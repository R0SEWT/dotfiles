-- Keybinds (was configs/Keybinds.conf + UserConfigs/UserKeybinds.conf + binds in Laptops.conf)
-- KeyHints.sh / KeyBinds.sh still read the old .conf files, so the cheat sheets show those.

local v    = require("lua.vars")
local mod  = v.mainMod
local dsp  = hl.dsp
local win  = hl.dsp.window
local sh   = v.scriptsDir .. "/"
local ush  = v.UserScripts .. "/"

local function bind(keys, action, opts)
    if type(action) == "string" then
        action = dsp.exec_cmd(action)
    end
    return hl.bind(keys, action, opts)
end

local rofi = "pkill rofi || true && "

---------- SESSION ----------
bind("CTRL + ALT + Delete", dsp.exit())
bind(mod .. " + Q",          win.close())
bind(mod .. " + SHIFT + Q",  sh .. "KillActiveProcess.sh")
bind("CTRL + ALT + L",       sh .. "LockScreen.sh")
bind("CTRL + ALT + P",       sh .. "Wlogout.sh")
bind(mod .. " + SHIFT + N",  "swaync-client -t -sw")
bind(mod .. " + SHIFT + E",  sh .. "Kool_Quick_Settings.sh")

---------- APPS ----------
bind(mod .. " + D",               rofi .. "rofi -show drun -modi drun,filebrowser,run,window")
bind(mod .. " + B",               'xdg-open "https://"')
bind(mod .. " + A",               rofi .. "ags -t 'overview'")
bind(mod .. " + Return",          v.term)
bind(mod .. " + E",               v.files)
bind(mod .. " + SHIFT + Return",  dsp.exec_cmd(v.term, {
    float = true, move = { "monitor_w*0.15", "monitor_h*0.05" }, size = { "monitor_w*0.7", "monitor_h*0.6" },
})) -- dropdown terminal

---------- KOOL MENUS / SCRIPTS ----------
bind(mod .. " + H",                   sh .. "KeyHints.sh")
bind(mod .. " + ALT + R",             sh .. "Refresh.sh")
bind(mod .. " + ALT + E",             sh .. "RofiEmoji.sh")
bind(mod .. " + S",                   sh .. "RofiSearch.sh")
bind(mod .. " + ALT + O",             sh .. "ChangeBlur.sh")
bind(mod .. " + SHIFT + G",           sh .. "GameMode.sh")
bind(mod .. " + ALT + L",             sh .. "ChangeLayout.sh")
bind(mod .. " + ALT + V",             sh .. "ClipManager.sh")
bind(mod .. " + CTRL + R",            sh .. "RofiThemeSelector.sh")
bind(mod .. " + CTRL + SHIFT + R",    rofi .. sh .. "RofiThemeSelector-modified.sh")
bind(mod .. " + CTRL + ALT + B",      "pkill -SIGUSR1 waybar") -- hide/show waybar
bind(mod .. " + CTRL + B",            sh .. "WaybarStyles.sh")
bind(mod .. " + ALT + B",             sh .. "WaybarLayout.sh")
bind(mod .. " + SHIFT + M",           ush .. "RofiBeats.sh")
bind(mod .. " + W",                   ush .. "WallpaperSelect.sh")
bind(mod .. " + SHIFT + W",           ush .. "WallpaperEffects.sh")
bind("CTRL + ALT + W",                ush .. "WallpaperRandom.sh")
bind(mod .. " + SHIFT + K",           sh .. "KeyBinds.sh")
bind(mod .. " + SHIFT + A",           sh .. "Animations.sh")
bind(mod .. " + SHIFT + O",           ush .. "ZshChangeTheme.sh")
bind(mod .. " + ALT + C",             ush .. "RofiCalc.sh")
-- bindln = ALT_L, SHIFT_L: ALT held, fires on Shift_L release, lets the keys through
bind("ALT + Shift_L", sh .. "SwitchKeyboardLayout.sh", { release = true, non_consuming = true })

---------- LAYOUTS ----------
bind(mod .. " + CTRL + D",      dsp.layout("removemaster"))
bind(mod .. " + I",             dsp.layout("addmaster"))
-- J/K cycle windows on either layout (ChangeLayout.sh used to rebind them on every switch)
local function cycle(next)
    return function()
        if hl.get_config("general.layout") == "master" then
            hl.dispatch(dsp.layout(next and "cyclenext" or "cycleprev"))
        else
            hl.dispatch(win.cycle_next({ next = next }))
        end
    end
end
bind(mod .. " + J",             cycle(true))
bind(mod .. " + K",             cycle(false))
bind(mod .. " + CTRL + Return", dsp.layout("swapwithmaster"))
bind(mod .. " + SHIFT + I",     dsp.layout("togglesplit")) -- dwindle
bind(mod .. " + P",             win.pseudo())              -- dwindle
bind(mod .. " + M",             dsp.layout("splitratio 0.3"))

---------- GROUPS ----------
bind(mod .. " + G",          hl.dsp.group.toggle())
bind(mod .. " + CTRL + Tab", hl.dsp.group.next())

---------- WINDOW STATE ----------
bind("ALT + Tab", function()
    hl.dispatch(win.cycle_next())
    hl.dispatch(win.bring_to_top())
end)
bind(mod .. " + SHIFT + F", win.fullscreen())
bind(mod .. " + CTRL + F",  win.fullscreen({ mode = "maximized" })) -- fake fullscreen
bind(mod .. " + SPACE",     win.float({ action = "toggle" }))
bind(mod .. " + CTRL + O",  win.set_prop({ prop = "opaque", value = "toggle" }))

