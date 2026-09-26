#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Game Mode. Turning off all animations
# Lua config (Hyprland >= 0.56): `hyprctl keyword` no longer works, settings go through `hyprctl eval`.

notif="$HOME/.config/swaync/images/ja.png"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# animations.enabled is a bool now: getoption -j returns {"bool": true|false}
ANIMATIONS=$(hyprctl -j getoption animations:enabled | jq -r '.bool')

if [ "$ANIMATIONS" = "true" ]; then
	hyprctl eval '
		hl.config({
			animations = { enabled = false },
			decoration = { shadow = { enabled = false }, blur = { enabled = false }, rounding = 0 },
			general    = { gaps_in = 0, gaps_out = 0, border_size = 1 },
		})
		hl.window_rule({ match = { class = ".*" }, opacity = "1 override 1 override 1 override" })'
	swww kill
	notify-send -e -u low -i "$notif" " Gamemode:" " enabled"
else
	swww-daemon --format xrgb && swww img "$HOME/.config/rofi/.current_wallpaper" &
	sleep 0.1
	${SCRIPTSDIR}/WallustSwww.sh
	sleep 0.5
	# reload drops the runtime overrides above (the old script never restored them)
	hyprctl reload
	${SCRIPTSDIR}/Refresh.sh
	notify-send -e -u normal -i "$notif" " Gamemode:" " disabled"
fi
