-- @todo-reminder
--  some of the used functions/calls seems to be obsolete.
--  check if this can be updated before it breaks

-- Key bindings --
config.keys = { }

config.keys.global = awful.util.table.join(
    -- next/pre tag (aka. workspace)
    awful.key({ altkey,           }, "e", awful.tag.viewnext ),
    awful.key({ altkey,           }, "t", awful.tag.viewprev ),

    -- focus you fack
    awful.key({ altkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            --if client.focus and client.isfloating then client.focus:raise() end
            if client.focus then client.focus:raise() end
        end
    ),
    awful.key( { altkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end
    ),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then client.focus:raise() end
        end
    ),

    -- Layout manipulation --
    -- in/decrease position for window
    awful.key({ modkey,           }, "Return", function () awful.client.swap.byidx(  1) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.client.swap.byidx( -1) end),

    -- laoyut switching --
    awful.key({ modkey,           }, "space", function () awful.layout.inc(config.layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(config.layouts, -1) end),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore), -- jump to last used tag
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto), -- jump to tag with hilight

    -- client manipulation --
    awful.key({ altkey, "Shift"   }, "f",       awful.client.floating.toggle),
    awful.key({ altkey, "Control", "Shift"   }, "k",
        function()
            local c = client.focus
            if c then c:kill() end
        end
    ),
    awful.key({ altkey, "Shift"   }, "m",
        function ()
            local c = client.focus
            if c then c.fullscreen = not c.fullscreen end
        end
    ),
    -- warp windows @todo: refine for tripple-monitor-setup
    awful.key({ altkey, "Control" }, "o", awful.client.movetoscreen),

    -- warp mouse (to screen +/- current one) [not tested with tripple monitor setup]
    awful.key({ altkey,           }, "o", function () awful.screen.focus_relative( 1) end),
    awful.key({ altkey, "Shift"   }, "o", function () awful.screen.focus_relative(-1) end),

    -- show awesome menu
    awful.key({ modkey,           }, "m", function () mymainmenu:show() end),
    -- use dmenu as Menubar
    awful.key({ altkey, "Shift" }, "p", function() awful.util.spawn( "dmenu_run" ) end),

    -- keys with unkown function
    --awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- does this even work? -> nope @tofix
    awful.key({ modkey,           }, "h", function () awful.tag.incmwfact( 0.05) end),
    awful.key({ modkey,           }, "l", function () awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster( 1)   end),
    awful.key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1)   end),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1)      end),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1)      end),



    -- assorted shortcuts --
    -- keyboard-layout switcher
    awful.key({ altkey, "Shift" }, "F8", function() awful.util.spawn( "/home/andy/scripte/keyboard_settings.sh") end),
    -- lockscreen
    awful.key({ altkey, "Control" }, "Return", function() awful.util.spawn( "/home/andy/scripte/lock_it.sh") end),
    -- volume slider
    awful.key({ altkey,           }, "Up",   function() awful.util.spawn( "/home/andy/scripte/osd_volume.sh +") end),
    awful.key({ altkey,           }, "Down", function() awful.util.spawn( "/home/andy/scripte/osd_volume.sh -") end),
    -- standard programs
    awful.key({ altkey,           }, "u", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift", "Control" }, "q", awesome.quit)
)
-- end config.keys.global --

-- ##########################
-- # spoilerspace:
-- # shortcuts, who may come in handy some day.
-- # implement as necessary
-- ####
-- Prompt
-- awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

-- awful.key({ modkey }, "x",
--           function ()
--               awful.prompt.run({ prompt = "Run Lua code: " },
--               mypromptbox[mouse.screen].widget,
--               awful.util.eval, nil,
--               awful.util.getdir("cache") .. "/history_eval")
--           end),

--  awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
--  awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
--  awful.key({ modkey,           }, "n",
--      function (c)
--          -- The client currently has the input focus, so it cannot be
--          -- minimized, since minimized clients can't have the focus.
--          c.minimized = true
--      end),
--  awful.key({ modkey,           }, "m",
--      function (c)
--          c.maximized_horizontal = not c.maximized_horizontal
--          c.maximized_vertical   = not c.maximized_vertical
--      end)
-- )

-- ########################
-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    config.keys.global = awful.util.table.join(
        config.keys.global,
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewonly(tag)
                end
            end
        ),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end
        ),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                local tag = awful.tag.gettags(client.focus.screen)[i]
                if client.focus and tag then
                    awful.client.toggletag(tag)
                end
            end
        )
    )
end


-- ##################
-- client mouse events
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ altkey }, 1, awful.mouse.client.move),
    awful.button({ altkey }, 3, awful.mouse.client.resize)
)

-- root window --
-- this seems a bit broken
root.buttons( awful.util.table.join(
                  -- Mouse bindings --
                  awful.button({ }, 3, function () mymainmenu:toggle() end),
                  awful.button({ }, 4, awful.tag.viewnext),
                  awful.button({ }, 5, awful.tag.viewprev)
                                   )
)

-- finally, announce previously defined keys
root.keys(config.keys.global)
