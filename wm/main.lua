--
-- Create the WindowManager controller
--

local WindowManager = require("WindowManager")
local wm = WindowManager:new()

--
-- Comment settings/tweekables. These will be handled automatically by WindowManager
-- 

wm.prefs.terminal = os.getenv("X_TERMINAL") or "xfce4-terminal"
wm.prefs.editor   = os.getenv("EDITOR") or "vim"
wm.prefs.modkey   = modkey
wm.prefs.theme    = "default"

local mymenu_awesome = {
  { "hotkeys", wm:show_hotkeys_screen() },
  { "manual", wm:x_terminal_cmd("man awesome") },
  { "edit config", wm:x_terminal_cmd(wm.prefs.editor .. " " .. awesome.conffile) },
  { "restart", awesome.restart },
  { "quit", wm.quit() },
}

wm.prefs.mainmenu = {
  { "awesome",       mymenu_awesome, wm.beautiful.awesome_icon },
  { "open terminal", terminal }
}

wm.prefs.tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

wm:set_theme()
wm:set_mainmenu()

-- Set default layouts and order
local layout_suit = wm.awful.layout.suit
wm:set_layouts({
    layout_suit.floating,
    layout_suit.tile,
    layout_suit.tile.left,
    layout_suit.tile.bottom,
    layout_suit.tile.top,
    layout_suit.fair,
    layout_suit.fair.horizontal,
    layout_suit.spiral,
    layout_suit.spiral.dwindle,
    layout_suit.max,
    layout_suit.max.fullscreen,
    layout_suit.magnifier,
    layout_suit.corner.nw,
    -- layout_suit.corner.ne,
    -- layout_suit.corner.sw,
    -- layout_suit.corner.se,
})

-- Standard awesome library
local gears = wm.gears
local autofocus = wm.autofocus
local awful = wm.awful

-- Widget and layout library
local wibox = wm.wibox

-- Theme handling library
local beautiful = wm.beautiful

-- Notification library
local naughty = wm.naughty
local menubar = wm.menubar
local hotkeys_popup = wm.hotkeys_popup

