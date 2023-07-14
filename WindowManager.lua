-- Meta class
local WindowManager = {}

-- Init tasks
require("error-handling")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Derived class method new
function WindowManager:new()
    local wm = {}
    setmetatable(wm, self)
    self.__index = self

    self.prefs = {}

    -- Standard libraries
    self.gears = require("gears")
    self.awful = require("awful")
    self.autofocus = require("awful.autofocus")

    -- Widget and layout library
    self.wibox = require("wibox")

    -- Theme handling library
    self.beautiful = require("beautiful")

    -- Notification library
    self.naughty = require("naughty")
    self.menubar = require("menubar")
    self.hotkeys_popup = require("awful.hotkeys_popup")

    -- Enable hotkeys help widget for VIM and other apps
    -- when client with a matching name is opened:
    require("awful.hotkeys_popup.keys")

    return wm
end

function WindowManager:set_theme(theme_name)
    local theme = theme_name or self.prefs.theme
    local beautiful = self.beautiful
    local gears = self.gears
    beautiful.init(gears.filesystem.get_themes_dir() .. theme .. "/theme.lua")
end

function WindowManager:set_layouts(layouts)
    local awful = self.awful
    -- Table of layouts to cover with awful.layout.inc, order matters.
    awful.layout.layouts = layouts   
end

function WindowManager:set_mainmenu(menuarg)
  local mainmenu = menuarg or self.prefs.mainmenu
  self.mainmenu = self.awful.menu({items=mainmenu})
end

-- TODO: add means of overriding with a hook
function WindowManager:set_wallpaper(screen)

  -- Wallpaper
  local wallpaper
  if self.prefs.wallpaper then
    wallpaper = self.prefs.wallpaper
  elseif self.beautiful.wallpaper then
    wallpaper = self.beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(screen)
    end
  end
  self.gears.wallpaper.maximized(wallpaper, screen, true)
end

--
-- Event callbacks and such
--

function WindowManager:x_terminal_cmd(cmd)
    if cmd then 
        -- TODO: safe escape this
        return self.prefs.terminal .. " -e '" .. cmd .. "'"
    else
        return self.prefs.terminal
    end
end

function WindowManager:show_hotkeys_screen()
  return function() 
    self.hotkeys_popup.show_help(nil, self.awful.screen.focused())
  end
end

function WindowManager:quit()
  return function()
    awesome.quit()
  end
end

function WindowManager:taglist_view_only()
  return function(t)
    t:view_only()
  end
end

function WindowManager:taglist_move_to()
  return function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end
end

function WindowManager:taglist_focus_toggle()
  return function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end
end

function WindowManager:taglist_viewnext()
  return function(t)
    self.awful.tag.viewnext(t.screen)
  end
end

function WindowManager:taglist_viewprev()
  return function(t)
    self.awful.tag.viewprev(t.screen)
  end
end

