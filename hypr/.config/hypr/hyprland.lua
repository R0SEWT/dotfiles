-- Hyprland config (Lua, Hyprland >= 0.56).
-- Migrated from KooL's hyprlang dots (v2.3.15). hyprland.conf and UserConfigs/*.conf
-- are kept only as a rollback path: Hyprland ignores them while this file exists.
--
-- Each require() runs in its own scope, so an error in one module does not stop the rest.
-- Stubs for editor autocompletion: /usr/share/hypr/stubs

require("lua.env")
require("lua.monitors")
require("lua.settings")
require("lua.decoration")
require("lua.animations")
require("lua.rules")
require("lua.keybinds")
require("lua.autostart")
