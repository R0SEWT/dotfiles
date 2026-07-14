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

## Remove

```bash
gnome-extensions disable zoroak@rosewt.dev
./scripts/unstow.sh zoroak
```
