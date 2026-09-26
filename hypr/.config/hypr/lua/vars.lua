-- Shared paths and default apps (was 01-UserDefaults.conf + the $vars repeated in every file)

local home = os.getenv("HOME")

return {
    mainMod     = "SUPER",
    term        = "kitty",
    files       = "thunar",
    scriptsDir  = home .. "/.config/hypr/scripts",
    UserScripts = home .. "/.config/hypr/UserScripts",
    UserConfigs = home .. "/.config/hypr/UserConfigs",
    wallDIR     = home .. "/Pictures/wallpapers",
    touchpad    = "dell099f:00-044e:120a-touchpad",
}
