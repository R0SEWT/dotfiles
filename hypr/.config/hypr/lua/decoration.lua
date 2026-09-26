-- Decorations (was UserConfigs/UserDecorations.conf + UserScripts/RainbowBorders.sh)

-- wallust writes wallust/colors.lua on every wallpaper change (template:
-- ~/.config/wallust/templates/colors-hyprland.lua). Fall back to fixed colors if it is missing.
local ok, c = pcall(require, "wallust.colors")
if not ok then
    c = { color0 = "rgb(49454A)", color10 = "rgb(6A3338)", color12 = "rgb(844C99)", color15 = "rgb(EBC9BF)" }
end

-- Rainbow active border: 10 random colours at 270deg (what RainbowBorders.sh did via hyprctl keyword)
local function rainbow()
    local colors = {}
    for i = 1, 10 do
        colors[i] = string.format("rgb(%06X)", math.random(0, 0xFFFFFF))
    end
    return { colors = colors, angle = 270 }
end

hl.config({
    general = {
        border_size = 2,
        gaps_in     = 2,
        gaps_out    = 4,
        col = {
            active_border   = rainbow(),
            inactive_border = c.color10,
        },
    },
    decoration = {
        rounding           = 10,
        active_opacity     = 1.0,
        inactive_opacity   = 0.9,
        fullscreen_opacity = 1.0,
        dim_inactive       = false,
        shadow = {
            enabled        = true,
            range          = 3,
            render_power   = 1,
            color          = c.color12,
            color_inactive = c.color10,
        },
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            ignore_opacity    = true,
            new_optimizations = true,
            special           = true,
            popups            = true,
        },
    },
    group = {
        col = {
            border_active = c.color15,
        },
        groupbar = {
            col = {
                active = c.color0,
            },
        },
    },
})
