-- Environment variables (was UserConfigs/ENVariables.conf)

local env = {
    GDK_BACKEND                         = "wayland,x11,*",
    QT_QPA_PLATFORM                     = "wayland;xcb",
    CLUTTER_BACKEND                     = "wayland",
    XDG_CURRENT_DESKTOP                 = "Hyprland",
    XDG_SESSION_DESKTOP                 = "Hyprland",
    XDG_SESSION_TYPE                    = "wayland",
    QT_AUTO_SCREEN_SCALE_FACTOR         = "1",
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
    -- the .conf set qt5ct and then qt6ct; the last one won
    QT_QPA_PLATFORMTHEME                = "qt6ct",
    QT_QUICK_CONTROLS_STYLE             = "org.hyprland.style",
    GDK_SCALE                           = "1",
    QT_SCALE_FACTOR                     = "1",
    HYPRCURSOR_THEME                    = "Bibata-Modern-Ice",
    HYPRCURSOR_SIZE                     = "24",
    MOZ_ENABLE_WAYLAND                  = "1",
    ELECTRON_OZONE_PLATFORM_HINT        = "auto", -- Wayland if possible, X11 otherwise
}

for name, value in pairs(env) do
    hl.env(name, value)
end
