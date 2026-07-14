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

Right-click hides the companion until the next state change.

## Remove

```bash
gnome-extensions disable zoroak@rosewt.dev
./scripts/unstow.sh zoroak
```
