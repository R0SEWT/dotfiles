#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For disabling touchpad.
# Lua config (Hyprland >= 0.56): toggles the device via `hyprctl eval`.
# Device name must match `touchpad` in ~/.config/hypr/lua/vars.lua

notif="$HOME/.config/swaync/images/ja.png"
TOUCHPAD_DEVICE="dell099f:00-044e:120a-touchpad"

export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

set_touchpad() {
	printf "%s" "$1" >"$STATUS_FILE"
	hyprctl eval "hl.device({ name = \"$TOUCHPAD_DEVICE\", enabled = $1 })"
}

enable_touchpad() {
	notify-send -u low -i $notif " Enabling" " touchpad"
	set_touchpad true
}

disable_touchpad() {
	notify-send -u low -i $notif " Disabling" " touchpad"
	set_touchpad false
}

if ! [ -f "$STATUS_FILE" ]; then
	enable_touchpad
elif [ "$(cat "$STATUS_FILE")" = "true" ]; then
	disable_touchpad
elif [ "$(cat "$STATUS_FILE")" = "false" ]; then
	enable_touchpad
fi
