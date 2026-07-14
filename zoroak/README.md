# Zoroak Lab Companion

Animated research companion for GNOME Shell 46 on Ubuntu 24.04.

## Install

```bash
./scripts/stow.sh zoroak
gnome-extensions enable zoroak@rosewt.dev
```

Log out and back in if GNOME Shell has not discovered the extension yet. Wayland
does not support restarting GNOME Shell in place with `Alt+F2`, `r`.

## Control

```bash
zoroakctl idle
zoroakctl working
zoroakctl review
zoroakctl failure
zoroakctl waiting
zoroakctl roaaak
```

The companion is click-through: it never blocks clicks to the window or desktop
beneath it. Hide or show it explicitly with:

```bash
zoroakctl hide
zoroakctl show
```

## Tuning animations

Timings live in `animations.json` next to the extension. Each state has:

- `row` — atlas row (0-based) for this state
- `frames` — number of valid frames in that row (upper bound for `sequence`)
- `sequence` — column indices played in order; repeat an index to hold/pause,
  go up-and-down (e.g. `[0,1,2,3,2,1]`) for ping-pong
- `frameMs` — dwell time per step, in milliseconds
- `loop` — `true` repeats forever; `false` plays once then switches to `next`
- `next` — state to switch to after a one-shot (`loop: false`) finishes

The running extension watches the file: **save it and the animation updates
live, no logout.** Invalid JSON is ignored (last good config stays) so an
in-progress edit never breaks the companion. The built-in `DEFAULT_STATES` in
`extension.js` are the fallback if the file is missing.

### Iterating without logging out

Wayland cannot restart GNOME Shell in place, so changes to `extension.js`
(engine code) need a reload. Instead of logging out, run a throwaway nested
shell that loads the current code:

```bash
dbus-run-session -- gnome-shell --nested --wayland
```

Zoroak appears in that window running the on-disk code, and `zoroakctl` drives
it (the runtime state file is shared). Edit `animations.json` and watch it
hot-reload there; restart the nested window (~2s) to pick up `extension.js`
edits. Your real session is untouched. Deploy engine changes to the real
session with one logout when convenient.

## Remove

```bash
gnome-extensions disable zoroak@rosewt.dev
./scripts/unstow.sh zoroak
```
