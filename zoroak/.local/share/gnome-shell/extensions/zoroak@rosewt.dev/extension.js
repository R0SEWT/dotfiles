import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import St from 'gi://St';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const SHEET_WIDTH = 1183;
const SHEET_HEIGHT = 1332;
const CELL_WIDTH = SHEET_WIDTH / 7;
const CELL_HEIGHT = SHEET_HEIGHT / 9;
const SCALE = 0.9;
const DEFAULT_FRAME_MS = 150;
const MANIFEST_FILENAME = 'animations.json';

// Timeline engine.
//
// Each state maps to one atlas row and describes a *timeline* over that row's
// frames rather than a plain 0..frames-1 loop:
//   row      - atlas row (0-based) holding this state's frames
//   frames   - number of valid frames in that row (upper bound for `sequence`)
//   sequence - column indices played in order; repeat an index to hold/pause,
//              go up-and-down for ping-pong. Defaults to [0..frames-1].
//   frameMs  - dwell time per sequence step (defaults to DEFAULT_FRAME_MS)
//   loop     - true: repeat forever; false: play once then go to `next`
//   next     - state to switch to when a one-shot (loop:false) finishes
//
// All timings use the existing atlas, so richer/longer animations are a config
// change here, not an engine rewrite.
//
// These are the built-in fallback defaults. At runtime they are overlaid by
// animations.json (see _loadManifest) so timings can be tuned live without a
// shell reload.
const DEFAULT_STATES = {
    idle: {
        row: 0, frames: 5,
        sequence: [0, 0, 0, 1, 2, 3, 4, 4, 3, 2, 1],
        frameMs: 180, loop: true,
    },
    runRight: {
        row: 1, frames: 7,
        sequence: [0, 1, 2, 3, 4, 5, 6],
        frameMs: 90, loop: true,
    },
    runLeft: {
        row: 2, frames: 7,
        sequence: [0, 1, 2, 3, 4, 5, 6],
        frameMs: 90, loop: true,
    },
    wave: {
        row: 3, frames: 4,
        sequence: [0, 1, 2, 3, 2, 1, 0],
        frameMs: 120, loop: false, next: 'idle',
    },
    jump: {
        row: 4, frames: 4,
        sequence: [0, 1, 2, 3, 2, 0],
        frameMs: 110, loop: false, next: 'idle',
    },
    failure: {
        row: 5, frames: 7,
        sequence: [0, 1, 2, 3, 4, 5, 6, 6, 6],
        frameMs: 130, loop: false, next: 'idle',
    },
    waiting: {
        row: 6, frames: 5,
        sequence: [0, 1, 2, 3, 4, 4, 3, 2, 1, 0, 0, 0],
        frameMs: 200, loop: true,
    },
    working: {
        row: 7, frames: 5,
        sequence: [0, 1, 2, 3, 4],
        frameMs: 140, loop: true,
    },
    review: {
        row: 8, frames: 5,
        sequence: [0, 0, 1, 2, 3, 4, 4, 3, 2, 1],
        frameMs: 170, loop: true,
    },
};

const DEFAULT_ALIASES = {
    active: 'working',
    processing: 'working',
    inspect: 'review',
    roaaak: 'wave',
};

