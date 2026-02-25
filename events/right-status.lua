local wezterm = require('wezterm')
local umath = require('utils.math')
local Cells = require('utils.cells')
local palette = require('utils.palette')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local memory_cache = {
	value = 'N/A',
	last_update_ms = 0,
}

local ICON_MEMORY = '󰍛'

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
   mem      = { fg = palette.mono12, bg = palette.mono02 },
   battery   = { fg = palette.mono12, bg = palette.mono02 },
}

local cells = Cells:new()

cells
	:add_segment('memory_icon', ICON_MEMORY .. ' ', colors.mem, attr(attr.intensity('Bold')))
	:add_segment('memory_text', '', colors.mem, attr(attr.intensity('Bold')))
	:add_segment('battery_icon', '', colors.battery)
	:add_segment('battery_text', '', colors.battery, attr(attr.intensity('Bold')))

---@return string
local function get_memory_usage()
	-- TODO: support WSL, Arch Linux, and Windows starship paths.
	local pcall_ok, ok, output, _ = pcall(wezterm.run_child_process, {
		'/opt/homebrew/bin/starship',
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
	wezterm.on('update-right-status', function(window, _pane)
		local battery_text, battery_icon = battery_info()
		refresh_memory_cache(window)

		cells
			:update_segment_text('memory_text', memory_cache.value)
			:update_segment_text('battery_icon', ' ' .. battery_icon)
			:update_segment_text('battery_text', battery_text .. ' ')

		window:set_right_status(
			wezterm.format(
				cells:render({ 'memory_icon', 'memory_text', 'battery_icon', 'battery_text' })
			)
		)
	end)
end

return M