-- {{{ Menu
-- Create a launcher widget and a main menu



-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}



-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function() wm:set_wallpaper() end)

awful.screen.connect_for_each_screen(wm:default_screen_setup())
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () wm.mainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local function hide_all_wiboxes()
  for s in screen do
    s.mywibox.visible = not s.mywibox.visible
    if s.mybottomwibox then
      s.mybottomwibox.visible = not s.mybottomwibox.visible
    end
  end
end

local function history_go_back()
  return function()
    -- awful.client.focus.history.previous()
    wm.awful.client.focus.byidx(1)
    if client.focus then
      client.focus:raise()
    end
  end
end

local modkey        = {"Mod4"}
local modshift      = {"Mod4", "Shift"}
local modctrl       = {"Mod4", "Control"}
local modctrlshift  = {"Mod4", "Shift", "Control"}

-- {{{ Key bindings
globalkeys = gears.table.join(
  wm:key(modkey,   "b",      "custom",   "toggle wibox",                   hide_all_wiboxes),
  wm:key(modkey,   "Tab",    "custom",   "focus back in history",          history_go_back()),
  wm:key(modkey,   "s",      "awesome",  "show help",                      hotkeys_popup.show_help),
  wm:key(modkey,   "w",      "awesome",  "show main menu",                 function () mymainmenu:show() end),
  wm:key(modctrl,  "r",      "awesome",  "reload awesome",                 awesome.restart),
  wm:key(modshift, "q",      "awesome",  "quit awesome",                   awesome.quit),
  wm:key(modkey,   "x",      "awesome",  "lua execute prompt",             wm:awesome_lua_exec_prompt()),
  wm:key(modkey,   "j",      "client",   "focus next by index",            wm:client_focus_next()),
  wm:key(modkey,   "k",      "client",   "focus previous by index",        wm:client_focus_next()),
  wm:key(modkey,   "u",      "client",   "jump to urgent client",          awful.client.urgent.jumpto),
  wm:key(modshift, "j",      "client",   "swap with next client by index", function () awful.client.swap.byidx(  1) end),
  wm:key(modshift, "k",      "client",   "swap with prev client by index", function () awful.client.swap.byidx( -1) end),
  wm:key(modctrl,  "n",      "client",   "restore minimized",              wm:client_restore_minimized()),
  wm:key(modkey,   "l",      "layout",   "increase master width factor",   function () awful.tag.incmwfact( 0.05)          end),
  wm:key(modkey,   "h",      "layout",   "decrease master width factor",   function () awful.tag.incmwfact(-0.05)          end),
  wm:key(modshift, "h",      "layout",   "increase # of master clients",   function () awful.tag.incnmaster( 1, nil, true) end),
  wm:key(modshift, "l",      "layout",   "decrease # of master clients",   function () awful.tag.incnmaster(-1, nil, true) end),
  wm:key(modctrl,  "h",      "layout",   "increase # of columns",          function () awful.tag.incncol( 1, nil, true)    end),
  wm:key(modctrl,  "l",      "layout",   "decrease # of columns",          function () awful.tag.incncol(-1, nil, true)    end),
  wm:key(modkey,   "space",  "layout",   "select next",                    function () awful.layout.inc( 1)                end),
  wm:key(modshift, "space",  "layout",   "select previous",                function () awful.layout.inc(-1)                end),
  wm:key(modkey,   "Return", "launcher", "open a terminal",                function () awful.spawn(terminal) end ),
  wm:key(modkey,   "r",      "launcher", "run prompt",                     function () awful.screen.focused().mypromptbox:run() end),
  wm:key(modkey,   "p",      "launcher", "show the menubar",               function () menubar.show() end),
  wm:key(modctrl,  "j",      "screen",   "focus next screen",              function () awful.screen.focus_relative( 1) end),
  wm:key(modctrl,  "k",      "screen",   "focus prev screen",              function () awful.screen.focus_relative(-1) end),
  wm:key(modkey,   "Left",   "tag",      "view previous",                  awful.tag.viewprev),
  wm:key(modkey,   "Right",  "tag",      "view next",                      awful.tag.viewnext),
  wm:key(modkey,   "Escape", "tag",      "go back",                        awful.tag.history.restore)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = gears.table.join(
    globalkeys,
    wm:key(modkey,       "#" .. i + 9, "tag", "view tag #"..i,                       wm:screen_view_tag_idx(i)),
    wm:key(modctrl,      "#" .. i + 9, "tag", "toggle tag #"..i,                     wm:screen_toggle_tag_idx(i)),
    wm:key(modshift,     "#" .. i + 9, "tag", "move focused client to tag #"..i,     wm:screen_move_client_idx(i)),
    wm:key(modctrlshift, "#" .. i + 9, "tag", "toggle focused client on tag #" .. i, wm:screen_toggle_client_idx(i))
  )
end

clientkeys = gears.table.join(
  wm:key(modkey,   "f",      "client", "toggle fullscreen",         wm:client_toggle_fullscreen()),
  wm:key(modshift, "c",      "client", "close",                     function (c) c:kill() end),
  wm:key(modctrl,  "space",  "client", "toggle floating",           awful.client.floating.toggle),
  wm:key(modctrl,  "Return", "client", "move to master",            function (c) c:swap(awful.client.getmaster()) end),
  wm:key(modkey,   "o",      "client", "move to screen",            function (c) c:move_to_screen() end),
  wm:key(modkey,   "t",      "client", "toggle keep on top",        function (c) c.ontop = not c.ontop end),
  wm:key(modkey,   "n",      "client", "minimize",                  function (c) c.minimized = true end),
  wm:key(modkey,   "m",      "client", "(un)maximize",              wm:client_toggle_maximized()),
  wm:key(modctrl,  "m",      "client", "(un)maximize vertically",   wm:client_toggle_maximized_vert()),
  wm:key(modshift, "m",      "client", "(un)maximize horizontally", wm:client_toggle_maximized_horiz())
)

clientbuttons = gears.table.join(
  wm:button({}, 1, wm:client_activate()),
  wm:button(modkey, 1, wm:client_move()),
  wm:button(modkey, 3, wm:client_resize())
)

local modkey="Mod4"

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