export default class ZoroakExtension extends Extension {
    enable() {
        this._state = null;
        this._seqIndex = 0;
        this._timerId = 0;
        this._states = DEFAULT_STATES;
        this._aliases = DEFAULT_ALIASES;
        const frameWidth = Math.round(CELL_WIDTH * SCALE);
        const frameHeight = Math.round(CELL_HEIGHT * SCALE);

        this._viewport = new St.Widget({
            style_class: 'zoroak-companion',
            reactive: false,
            visible: true,
            opacity: 255,
            width: frameWidth,
            height: frameHeight,
            clip_to_allocation: true,
        });

        const spriteFile = Gio.File.new_for_path(GLib.build_filenamev([
            this.path,
            'sprites',
            'zoroak.png',
        ]));
        this._sprite = St.TextureCache.get_default().load_file_async(
            spriteFile,
            Math.round(SHEET_WIDTH * SCALE),
            Math.round(SHEET_HEIGHT * SCALE),
            1,
            1.0);
        this._viewport.add_child(this._sprite);

        // Click-through: keep the companion out of the shell input region so
        // clicks reach the window/desktop underneath it. Visibility is driven
        // by the `hide`/`show` states via zoroakctl instead of a right-click.
        Main.layoutManager.addChrome(this._viewport, {
            affectsInputRegion: false,
            affectsStruts: false,
            trackFullscreen: true,
        });
        this._placeAtBottomRight();

        this._monitorChangedId = Main.layoutManager.connect(
            'monitors-changed', () => this._placeAtBottomRight());

        this._statePath = GLib.build_filenamev([
            GLib.get_user_runtime_dir(),
            'zoroak-state',
        ]);
        if (!GLib.file_test(this._statePath, GLib.FileTest.EXISTS))
            GLib.file_set_contents(this._statePath, 'idle\n');
        this._stateFile = Gio.File.new_for_path(this._statePath);
        this._stateMonitor = this._stateFile.monitor_file(
            Gio.FileMonitorFlags.NONE, null);
        this._stateChangedId = this._stateMonitor.connect(
            'changed', () => this._readState());

        // Load the animations manifest and watch it for live edits. A save to
        // animations.json re-applies timings without a shell reload.
        this._manifestPath = GLib.build_filenamev([
            this.path,
            MANIFEST_FILENAME,
        ]);
        this._loadManifest();
        this._manifestFile = Gio.File.new_for_path(this._manifestPath);
        this._manifestMonitor = this._manifestFile.monitor_file(
            Gio.FileMonitorFlags.NONE, null);
        this._manifestChangedId = this._manifestMonitor.connect(
            'changed', () => this._onManifestChanged());

        // Seeds the state from the runtime file and starts the timeline clock.
        this._readState();
        if (!this._state)
            this._setState('idle');
    }

    disable() {
        if (this._timerId) {
            GLib.source_remove(this._timerId);
            this._timerId = 0;
        }
        if (this._stateMonitor) {
            if (this._stateChangedId)
                this._stateMonitor.disconnect(this._stateChangedId);
            this._stateMonitor.cancel();
            this._stateMonitor = null;
        }
        if (this._manifestMonitor) {
            if (this._manifestChangedId)
                this._manifestMonitor.disconnect(this._manifestChangedId);
            this._manifestMonitor.cancel();
            this._manifestMonitor = null;
        }
        if (this._monitorChangedId) {
            Main.layoutManager.disconnect(this._monitorChangedId);
            this._monitorChangedId = null;
        }
        this._viewport?.destroy();
        this._viewport = null;
        this._sprite = null;
    }

    _readState() {
        try {
            const [, bytes] = GLib.file_get_contents(this._statePath);
            const requested = new TextDecoder().decode(bytes).trim();

            if (requested === 'hide') {
                if (this._viewport)
                    this._viewport.visible = false;
                return;
            }
            if (requested === 'show') {
                if (this._viewport)
                    this._viewport.visible = true;
                return;
            }

            const state = this._aliases[requested] ?? requested;
            const animation = this._states[state];
            if (!animation)
                return;

            if (this._viewport)
                this._viewport.visible = true;

            // A repeated one-shot request (e.g. running `zoroakctl roaaak`
            // again) should replay from the start; a looping state already
            // playing is left alone to avoid a visible jump.
            this._setState(state, {restart: !animation.loop});
        } catch (_error) {
            this._setState('idle', {restart: true});
        }
    }

    _setState(state, {restart = false} = {}) {
        const animation = this._states[state];
        if (!animation)
            return;
        if (state === this._state && !restart)
            return;

        this._state = state;
        this._seqIndex = 0;
        this._renderFrame();
        this._scheduleNextFrame();
    }

    _sequenceFor(animation) {
        return animation.sequence ??
            Array.from({length: animation.frames}, (_, i) => i);
    }

