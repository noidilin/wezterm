local wezterm = require('wezterm')
local act = wezterm.action

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

-- stylua: ignore
local keys = {
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

   -- HACK: resend space key stroke (https://github.com/wezterm/wezterm/issues/4055#issuecomment-1694542317)
   { key = 'Space', mods = 'SHIFT', action = act.SendKey({ key = 'Space', mods = 'SHIFT' }), },
   { key = 'Space', mods = 'CTRL', action = act.SendKey({ key = 'Space', mods = 'CTRL' }), },

   { key = 'F1', mods = 'NONE', action = act.ActivateCopyMode },
   { key = 'F3', mods = 'NONE', action = act.ActivateCommandPalette },
   { key = 'F4', mods = 'NONE', action = act.ShowLauncher },
   { key = 'F5', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   {
      key = 'F6',
      mods = 'NONE',
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
   },
   { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
   { key = 'F12', mods = 'NONE', action = act.ShowDebugOverlay },
   -- { key = "phys:Space", mods = "LEADER",        action = act.ActivateCommandPalette },

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

for i = 1, 9 do
   table.insert(keys, {
      key = tostring(i),
      mods = 'LEADER',
      action = act.ActivateTab(i - 1),
   })
end

-- stylua: ignore
local key_tables = {
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

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   -- disable_default_mouse_bindings = true,
   leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 3000 },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
