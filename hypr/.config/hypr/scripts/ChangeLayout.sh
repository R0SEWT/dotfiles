#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# for changing Hyprland Layouts (Master or Dwindle) on the fly
# Lua config (Hyprland >= 0.56): SUPER+J/K already pick the right action for the
# current layout (see ~/.config/hypr/lua/keybinds.lua), so only the layout changes here.

notif="$HOME/.config/swaync/images/ja.png"

LAYOUT=$(hyprctl -j getoption general:layout | jq -r '.str')

case $LAYOUT in
"master")
	hyprctl eval 'hl.config({ general = { layout = "dwindle" } })'
	notify-send -e -u low -i "$notif" " Dwindle Layout"
	;;
"dwindle")
	hyprctl eval 'hl.config({ general = { layout = "master" } })'
	notify-send -e -u low -i "$notif" " Master Layout"
	;;
*) ;;
esac
