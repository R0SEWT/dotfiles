-- Monitors and workspace placement (was monitors.conf + workspaces.conf, written by nwg-displays).
-- nwg-displays still writes the .conf files; copy any change it makes here by hand.

hl.monitor({ output = "eDP-1", mode = "1920x1080@59.99", position = "676x1440", scale = 1 })
hl.monitor({ output = "DP-3",  mode = "1920x1080@60.0",  position = "2596x802", scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
for _, ws in ipairs({ 2, 3, 4, 5 }) do
    hl.workspace_rule({ workspace = tostring(ws), monitor = "eDP-1" })
end
for _, ws in ipairs({ 6, 7, 8, 9, 10 }) do
    hl.workspace_rule({ workspace = tostring(ws), monitor = "HDMI-A-1" })
end
