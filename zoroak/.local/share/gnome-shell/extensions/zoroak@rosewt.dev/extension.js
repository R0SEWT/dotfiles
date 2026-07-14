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
const STATES = {
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

const ALIASES = {
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

            const state = ALIASES[requested] ?? requested;
            const animation = STATES[state];
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
        const animation = STATES[state];
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
        const animation = STATES[this._state];
        const delay = animation.frameMs ?? DEFAULT_FRAME_MS;
        this._timerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, delay, () => {
            this._timerId = 0;
            this._advanceFrame();
            return GLib.SOURCE_REMOVE;
        });
    }

    _advanceFrame() {
        const animation = STATES[this._state];
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
        const animation = STATES[this._state];
        const sequence = this._sequenceFor(animation);
        const column = sequence[this._seqIndex] ?? 0;
        const x = -Math.round(column * CELL_WIDTH * SCALE);
        const y = -Math.round(animation.row * CELL_HEIGHT * SCALE);
        this._sprite.set_position(x, y);
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
