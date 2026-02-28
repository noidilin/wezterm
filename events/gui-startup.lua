local wezterm = require('wezterm') ---@type Wezterm
local mux = wezterm.mux
local custom = require('utils.custom')

local M = {}

M.setup = function()
	wezterm.on('gui-startup', function(cmd)
		local spawn_opts = cmd or {}
		local workspace = custom.get('name.workspace', 'main')

		spawn_opts.workspace = spawn_opts.workspace or workspace

		if spawn_opts.cwd == nil and spawn_opts.domain == nil then
			spawn_opts.cwd = wezterm.home_dir
		end

		local _, _, window = mux.spawn_window(spawn_opts)
		window:gui_window():maximize()
	end)
end

return M
