-- Autostart (was UserConfigs/Startup_Apps.conf exec-once lines)
-- RainbowBorders.sh is gone: lua/decoration.lua sets the rainbow border itself.

local v = require("lua.vars")

hl.on("hyprland.start", function()
    hl.exec_cmd("swww-daemon --format xrgb")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd(v.scriptsDir .. "/Polkit.sh")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("swaync")
    hl.exec_cmd("ags")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("waybar")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hypridle")
end)
