-- Window and layer rules (was UserConfigs/WindowRules.conf)
-- Rules run top to bottom and the last match wins, so tags are assigned first.

local function rule(match, effects)
    effects.match = match
    hl.window_rule(effects)
end

-- Monitor-relative size/move, e.g. pct(70, 60) -> 70% x 60% of the monitor
local function pct(w, h)
    return { "monitor_w*" .. w / 100, "monitor_h*" .. h / 100 }
end

---------- TAGS ----------
local tags = {
    browser = {
        { class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$" },
        { class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$" },
        { class = "^(chrome-.+-Default)$" }, -- Chrome PWAs
        { class = "^([Cc]hromium)$" },
        { class = "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$" },
        { class = "^(Brave-browser(-beta|-dev|-unstable)?)$" },
        { class = "^([Tt]horium-browser|[Cc]achy-browser)$" },
        { class = "^(zen-alpha|zen)$" },
    },
    notif = {
        { class = "^(swaync-control-center|swaync-notification-window|swaync-client|class)$" },
    },
    KooL_Cheat    = { { title = "^(KooL Quick Cheat Sheet)$" } },
    KooL_Settings = { { title = "^(KooL Hyprland Settings)$" } },
    ["KooL-Settings"] = { { class = "^(nwg-displays|nwg-look)$" } },
    terminal = { { class = "^(Alacritty|kitty|kitty-dropterm)$" } },
    email = {
        { class = "^([Tt]hunderbird|org.gnome.Evolution)$" },
        { class = "^(eu.betterbird.Betterbird)$" },
    },
    projects = {
        { class = "^(codium|codium-url-handler|VSCodium)$" },
        { class = "^(VSCode|code-url-handler)$" },
        { class = "^(jetbrains-.+)$" }, -- JetBrains IDEs
    },
    screenshare = { { class = "^(com.obsproject.Studio)$" } },
    im = {
        { class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$" },
        { class = "^([Ff]erdium)$" },
        { class = "^([Ww]hatsapp-for-linux)$" },
        { class = "^(ZapZap|com.rtosta.zapzap)$" },
        { class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$" },
        { class = "^(teams-for-linux)$" },
    },
    games = {
        { class = "^(gamescope)$" },
        { class = "^(steam_app_\\d+)$" },
    },
    gamestore = {
        { class = "^([Ss]team)$" },
        { title = "^([Ll]utris)$" },
        { class = "^(com.heroicgameslauncher.hgl)$" },
    },
    ["file-manager"] = {
        { class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$" },
        { class = "^(app.drey.Warp)$" },
    },
    wallpaper        = { { class = "^([Ww]aytrogen)$" } },
    multimedia       = { { class = "^([Aa]udacious)$" } },
    multimedia_video = { { class = "^([Mm]pv|vlc)$" } },
    settings = {
        { title = "^(ROG Control)$" },
        { class = "^(wihotspot(-gui)?)$" }, -- wifi hotspot
        { class = "^([Bb]aobab|org.gnome.[Bb]aobab)$" }, -- disk usage analyzer
        { class = "^(gnome-disks|wihotspot(-gui)?)$" },
        { title = "(Kvantum Manager)" },
        { class = "^(file-roller|org.gnome.FileRoller)$" }, -- archive manager
        { class = "^(nm-applet|nm-connection-editor|blueman-manager)$" },
        { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" },
        { class = "^(qt5ct|qt6ct|[Yy]ad)$" },
        { class = "(xdg-desktop-portal-gtk)" },
        { class = "^(org.kde.polkit-kde-authentication-agent-1)$" },
        { class = "^([Rr]ofi)$" },
    },
    viewer = {
        { class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$" }, -- system monitor
        { class = "^(evince)$" }, -- document viewer
        { class = "^(eog|org.gnome.Loupe)$" }, -- image viewer
    },
}

-- pairs() has no fixed order; tag rules don't depend on each other, so that's fine
for tag, matches in pairs(tags) do
    for _, match in ipairs(matches) do
        rule(match, { tag = "+" .. tag })
    end
end

---------- SPECIAL OVERRIDES ----------
rule({ tag = "multimedia_video*" }, { no_blur = true, opacity = "1.0" })

---------- POSITION ----------
rule({ tag = "KooL_Cheat*" }, { center = true })
rule({ class = "([Tt]hunar)", title = "negative:(.*[Tt]hunar.*)" }, { center = true })
rule({ title = "^(ROG Control)$" }, { center = true })
rule({ tag = "KooL-Settings*" }, { center = true })
rule({ title = "^(Keybindings)$" }, { center = true })
rule({ class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, { center = true })
rule({ class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, { center = true })
rule({ class = "^([Ff]erdium)$" }, { center = true })
rule({ title = "^(Picture-in-Picture)$" }, { move = pct(72, 7) })

-- don't go idle while something is fullscreen
rule({ fullscreen = true }, { idle_inhibit = "fullscreen" })

---------- WORKSPACES ----------
rule({ tag = "email*" },     { workspace = "1" })
rule({ tag = "browser*" },   { workspace = "2" })
rule({ tag = "gamestore*" }, { workspace = "5" })
rule({ tag = "im*" },        { workspace = "7" })
rule({ tag = "games*" },     { workspace = "8" })

rule({ tag = "screenshare*" },               { workspace = "4 silent" })
rule({ class = "^(virt-manager)$" },         { workspace = "6 silent" })
rule({ class = "^(.virt-manager-wrapped)$" }, { workspace = "6 silent" })
rule({ tag = "multimedia*" },                { workspace = "9 silent" })

---------- FLOAT ----------
for _, t in ipairs({ "KooL_Cheat*", "wallpaper*", "settings*", "viewer*", "KooL-Settings*" }) do
    rule({ tag = t }, { float = true })
end
rule({ class = "([Zz]oom|onedriver|onedriver-launcher)$" }, { float = true })
rule({ class = "(org.gnome.Calculator)", title = "(Calculator)" }, { float = true })
rule({ class = "^(mpv|com.github.rafostar.Clapper)$" }, { float = true })
rule({ class = "^([Qq]alculate-gtk)$" }, { float = true })
rule({ class = "^([Ff]erdium)$" }, { float = true })
rule({ title = "^(Picture-in-Picture)$" }, { float = true })

-- popups and dialogs
rule({ title = "^(Authentication Required)$" }, { float = true, center = true })
rule({ class = "(codium|codium-url-handler|VSCodium)", title = "negative:(.*codium.*|.*VSCodium.*)" }, { float = true })
rule({ class = "^(com.heroicgameslauncher.hgl)$", title = "negative:(Heroic Games Launcher)" }, { float = true })
rule({ class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, { float = true })
rule({ class = "([Tt]hunar)", title = "negative:(.*[Tt]hunar.*)" }, { float = true })
rule({ title = "^(Add Folder to Workspace)$" }, { float = true, size = pct(70, 60), center = true })
rule({ title = "^(Save As)$" }, { float = true, size = pct(70, 60), center = true })
rule({ initial_title = "(Open Files)" }, { float = true, size = pct(70, 60) })
rule({ title = "^(SDDM Background)$" }, { float = true, center = true, size = pct(16, 12) }) -- KooL's SDDM YAD

---------- OPACITY ----------
rule({ tag = "browser*" },      { opacity = "0.9 0.7" })
rule({ tag = "projects*" },     { opacity = "0.9 0.8" })
rule({ tag = "im*" },           { opacity = "0.94 0.86" })
rule({ tag = "multimedia*" },   { opacity = "0.94 0.86" })
rule({ tag = "file-manager*" }, { opacity = "0.9 0.8" })
rule({ tag = "terminal*" },     { opacity = "0.8 0.7" })
rule({ tag = "settings*" },     { opacity = "0.8 0.7" })
rule({ tag = "viewer*" },       { opacity = "0.82 0.75" })
rule({ tag = "wallpaper*" },    { opacity = "0.9 0.7" })
rule({ class = "^(gedit|org.gnome.TextEditor|mousepad)$" }, { opacity = "0.8 0.7" })
rule({ class = "^(deluge)$" },       { opacity = "0.9 0.8" })
rule({ class = "^(im.riot.Riot)$" }, { opacity = "0.9 0.8" }) -- Element matrix client
rule({ class = "^(seahorse)$" },     { opacity = "0.9 0.8" }) -- gnome-keyring gui
rule({ title = "^(Picture-in-Picture)$" }, { opacity = "0.95 0.75" })

---------- SIZE ----------
rule({ tag = "KooL_Cheat*" }, { size = pct(65, 90) })
rule({ tag = "wallpaper*" },  { size = pct(70, 70) })
rule({ tag = "settings*" },   { size = pct(70, 70) })
rule({ class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, { size = pct(60, 70) })
rule({ class = "^([Ff]erdium)$" }, { size = pct(60, 70) })

---------- PIN / EXTRAS ----------
rule({ title = "^(Picture-in-Picture)$" }, { pin = true, keep_aspect_ratio = true })

---------- BLUR & FULLSCREEN ----------
rule({ tag = "games*" }, { no_blur = true, fullscreen = true })

---------- LAYER RULES ----------
hl.layer_rule({ match = { namespace = "rofi" },          blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0 })
