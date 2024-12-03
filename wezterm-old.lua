-- setup shell program
local shell = { 'pwsh' }

local platform = require('utils.platform')
if platform.is_win then
   shell = { 'nu' }
elseif platform.is_mac then
   shell = { 'zsh' }
end

-- pull in the wezterm api
local wezterm = require('wezterm')
local act = wezterm.action
local is_dark = true

-- event
require('events.right-status').setup()
require('events.left-status').setup()
require('events.tab-title').setup()
require('events.new-tab-button').setup()

-- Load GPU adapters
local gpu_adapters = require('utils.gpu_adapter')

-- [[ Neovim: smart-splits ]]
---- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
   -- this is set by the plugin, and unset on ExitPre in Neovim
   return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
   h = 'Left',
   j = 'Down',
   k = 'Up',
   l = 'Right',
}

local function split_nav(resize_or_move, key)
   return {
      key = key,
      mods = resize_or_move == 'resize' and 'META' or 'CTRL',
      action = wezterm.action_callback(function(win, pane)
         if is_vim(pane) then
            -- pass the keys through to vim/nvim
            win:perform_action({
               SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
            }, pane)
         else
            if resize_or_move == 'resize' then
               win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
            else
               win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
            end
         end
      end),
   }
end

-- configuration
local config = wezterm.config_builder()

config.colors = {
   foreground = '#b3b3b3',
   background = '#191919',
   cursor_bg = '#878787',
   selection_bg = '#303030',
   -- order: black > red > green > yellow > blue > magenta > cyan > white
   ansi = { '#474747', '#b07878', '#778777', '#d6caab', '#7d96ad', '#797994', '#769494', '#dad5c8' },
   brights = {
      '#5d5d5d',
      '#cc9393',
      '#9bb09b',
      '#ebd6b7',
      '#9db2cf',
      '#9f9fbd',
      '#92b3b3',
      '#faf5eb',
   },
   -- further customization
   cursor_border = '#878787',
   selection_fg = '#8e8e8e',
   cursor_fg = '#eaeaea',
   scrollbar_thumb = '#4e4e4e',

   tab_bar = {
      -- The color of the strip that goes along the top of the window
      -- (does not apply when fancy tab bar is in use)
      background = '#191919',
      active_tab = {
         bg_color = '#242424', -- background color
         fg_color = '#9d9d9d', -- text color
         intensity = 'Bold', -- default is "Normal" (options: "Half", "Normal" or "Bold")
         underline = 'Single', -- default is "None" (options: "None", "Single" or "Double")
         italic = false, -- default is false
         strikethrough = false, -- default is false
      },

      --[[ inactive_tab = { -- same options as `active_tab` section
			bg_color = "#191919",
			fg_color = "#4e4e4e",
			italic = true,
		}, ]]

      --[[ inactive_tab_hover = { -- same options as `active_tab` section
			bg_color = "#191919",
			fg_color = "#5d5d5d",
			italic = true,
		}, ]]

      new_tab = { -- same options as `active_tab` section
         bg_color = '#191919',
         fg_color = '#4e4e4e',
      },

      new_tab_hover = { -- same options as `active_tab` section
         bg_color = '#191919',
         fg_color = '#5d5d5d',
      },
   },
}

-- config.freetype_load_flags = "NO_HINTING"
config.font = wezterm.font_with_fallback({
   'CommitMono Nerd Font Mono',
   'Fira Code',
   'JetBrains Mono',
})
config.font_size = 12.5
config.line_height = 1.5

config.window_decorations = 'RESIZE'
config.window_padding = {
   left = 10,
   right = 10,
   top = 10,
   bottom = 10,
}

-- config.window_background_opacity = 1
-- config.macos_window_background_blur = 8

-- Cursor
config.animation_fps = 60
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 700

-- Dim inactive panes
config.inactive_pane_hsb = {
   saturation = 0.1,
   brightness = is_dark and 0.8 or 0.95,
}

-- Wezterm
config.set_environment_variables = { TERMINAL = 'WezTerm' }
config.enable_scroll_bar = false
config.visual_bell = {
   fade_in_duration_ms = 75,
   fade_out_duration_ms = 75,
   target = 'CursorColor',
}

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_max_width = 20
config.show_tab_index_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true

-- Engine
config.default_prog = shell
config.automatically_reload_config = true
config.pane_focus_follows_mouse = false
config.window_close_confirmation = 'NeverPrompt'
config.scrollback_lines = 3000
config.default_workspace = 'main'
-- config.win32_system_backdrop = "Acrylic" -- Auto, Disabled, Acrylic, Mica, Tabbed

