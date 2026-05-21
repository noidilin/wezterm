local wezterm = require('wezterm') ---@type Wezterm
local act = wezterm.action
local smart_splits = require('config.smart-splits')
local workspaces = require('config.workspaces')

local function clone_list(list)
	local out = {}
	for i = 1, #list do
		out[i] = list[i]
	end
	return out
end

-- stylua: ignore
local keys = {
  -- Remove default bindings
  { key = 'n',        mods = 'CTRL',          action = act.DisableDefaultAssignment },
  { key = 'h',        mods = 'CTRL',          action = act.DisableDefaultAssignment },
  { key = 'j',        mods = 'CTRL',          action = act.DisableDefaultAssignment },
  { key = 'k',        mods = 'CTRL',          action = act.DisableDefaultAssignment },
  { key = 'l',        mods = 'CTRL',          action = act.DisableDefaultAssignment },
  { key = 't',        mods = 'CTRL | SHIFT',  action = act.DisableDefaultAssignment },
  { key = 'w',        mods = 'CTRL | SHIFT',  action = act.DisableDefaultAssignment },

  -- HACK: resend space key stroke (https://github.com/wezterm/wezterm/issues/4055#issuecomment-1694542317)
  { key = 'Space',    mods = 'SHIFT',         action = act.SendKey({ key = 'Space', mods = 'SHIFT' }), },
  { key = 'Space',    mods = 'CTRL',          action = act.SendKey({ key = 'Space', mods = 'CTRL' }), },

  -- paste from the clipboard
  { key = 'V',        mods = 'CTRL|SHIFT',    action = act.PasteFrom 'Clipboard' },

  { key = 'F3',       mods = 'NONE',          action = act.ActivateCommandPalette },
  { key = 'F4',       mods = 'NONE',          action = act.ShowLauncherArgs({ flags = 'FUZZY|LAUNCH_MENU_ITEMS|DOMAINS' }) },
  { key = 'F5',       mods = 'NONE',          action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }), },
  { key = 'F6',       mods = 'NONE',          action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
  { key = 'F11',      mods = 'NONE',          action = act.ToggleFullScreen },
  { key = 'F12',      mods = 'NONE',          action = act.ShowDebugOverlay },
  -- { key = "phys:Space", mods = "LEADER",        action = act.ActivateCommandPalette },

  -- Send original key stroke when pressing leader key twice
  { key = 'q',        mods = 'LEADER | CTRL', action = act.SendKey({ key = 'q', mods = 'CTRL' }) },

  -- Scroll by half page
  { key = 'PageUp',   mods = 'SHIFT',         action = act.ScrollByPage(-0.5) },
  { key = 'PageDown', mods = 'SHIFT',         action = act.ScrollByPage(0.5) },

  -- Pane split
  { key = '-',        mods = 'LEADER',        action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = '\\',       mods = 'LEADER',        action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },

  -- Pane manipulate
  { key = 'x',        mods = 'LEADER',        action = act.CloseCurrentPane({ confirm = false }) },
  { key = 'z',        mods = 'LEADER',        action = act.TogglePaneZoomState },
  -- { key = 'o',        mods = 'LEADER',        action = act.RotatePanes("SwapWithActive") },
  { key = '!',        mods = 'LEADER|SHIFT',  action = wezterm.action_callback(function(_, pane)
    pane:move_to_new_window()
  end) },

  -- Pane resize
  { key = 'H',        mods = 'LEADER|SHIFT',  action = act.AdjustPaneSize({ 'Left', 5 }) },
  { key = 'J',        mods = 'LEADER|SHIFT',  action = act.AdjustPaneSize({ 'Down', 5 }) },
  { key = 'K',        mods = 'LEADER|SHIFT',  action = act.AdjustPaneSize({ 'Up', 5 }) },
  { key = 'L',        mods = 'LEADER|SHIFT',  action = act.AdjustPaneSize({ 'Right', 5 }) },

  -- Tab Manimupate
  { key = 'c',        mods = 'LEADER',        action = act.SpawnTab('CurrentPaneDomain') },
  { key = '&',        mods = 'LEADER|SHIFT',  action = act.CloseCurrentTab({ confirm = false }) },

  -- Adjust tab order
  { key = 'Tab',      mods = 'CTRL|SHIFT',    action = act.ActivateTabRelative(-1) },
  { key = 'Tab',      mods = 'CTRL',          action = act.ActivateTabRelative(1) },
  ---- Or shortcuts to move tab w/o move mode. SHIFT is for when caps lock is on
  { key = '<',        mods = 'LEADER|SHIFT',  action = act.MoveTabRelative(-1) },
  { key = '>',        mods = 'LEADER|SHIFT',  action = act.MoveTabRelative(1) },

  -- Key tables for move/resize/view/copy/mux
  { key = 'm',        mods = 'LEADER',        action = act.ActivateKeyTable({ name = 'move', one_shot = false }), },
  { key = 's',        mods = 'LEADER',        action = act.ActivateKeyTable({ name = 'resize', one_shot = false }), },
  { key = 'v',        mods = 'LEADER',        action = act.ActivateKeyTable({ name = 'view', one_shot = false }), },
  { key = 'y',        mods = 'LEADER',        action = act.ActivateCopyMode },
  { key = 'f',        mods = 'LEADER',        action = act.Search({ CaseInSensitiveString = '' }) },
  { key = 'w',        mods = 'LEADER',        action = act.ActivateKeyTable({ name = 'mux', one_shot = false }), },
}