    _scheduleNextFrame() {
        if (this._timerId) {
            GLib.source_remove(this._timerId);
            this._timerId = 0;
        }
        const animation = this._states[this._state];
        const delay = animation.frameMs ?? DEFAULT_FRAME_MS;
        this._timerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, delay, () => {
            this._timerId = 0;
            this._advanceFrame();
            return GLib.SOURCE_REMOVE;
        });
    }

    _advanceFrame() {
        const animation = this._states[this._state];
        const sequence = this._sequenceFor(animation);
        this._seqIndex += 1;

        if (this._seqIndex >= sequence.length) {
            if (animation.loop) {
                this._seqIndex = 0;
            } else {
                // One-shot finished: hand off to the follow-up state.
                this._setState(animation.next ?? 'idle', {restart: true});
                return;
            }
        }

        this._renderFrame();
        this._scheduleNextFrame();
    }

    _renderFrame() {
        const animation = this._states[this._state];
        const sequence = this._sequenceFor(animation);
        const column = sequence[this._seqIndex] ?? 0;
        const x = -Math.round(column * CELL_WIDTH * SCALE);
        const y = -Math.round(animation.row * CELL_HEIGHT * SCALE);
        this._sprite.set_position(x, y);
    }

    _onManifestChanged() {
        // Editors write via truncate or temp+rename; either way we just try to
        // reload. A failed parse (mid-save) keeps the last-good tables.
        if (!this._loadManifest())
            return;

        // Re-apply the current animation so timing/sequence edits show up at
        // once. If the playing state vanished from the manifest, fall to idle.
        const current = this._state && this._states[this._state]
            ? this._state
            : 'idle';
        this._setState(current, {restart: true});
    }

    _loadManifest() {
        // Overlays animations.json (if present and valid) on the built-in
        // defaults. Returns true only when a valid manifest was applied.
        if (!GLib.file_test(this._manifestPath, GLib.FileTest.EXISTS))
            return false;
        try {
            const [ok, bytes] = GLib.file_get_contents(this._manifestPath);
            if (!ok)
                return false;
            const manifest = JSON.parse(new TextDecoder().decode(bytes));
            return this._applyManifest(manifest);
        } catch (error) {
            logError(error, 'Zoroak: ignoring invalid animations.json');
            return false;
        }
    }

    _applyManifest(manifest) {
        if (!manifest || typeof manifest !== 'object')
            return false;
        this._states = this._validateStates(manifest.states);
        this._aliases = this._validateAliases(manifest.aliases);
        return true;
    }

    _validateStates(raw) {
        // Start from a copy of the defaults so a partial or broken manifest
        // still yields a complete, safe set (idle always exists).
        const result = {};
        for (const [name, def] of Object.entries(DEFAULT_STATES))
            result[name] = {...def};

        if (!raw || typeof raw !== 'object')
            return result;

        for (const [name, value] of Object.entries(raw)) {
            const clean = this._validateState(value, result[name]);
            if (clean)
                result[name] = clean;
        }
        return result;
    }

    _validateState(value, fallback) {
        if (!value || typeof value !== 'object')
            return fallback ?? null;

        const row = Number.isInteger(value.row) ? value.row : fallback?.row;
        const frames = Number.isInteger(value.frames) && value.frames > 0
            ? value.frames
            : fallback?.frames;
        if (!Number.isInteger(row) || row < 0 || !Number.isInteger(frames))
            return fallback ?? null;

        // Keep only integer indices within [0, frames-1]; fall back to the
        // default sequence (clamped) or a straight 0..frames-1 run.
        let sequence = Array.isArray(value.sequence)
            ? value.sequence.filter(i => Number.isInteger(i) && i >= 0 && i < frames)
            : [];
        if (sequence.length === 0 && Array.isArray(fallback?.sequence))
            sequence = fallback.sequence.filter(i => i >= 0 && i < frames);
        if (sequence.length === 0)
            sequence = Array.from({length: frames}, (_, i) => i);

        const frameMs = Number.isFinite(value.frameMs) && value.frameMs > 0
            ? value.frameMs
            : (fallback?.frameMs ?? DEFAULT_FRAME_MS);
        const loop = typeof value.loop === 'boolean'
            ? value.loop
            : (fallback?.loop ?? true);

        const clean = {row, frames, sequence, frameMs, loop};
        const next = typeof value.next === 'string' && value.next
            ? value.next
            : fallback?.next;
        if (typeof next === 'string' && next)
            clean.next = next;
        return clean;
    }

    _validateAliases(raw) {
        const result = {...DEFAULT_ALIASES};
        if (raw && typeof raw === 'object') {
            for (const [key, target] of Object.entries(raw)) {
                if (typeof target === 'string' && target)
                    result[key] = target;
            }
        }
        return result;
    }

    _placeAtBottomRight() {
        const monitor = Main.layoutManager.primaryMonitor;
        if (!monitor || !this._viewport)
            return;

        const margin = 24;
        this._viewport.set_position(
            monitor.x + monitor.width - this._viewport.width - margin,
            monitor.y + monitor.height - this._viewport.height - margin);
    }
}