-- Render
config.max_fps = 60
config.front_end = 'WebGpu' -- OpenGL, WebGpu, Software
config.webgpu_power_preference = 'HighPerformance'
config.webgpu_preferred_adapter = gpu_adapters:pick_best()

-- Keys
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 3000 }
config.keys = {
   -- Remove default bindings
   { key = 'n', mods = 'CTRL', action = act.DisableDefaultAssignment },
   -- { key = "Space", mods = "CTRL",         action = act.DisableDefaultAssignment },
   -- { key = "Space", mods = "SHIFT",        action = act.DisableDefaultAssignment },
   { key = 'h', mods = 'CTRL', action = act.DisableDefaultAssignment },
   { key = 'j', mods = 'CTRL', action = act.DisableDefaultAssignment },
   { key = 'k', mods = 'CTRL', action = act.DisableDefaultAssignment },
   { key = 'l', mods = 'CTRL', action = act.DisableDefaultAssignment },
   { key = 't', mods = 'CTRL | SHIFT', action = act.DisableDefaultAssignment },
   { key = 'w', mods = 'CTRL | SHIFT', action = act.DisableDefaultAssignment },

   -- Fix Space Key
   {
      key = 'Space',
      mods = 'SHIFT',
      action = wezterm.action.SendKey({ key = '\\', mods = 'CTRL' }),
   },

   -- Copy Mode
   { key = 'F1', mods = '', action = wezterm.action.ActivateCopyMode },
   -- Window
   { key = 'F11', mods = '', action = wezterm.action.ToggleFullScreen },
   -- command palette
   -- { key = "phys:Space", mods = "LEADER",        action = act.ActivateCommandPalette },
   { key = 'F3', mods = '', action = act.ActivateCommandPalette },

   -- workspace
   { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },

   -- Send C-a when pressing C-a twice
   { key = 'a', mods = 'LEADER | CTRL', action = act.SendKey({ key = 'a', mods = 'CTRL' }) },

   -- Pane split
   { key = '-', mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
   { key = '\\', mods = 'LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },

   -- Pane manipulate
   { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane({ confirm = false }) },
   { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
   { key = 'o', mods = 'LEADER', action = act.RotatePanes('Clockwise') },

   -- Pane resize
   { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize({ 'Left', 5 }) },
   { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize({ 'Down', 5 }) },
   { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize({ 'Up', 5 }) },
   { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize({ 'Right', 5 }) },

   -- Tab Manimupate
   { key = 'c', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
   { key = '&', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab({ confirm = false }) },

   -- Adjust tab order
   { key = '[', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
   { key = ']', mods = 'LEADER', action = act.ActivateTabRelative(1) },
   { key = 'n', mods = 'LEADER', action = act.ShowTabNavigator },
   ---- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
   { key = '<', mods = 'LEADER|SHIFT', action = act.MoveTabRelative(-1) },
   { key = '>', mods = 'LEADER|SHIFT', action = act.MoveTabRelative(1) },

   -- Key table for moving tabs and resize pane
   {
      key = 'm',
      mods = 'LEADER',
      action = act.ActivateKeyTable({ name = 'move_tab', one_shot = false }),
   },
   {
      key = 's',
      mods = 'LEADER',
      action = act.ActivateKeyTable({ name = 'resize_pane', one_shot = false }),
   },

   -- smart-splits
   ---- move between split panes
   split_nav('move', 'h'),
   split_nav('move', 'j'),
   split_nav('move', 'k'),
   split_nav('move', 'l'),
   ---- resize panes
   split_nav('resize', 'h'),
   split_nav('resize', 'j'),
   split_nav('resize', 'k'),
   split_nav('resize', 'l'),
}

-- Navigate tab with LEADER + 1-9
for i = 1, 9 do
   table.insert(config.keys, {
      key = tostring(i),
      mods = 'LEADER',
      action = act.ActivateTab(i - 1),
   })
end

config.key_tables = {
   resize_pane = {
      { key = 'h', action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'j', action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'k', action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'l', action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'Enter', action = 'PopKeyTable' },
   },
   move_tab = {
      { key = 'h', action = act.MoveTabRelative(-1) },
      { key = 'j', action = act.MoveTabRelative(-1) },
      { key = 'k', action = act.MoveTabRelative(1) },
      { key = 'l', action = act.MoveTabRelative(1) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'Enter', action = 'PopKeyTable' },
   },
}

-- and finally, return the configuration to wezterm
return config
