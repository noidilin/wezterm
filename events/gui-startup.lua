local wezterm = require('wezterm')
local mux = wezterm.mux
local platform = require('utils.platform')

local M = {}

M.setup = function()
   wezterm.on('gui-startup', function(cmd)
      local spawn_opts = cmd or {}

      if platform.is_mac then
         spawn_opts.workspace = 'main'
         spawn_opts.cwd = wezterm.home_dir
         spawn_opts.args = spawn_opts.args or { '/opt/homebrew/bin/nu', '-l' }
      end

      local _, _, window = mux.spawn_window(spawn_opts)
      window:gui_window():maximize()
   end)
end

return M
