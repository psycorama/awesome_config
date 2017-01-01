-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")
beautiful = require("beautiful")
naughty = require("naughty")

-- ### Simple function to load additional LUA files from rc-directory ###
function loadrc(name, mod)
    local success
    local result

    -- Which file? In rc/ or in lib/?
    local path = awful.util.getdir("config") .. "/" ..
        (mod and "lib" or "rc") ..
        "/" .. name .. ".lua"

    -- If the module is already loaded, don't load it again
    if mod and package.loaded[mod] then return package.loaded[mod] end

    -- Execute the RC/module file
    success, result = pcall(function() return dofile(path) end)
    if not success then
        naughty.notify({ title = "Error while loading an RC file",
                         text = "When loading `" .. name ..
                             "`, got the following error:\n" .. result,
                         preset = naughty.config.presets.critical})
        return print("E: error loading RC file '" .. name .. "': " .. result)
    end

    -- Is it a module?
    if mod then
        return package.loaded[mod]
    end

    return result
end
-- ############################

-- # Error handling #
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
--

-- Variable definitions --
-- Themes define colours, icons, and wallpapers
-- beautiful.init("$HOME/.config/awesome/themes/default/theme.lua")
beautiful.init("/usr/local/share/awesome/themes/default/theme.lua")
-- beautiful.fg_widget_value = "#33FF33"
beautiful.border_focus = "#339933"

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "mg"
editor_cmd = terminal .. " -e " .. editor

-- Default modkeys --
modkey = "Mod4" -- [Super] key
altkey = "Mod1" --  [Alt]  key

config = {}
-- Table of layouts to cover with awful.layout.inc, order matters.
config.layouts =
{
--    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating,
--    awful.layout.suit.magnifier
}
--


-- ########## loading a bunch of stuff #############
loadrc("tags")
loadrc("keybindings")
loadrc("rules")
loadrc("signals")
loadrc("menu")
loadrc("wibox") -- replaces widgets (@todo: maybe test widgets again)
-- ###########################
