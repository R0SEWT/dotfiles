-- Main settings (was UserConfigs/UserSettings.conf + the device block in Laptops.conf)

local v = require("lua.vars")

hl.config({
    dwindle = {
        preserve_split       = true,
        special_scale_factor = 0.8,
    },
    master = {
        new_status = "master",
        new_on_top = true,
        mfact      = 0.5,
    },
    general = {
        resize_on_border = true,
        layout           = "dwindle",
    },
    input = {
        kb_layout                   = "us,es",
        kb_options                  = "grp:alt_shift_toggle",
        repeat_rate                 = 50,
        repeat_delay                = 300,
        sensitivity                 = 0,
        numlock_by_default          = true,
        left_handed                 = false,
        follow_mouse                = 1,
        float_switch_override_focus = 0,
        touchpad = {
            disable_while_typing    = true,
            natural_scroll          = true,
            clickfinger_behavior    = true,
            middle_button_emulation = false,
            tap_to_click            = true,
            drag_lock               = 0,
        },
        touchdevice = {
            enabled = true,
        },
        tablet = {
            transform   = 0,
            left_handed = false,
        },
    },
    gestures = {
        workspace_swipe_distance           = 300,
        workspace_swipe_invert             = true,
        workspace_swipe_min_speed_to_force = 20,
        workspace_swipe_cancel_ratio       = 0.5,
        workspace_swipe_create_new         = true,
        workspace_swipe_forever            = true,
    },
    misc = {
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        vrr                        = 0,
        mouse_move_enables_dpms    = true,
        enable_swallow             = true,
        swallow_regex              = "^(kitty)$",
        focus_on_activate          = true,
        initial_workspace_tracking = 0,
        middle_click_paste         = false,
    },
    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
        pass_mouse_when_bound    = false,
    },
    xwayland = {
        enabled            = true,
        force_zero_scaling = true,
    },
    render = {
        direct_scanout = 1,
    },
    cursor = {
        sync_gsettings_theme     = true,
        no_hardware_cursors      = 2,
        enable_hyprcursor        = true,
        warp_on_change_workspace = 2,
        no_warps                 = false,
    },
})

-- Touchpad: TouchPad.sh (xf86TouchpadToggle) flips `enabled` at runtime
hl.device({ name = v.touchpad, enabled = true, sensitivity = 0.85 })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "special" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({
    fingers   = 3,
    direction = "down",
    action    = function()
        hl.exec_cmd("pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window")
    end,
})
