-- Wibox --
wibox = require("wibox")
vicious = require("vicious")

-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
                awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, function ()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ width=250 })
        end
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then
            client.focus:raise()
        end
    end)
)

-- ########### registration for widgets #############
-- CPU temp --
local thermalwidget  = wibox.widget.textbox()
vicious.register( thermalwidget,
    vicious.widgets.thermal,
    function(widget, args)
        local labels = { "Mobo", "CPU" }
        local var = ""
        local cnt = 1
        while cnt <= #args do
            var = var .. " " .. labels[cnt]
            value = tonumber(args[cnt])
            if value >= 65 then
                var = var .. " <span color='red'>"
            elseif value >= 50 then
                var = var .. " <span color='orange'>"
            elseif value >= 35 then
                var = var .. " <span color='yellow'>"
            else
                var = var .. " <span color='cyan'>"
            end
            var = var .. value .. "°C</span>"
            cnt = cnt + 1
        end
        return "|" .. var
    end,
    5,
    { "hw.acpi.thermal.tz0.temperature", "dev.cpu.0.temperature"}
)

-- fanspeed --
local fanspeedwidget = wibox.widget.textbox()
vicious.register( fanspeedwidget,
    vicious.widgets.fanspeed,
    function(widget, args)
        local var = "<span color='yellow'>@</span>"
        --local var = "@"
        local speed = tonumber(args[1])
        if speed < 0 then
            return var .. "<span color='orange'>N/A</span> |"
        else
            if speed < 1500 then
                var = var .. "<span color='cyan'>"
            elseif speed < 2250 then
                var = var .. "<span color='yellow'>"
            elseif speed < 3000 then
                var = var .. "<span color='orange'>"
            else
                var = var .. "<span color='red'>"
            end
            return var .. speed .. "</span>RPM |"
        end
    end,
    5,
    -- no table support, yet
    "dev.acpi_ibm.0.fan_speed"
)

-- Memory usage
local memwidget = wibox.widget.textbox()
vicious.register( memwidget,
    vicious.widgets.mem,
    function(widget, args)
        local var=""
        if args[1] >= 75 then
            var = "<span color='red'>"
        elseif args[1] >= 50 then
            var = "<span color='orange'>"
        elseif args[1] >= 25 then
            var = "<span color='yellow'>"
        else
            var = "<span color='cyan'>"
        end
        -- show: "45% [48%,92%]" -> (active+inactive)[(buffered+wired)%,(used)%]
        var = "Mem:" .. var .. args[1] .. "% [" .. args[11] .. "," .. args[10] .. "]</span> |"
        return var
    end,
    5
)

local batwidget = wibox.widget.textbox()
vicious.register( batwidget,
    vicious.widgets.bat,
    function(widget, args)
        -- return: state, percent, time, rate
        var=args[2] .. "%" .. args[1] .. " (".. args[3] .. "|"  .. args[5] .. "W)</span>"
        if args[2] >= 90 then
            var = "<span color='cyan'>"  .. var
        elseif args[2] >= 50 then
            var = "<span color='lightgreen'>" .. var
        elseif args[2] >= 30 then
            var = "<span color='yellow'>" .. var
        elseif args[2] >= 15 then
            var = "<span color='orange'>" .. var
        else
            var = "<span color='red'>" .. var
        end
        return " Bat: " .. var .. " "
    end,
    10
)

-- ############## bringing it all together. at the top ##########
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock) -- @todo: this needs updating
    -- right_layout:add(speedometerwidget)
    right_layout:add(thermalwidget)
    right_layout:add(fanspeedwidget)
    right_layout:add(memwidget)
    right_layout:add(batwidget)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
