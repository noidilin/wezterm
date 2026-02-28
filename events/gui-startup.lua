local wezterm = require('wezterm') ---@type Wezterm
local mux = wezterm.mux
local platform = require('utils.platform')
local custom = require('utils.custom')

local M = {}

M.setup = function()
	wezterm.on('gui-startup', function(cmd)
		local spawn_opts = cmd or {}
		local workspace = custom.get('name.workspace', 'main')
		local default_shell = custom.get_platform('executable.default_shell', '/opt/homebrew/bin/nu')

		if platform.is_mac then
			spawn_opts.workspace = workspace
			spawn_opts.cwd = wezterm.home_dir
			spawn_opts.args = spawn_opts.args or { default_shell, '-l' }
		end

		local _, _, window = mux.spawn_window(spawn_opts)
		window:gui_window():maximize()
	end)
end

return M
