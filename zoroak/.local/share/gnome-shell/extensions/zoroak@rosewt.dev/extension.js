import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import St from 'gi://St';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const SHEET_WIDTH = 1136;
const SHEET_HEIGHT = 1384;
const CELL_WIDTH = SHEET_WIDTH / 8;
const CELL_HEIGHT = SHEET_HEIGHT / 9;
const SCALE = 0.9;
const FRAME_INTERVAL_MS = 150;

const STATES = {
    idle: {row: 0, frames: 5},
    runRight: {row: 1, frames: 7},
    runLeft: {row: 2, frames: 7},
    wave: {row: 3, frames: 4},
    jump: {row: 4, frames: 4},
    failure: {row: 5, frames: 7},
    waiting: {row: 6, frames: 5},
    working: {row: 7, frames: 5},
    review: {row: 8, frames: 5},
};

const ALIASES = {
    active: 'working',
    processing: 'working',
    inspect: 'review',
    roaaak: 'wave',
};

export default class ZoroakExtension extends Extension {
    enable() {
        this._frame = 0;
        this._state = 'idle';
        const frameWidth = Math.round(CELL_WIDTH * SCALE);
        const frameHeight = Math.round(CELL_HEIGHT * SCALE);

        this._viewport = new St.Widget({
            style_class: 'zoroak-companion',
            reactive: true,
            width: frameWidth,
            height: frameHeight,
            clip_to_allocation: true,
        });

        this._sprite = new St.Widget({
            style_class: 'zoroak-sprite',
            width: Math.round(SHEET_WIDTH * SCALE),
            height: Math.round(SHEET_HEIGHT * SCALE),
        });
        this._viewport.add_child(this._sprite);

        this._viewport.connect('button-press-event', (_actor, event) => {
            if (event.get_button() === 3) {
                this._viewport.visible = false;
                return Clutter.EVENT_STOP;
            }
            return Clutter.EVENT_PROPAGATE;
        });

        Main.layoutManager.addChrome(this._viewport, {
            affectsInputRegion: true,
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
        this._stateFile = Gio.File.new_for_path(this._statePath);
        this._stateMonitor = this._stateFile.monitor_file(
            Gio.FileMonitorFlags.NONE, null);
        this._stateChangedId = this._stateMonitor.connect(
            'changed', () => this._readState());

        this._readState();
        this._timerId = GLib.timeout_add(
            GLib.PRIORITY_DEFAULT,
            FRAME_INTERVAL_MS,
            () => this._advanceFrame());
        this._renderFrame();
    }

    disable() {
        if (this._timerId) {
            GLib.source_remove(this._timerId);
            this._timerId = null;
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
            const state = ALIASES[requested] ?? requested;
            if (STATES[state] && state !== this._state) {
                this._state = state;
                this._frame = 0;
                this._viewport.visible = true;
                this._renderFrame();
            }
        } catch (_error) {
            this._state = 'idle';
        }
    }

    _advanceFrame() {
        const animation = STATES[this._state];
        this._frame = (this._frame + 1) % animation.frames;
        this._renderFrame();
        return GLib.SOURCE_CONTINUE;
    }

    _renderFrame() {
        const animation = STATES[this._state];
        const x = -Math.round(this._frame * CELL_WIDTH * SCALE);
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