-- was `workspaceopt allfloat` (removed upstream): toggle float for every window on this workspace
bind(mod .. " + ALT + SPACE", function()
    local ws = hl.get_active_workspace()
    if ws == nil then
        return
    end
    for _, w in ipairs(hl.get_workspace_windows(ws)) do
        hl.dispatch(win.float({ window = w, action = "toggle" }))
    end
end)

-- cursor zoom with SUPER+ALT+scroll
local function zoom(factor)
    return function()
        local current = math.max(hl.get_config("cursor.zoom_factor") or 1, 1)
        hl.config({ cursor = { zoom_factor = math.max(current * factor, 1) } })
    end
end
bind(mod .. " + ALT + mouse_down", zoom(2))
bind(mod .. " + ALT + mouse_up",   zoom(0.5))

---------- MEDIA / HARDWARE KEYS ----------
bind("XF86AudioRaiseVolume",  sh .. "Volume.sh --inc",        { locked = true, repeating = true })
bind("XF86AudioLowerVolume",  sh .. "Volume.sh --dec",        { locked = true, repeating = true })
bind("XF86AudioMicMute",      sh .. "Volume.sh --toggle-mic", { locked = true })
bind("XF86AudioMute",         sh .. "Volume.sh --toggle",     { locked = true })
bind("XF86Sleep",             "systemctl suspend",            { locked = true })
bind("XF86RFKill",            sh .. "AirplaneMode.sh",        { locked = true })
bind("XF86AudioPause",        sh .. "MediaCtrl.sh --pause",   { locked = true })
bind("XF86AudioPlay",         sh .. "MediaCtrl.sh --pause",   { locked = true })
bind("XF86AudioNext",         sh .. "MediaCtrl.sh --nxt",     { locked = true })
bind("XF86AudioPrev",         sh .. "MediaCtrl.sh --prv",     { locked = true })
bind("XF86AudioStop",         sh .. "MediaCtrl.sh --stop",    { locked = true })
bind("XF86KbdBrightnessDown", sh .. "BrightnessKbd.sh --dec", { repeating = true })
bind("XF86KbdBrightnessUp",   sh .. "BrightnessKbd.sh --inc", { repeating = true })
bind("XF86MonBrightnessDown", sh .. "Brightness.sh --dec",    { repeating = true })
bind("XF86MonBrightnessUp",   sh .. "Brightness.sh --inc",    { repeating = true })
bind("XF86TouchpadToggle",    sh .. "TouchPad.sh")

---------- SCREENSHOTS ----------
for _, key in ipairs({ "Print", "F6" }) do
    bind(mod .. " + " .. key,           sh .. "ScreenShot.sh --now")
    bind(mod .. " + SHIFT + " .. key,   sh .. "ScreenShot.sh --area")
    bind(mod .. " + CTRL + " .. key,    sh .. "ScreenShot.sh --in5")
    bind("ALT + " .. key,               sh .. "ScreenShot.sh --active")
end
bind(mod .. " + CTRL + SHIFT + Print", sh .. "ScreenShot.sh --in10")
bind(mod .. " + ALT + F6",             sh .. "ScreenShot.sh --in10")
bind(mod .. " + SHIFT + S",            sh .. "ScreenShot.sh --swappy")

---------- MOVE / RESIZE / FOCUS ----------
local resize = { left = { -50, 0 }, right = { 50, 0 }, up = { 0, -50 }, down = { 0, 50 } }
for dir, delta in pairs(resize) do
    bind(mod .. " + SHIFT + " .. dir, win.resize({ x = delta[1], y = delta[2], relative = true }), { repeating = true })
    bind(mod .. " + CTRL + " .. dir,  win.move({ direction = dir }))
    bind(mod .. " + ALT + " .. dir,   win.swap({ direction = dir }))
    bind(mod .. " + " .. dir,         dsp.focus({ direction = dir }))
end

bind(mod .. " + mouse:272", win.drag(),   { mouse = true })
bind(mod .. " + mouse:273", win.resize(), { mouse = true })

---------- WORKSPACES ----------
bind(mod .. " + Tab",         dsp.focus({ workspace = "m+1" }))
bind(mod .. " + SHIFT + Tab", dsp.focus({ workspace = "m-1" }))

bind(mod .. " + U",         hl.dsp.workspace.toggle_special(""))
bind(mod .. " + SHIFT + U", win.move({ workspace = "special" }))

-- code:10..19 = keys 1..0, so it works with any keyboard layout
for i = 1, 10 do
    local key = "code:" .. (9 + i)
    bind(mod .. " + " .. key,            dsp.focus({ workspace = i }))
    bind(mod .. " + SHIFT + " .. key,    win.move({ workspace = i }))
    bind(mod .. " + CTRL + " .. key,     win.move({ workspace = i, follow = false }))
end

bind(mod .. " + SHIFT + bracketleft",  win.move({ workspace = "-1" }))
bind(mod .. " + SHIFT + bracketright", win.move({ workspace = "+1" }))
bind(mod .. " + CTRL + bracketleft",   win.move({ workspace = "-1", follow = false }))
bind(mod .. " + CTRL + bracketright",  win.move({ workspace = "+1", follow = false }))

bind(mod .. " + mouse_down", dsp.focus({ workspace = "e+1" }))
bind(mod .. " + mouse_up",   dsp.focus({ workspace = "e-1" }))
bind(mod .. " + period",     dsp.focus({ workspace = "e+1" }))
bind(mod .. " + comma",      dsp.focus({ workspace = "e-1" }))
