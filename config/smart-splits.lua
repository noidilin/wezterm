local wezterm = require('wezterm') ---@type Wezterm

local M = {}

local direction_keys = {
	h = 'Left',
	j = 'Down',
	k = 'Up',
	l = 'Right',
}

---@param pane Pane
---@return boolean
local function is_vim(pane)
	-- This is set by smart-splits.nvim and unset on ExitPre in Neovim.
	return pane:get_user_vars().IS_NVIM == 'true'
end

---@param resize_or_move 'resize'|'move'
---@param key string
---@return table
local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == 'resize' and 'META' or 'CTRL',
		action = wezterm.action_callback(function(window, pane)
			if is_vim(pane) then
				window:perform_action({
					SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
				}, pane)
			elseif resize_or_move == 'resize' then
				window:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
			else
				window:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
			end
		end),
	}
end

---@return table[]
function M.keys()
	return {
		split_nav('move', 'h'),
		split_nav('move', 'j'),
		split_nav('move', 'k'),
		split_nav('move', 'l'),
		split_nav('resize', 'h'),
		split_nav('resize', 'j'),
		split_nav('resize', 'k'),
		split_nav('resize', 'l'),
	}
end

return M
