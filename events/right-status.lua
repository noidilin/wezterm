local wezterm = require('wezterm') ---@type Wezterm
local umath = require('utils.math')
local Cells = require('utils.cells')
local custom = require('utils.custom')
local palette = require('utils.palette')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local memory_cache = {
	value = 'N/A',
	last_update_ms = 0,
}

local ICON_MEMORY = '󰍛'
local ICON_WORKTREE = nf.dev_git_branch or ''
local starship_executable = custom.get_platform('executable.starship', 'starship')

---@type string[]
local discharging_icons = {
	nf.md_battery_10,
	nf.md_battery_20,
	nf.md_battery_30,
	nf.md_battery_40,
	nf.md_battery_50,
	nf.md_battery_60,
	nf.md_battery_70,
	nf.md_battery_80,
	nf.md_battery_90,
	nf.md_battery,
}
---@type string[]
local charging_icons = {
	nf.md_battery_charging_10,
	nf.md_battery_charging_20,
	nf.md_battery_charging_30,
	nf.md_battery_charging_40,
	nf.md_battery_charging_50,
	nf.md_battery_charging_60,
	nf.md_battery_charging_70,
	nf.md_battery_charging_80,
	nf.md_battery_charging_90,
	nf.md_battery_charging,
}

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
   worktree  = { fg = palette.mono12, bg = palette.mono02 },
   mem      = { fg = palette.mono12, bg = palette.mono02 },
   battery   = { fg = palette.mono12, bg = palette.mono02 },
}

local cells = Cells:new()

cells
	:add_segment('worktree_icon', '', colors.worktree, attr(attr.intensity('Bold')))
	:add_segment('worktree_text', '', colors.worktree, attr(attr.intensity('Bold')))
	:add_segment('memory_icon', ICON_MEMORY .. ' ', colors.mem, attr(attr.intensity('Bold')))
	:add_segment('memory_text', '', colors.mem, attr(attr.intensity('Bold')))
	:add_segment('battery_icon', '', colors.battery)
	:add_segment('battery_text', '', colors.battery, attr(attr.intensity('Bold')))

---@param text string
---@param max_len number
---@return string
local function truncate(text, max_len)
	if #text <= max_len then
		return text
	end
	return text:sub(1, max_len - 3) .. '...'
end

---@param path string
---@return string
local function basename(path)
	local normalized = (path or ''):gsub('\\', '/'):gsub('/+$', '')
	return normalized:match('([^/]+)$') or normalized
end

---@param value string
---@return string
local function decode_percent_encoded(value)
	return value:gsub('%%(%x%x)', function(hex)
		return string.char(tonumber(hex, 16))
	end)
end

---@param pane Pane
---@return string
local function resolve_worktree_name(pane)
	local ok, cwd = pcall(function()
		return pane:get_current_working_dir()
	end)

	if not ok or cwd == nil then
		return ''
	end

	local path = ''
	if type(cwd) == 'string' then
		path = cwd
	elseif type(cwd) == 'userdata' or type(cwd) == 'table' then
		path = cwd.file_path or cwd.path or tostring(cwd)
	else
		path = tostring(cwd)
	end

	if path == '' then
		return ''
	end

	path = decode_percent_encoded(path)
	path = path:gsub('^file://[^/]*', '')

	local leaf = basename(path)
	if leaf == '' then
		return ''
	end

	local worktree = leaf:match('^[^%.]+%.(.+)$')
	if not worktree or worktree == '' then
		return ''
	end

	return truncate(worktree, 25)
end

---@return string
local function get_memory_usage()
	local pcall_ok, ok, output, _ = pcall(wezterm.run_child_process, {
		starship_executable,
		'module',
		'memory_usage',
	})

	if not pcall_ok or not ok or not output then
		return 'N/A'
	end

	local cleaned = output:gsub('\27%[[0-9;]*m', ''):match('^%s*(.-)%s*$')
	if cleaned == nil or cleaned == '' then
		return 'N/A'
	end

	return cleaned
end

---@param window Window
---@return boolean
local function memory_cache_is_stale(window)
	local now_ms = os.time() * 1000
	local interval_ms = window:effective_config().status_update_interval
	return (now_ms - memory_cache.last_update_ms) >= interval_ms
end

---@param window Window
local function refresh_memory_cache(window)
	if not memory_cache_is_stale(window) then
		return
	end

	memory_cache.value = get_memory_usage()
	memory_cache.last_update_ms = os.time() * 1000
end

---@return string, string
local function battery_info()
	-- ref: https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html

	local charge = ''
	local icon = ''

	for _, b in ipairs(wezterm.battery_info()) do
		local idx = umath.clamp(umath.round(b.state_of_charge * 10), 1, 10)
		charge = string.format('%.0f%%', b.state_of_charge * 100)

		if b.state == 'Charging' then
			icon = charging_icons[idx]
		else
			icon = discharging_icons[idx]
		end
	end

	return charge, icon .. ' '
end

M.setup = function()
	wezterm.on('update-right-status', function(window, pane)
		local battery_text, battery_icon = battery_info()
		local worktree = resolve_worktree_name(pane)
		local show_worktree = worktree ~= ''
		refresh_memory_cache(window)

		cells
			:update_segment_text(
				'worktree_icon',
				show_worktree and (' ' .. ICON_WORKTREE .. ' ') or ''
			)
			:update_segment_text('worktree_text', show_worktree and worktree .. ' ' or '')
			:update_segment_text('memory_text', memory_cache.value)
			:update_segment_text('battery_icon', ' ' .. battery_icon)
			:update_segment_text('battery_text', battery_text .. ' ')

		window:set_right_status(wezterm.format(cells:render({
			'worktree_icon',
			'worktree_text',
			'memory_icon',
			'memory_text',
			'battery_icon',
			'battery_text',
		})))
	end)
end

return M