for _, key in ipairs(smart_splits.keys()) do
	table.insert(keys, key)
end

for i = 1, 9 do
	table.insert(keys, {
		key = tostring(i),
		mods = 'LEADER',
		action = act.ActivateTab(i - 1),
	})
end

-- stylua: ignore
local copy_mode = clone_list(((wezterm.gui and wezterm.gui.default_key_tables) and wezterm.gui.default_key_tables().copy_mode) or {})
table.insert(copy_mode, { key = '/', action = act.Search({ CaseInSensitiveString = '' }) })
table.insert(
	copy_mode,
	{ key = 'q', mods = 'CTRL', action = act.CopyMode({ SetSelectionMode = 'Block' }) }
)

local key_tables = {
	resize = {
		{ key = 'h', action = act.AdjustPaneSize({ 'Left', 1 }) },
		{ key = 'j', action = act.AdjustPaneSize({ 'Down', 1 }) },
		{ key = 'k', action = act.AdjustPaneSize({ 'Up', 1 }) },
		{ key = 'l', action = act.AdjustPaneSize({ 'Right', 1 }) },
		{ key = 'Escape', action = 'PopKeyTable' },
		{ key = 'Enter', action = 'PopKeyTable' },
		{ key = 'q', action = 'PopKeyTable' },
	},
	move = {
		{ key = 'h', action = act.MoveTabRelative(-1) },
		{ key = 'j', action = act.MoveTabRelative(-1) },
		{ key = 'k', action = act.MoveTabRelative(1) },
		{ key = 'l', action = act.MoveTabRelative(1) },
		{ key = 'Escape', action = 'PopKeyTable' },
		{ key = 'Enter', action = 'PopKeyTable' },
		{ key = 'q', action = 'PopKeyTable' },
	},
	view = {
		{ key = 'k', action = act.ScrollByLine(-1) },
		{ key = 'j', action = act.ScrollByLine(1) },
		{ key = 'k', mods = 'SHIFT', action = act.ScrollByLine(-10) },
		{ key = 'j', mods = 'SHIFT', action = act.ScrollByLine(10) },
		{ key = 'u', action = act.ScrollByPage(-0.5) },
		{ key = 'd', action = act.ScrollByPage(0.5) },
		{ key = 'u', mods = 'SHIFT', action = act.ScrollByPage(-1) },
		{ key = 'd', mods = 'SHIFT', action = act.ScrollByPage(1) },
		{ key = 'Home', action = act.ScrollToTop },
		{ key = 'End', action = act.ScrollToBottom },
		{ key = 'Escape', action = 'PopKeyTable' },
		{ key = 'Enter', action = 'PopKeyTable' },
		{ key = 'q', action = 'PopKeyTable' },
	},
	copy_mode = copy_mode,
	mux = workspaces.key_table(),
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
	leader = { key = 'q', mods = 'CTRL', timeout_milliseconds = 3000 },
	keys = keys,
	key_tables = key_tables,
	mouse_bindings = mouse_bindings,
}