function WindowManager:tasklist_minimize_or_activate()
  return function(c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal(
        "request::activate",
        "tasklist",
        {raise = true}
      )
    end
  end
end

function WindowManager:tasklist_show_client_list()
  return function(c)
    self.awful.menu.client_list({ theme = { width = 250 } })
  end
end

function WindowManager:tasklist_focus_next()
  return function(c)
    self.awful.client.focus.byidx(1)
  end
end

function WindowManager:tasklist_focus_prev()
  return function(c)
    self.awful.client.focus.byidx(-1)
  end
end

function WindowManager:client_focus_next()
  return function()
    self.awful.client.focus.byidx( 1)
  end
end

function WindowManager:client_focus_prev()
  return function()
    self.awful.client.focus.byidx(-1)
  end
end

--function WindowManager:client_go_back()
--
--end

function WindowManager:client_restore_minimized()
  return function()
    local c = self.awful.client.restore()
    -- Focus restored client
    if c then
      c:emit_signal(
        "request::activate", "key.unminimize", {raise = true}
      )
    end
  end
end

function WindowManager:client_toggle_fullscreen()
  return function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end
end

function WindowManager:client_toggle_maximized()
  return function(c)
    c.maximized = not c.maximized
    c:raise()
  end
end

function WindowManager:client_toggle_maximized_vert()
  return function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end
end

function WindowManager:client_toggle_maximized_horiz()
  return function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end
end

function WindowManager:awesome_lua_exec_prompt()
  return function()
    self.awful.prompt.run {
      prompt       = "Run Lua code: ",
      textbox      = awful.screen.focused().mypromptbox.widget,
      exe_callback = awful.util.eval,
      history_path = awful.util.get_cache_dir() .. "/history_eval"
    }
  end
end

function WindowManager:screen_view_tag_idx(idx)
  return function()
    local screen = awful.screen.focused()
    local tag = screen.tags[idx]
    if tag then
      tag:view_only()
    end
  end
end

function WindowManager:screen_toggle_tag_idx(idx)
  return function()
    local screen = awful.screen.focused()
    local tag = screen.tags[idx]
    if tag then
      awful.tag.viewtoggle(tag)
    end
  end
end

function WindowManager:screen_move_client_idx(idx)
  return function()
    if client.focus then
      local tag = client.focus.screen.tags[idx]
      if tag then
        client.focus:move_to_tag(tag)
      end
    end
  end
end

function WindowManager:screen_toggle_client_idx(idx)
  return function()
    if client.focus then
      local tag = client.focus.screen.tags[idx]
      if tag then
        client.focus:toggle_tag(tag)
      end
    end
  end
end


function WindowManager:default_screen_setup()
  return function(s)

    mylauncher = self.awful.widget.launcher({ image = self.beautiful.awesome_icon,
                                         menu = self.mainmenu })
    -- Keyboard map indicator and switcher
    mykeyboardlayout = self.awful.widget.keyboardlayout()

    -- {{{ Wibar
    -- Create a textclock widget
    mytextclock = self.wibox.widget.textclock()

    -- Create a wibox for each screen and add it
    local taglist_buttons = self.gears.table.join(
      self.awful.button({ },        1, self:taglist_view_only() ),
      self.awful.button({ modkey }, 1, self:taglist_move_to() ),
      self.awful.button({ },        3, self.awful.tag.viewtoggle),
      self.awful.button({ modkey }, 3, self:taglist_focus_toggle()),
      self.awful.button({ },        4, self:taglist_viewnext()),
      self.awful.button({ },        5, self:taglist_viewprev())
    )

    local tasklist_buttons = self.gears.table.join(
      self.awful.button({ }, 1, self:tasklist_minimize_or_activate()),
      self.awful.button({ }, 3, self:tasklist_show_client_list()),
      self.awful.button({ }, 4, self:tasklist_focus_next()),
      self.awful.button({ }, 5, self:tasklist_focus_prev())
    )

    -- Wallpaper
    self:set_wallpaper(s)

    -- Each screen has its own tag table.
    self.awful.tag(self.prefs.tags, s, self.awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = self.awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = self.awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(self.gears.table.join(
                            self.awful.button({ }, 1, function () self.awful.layout.inc( 1) end),
                            self.awful.button({ }, 3, function () self.awful.layout.inc(-1) end),
                            self.awful.button({ }, 4, function () self.awful.layout.inc( 1) end),
                            self.awful.button({ }, 5, function () self.awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = self.awful.widget.taglist {
      screen  = s,
      filter  = self.awful.widget.taglist.filter.all,
      buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = self.awful.widget.tasklist {
      screen  = s,
      filter  = self.awful.widget.tasklist.filter.currenttags,
      buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = self.awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
      layout = self.wibox.layout.align.horizontal,
      { -- Left widgets
        layout = self.wibox.layout.fixed.horizontal,
        mylauncher,
        s.mytaglist,
        s.mypromptbox,
      },
      s.mytasklist, -- Middle widget
      { -- Right widgets
        layout = self.wibox.layout.fixed.horizontal,
        mykeyboardlayout,
        self.wibox.widget.systray(),
        mytextclock,
        s.mylayoutbox,
      },
    }
  end
end

function WindowManager:client_activate()
  return function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
  end
end

function WindowManager:client_move()
  return function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    self.awful.mouse.client.move(c)
  end
end

function WindowManager:client_resize()
  return function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    self.awful.mouse.client.resize(c)
  end
end


function WindowManager:key(mods, keycode, groupstr, desc, func)
  return self.awful.key(mods, keycode, func, {description=desc, group=groupstr})
end

function WindowManager:button(mods, buttonid, func)
  return self.awful.button(mods, buttonid, func)
end

return WindowManager
