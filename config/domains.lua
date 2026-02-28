local platform = require('utils.platform')
local custom = require('utils.custom')

local home_dir = custom.get('name.home_dir', 'noid')
local default_cwd = '/home/' .. home_dir
local linux_shell = custom.get('executable.default_shell.linux', 'nu')

local options = {
	-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
	ssh_domains = {},

	-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
	unix_domains = {},

	-- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
	wsl_domains = {
		{
			name = 'wsl.arch',
			distribution = 'archlinux',
			username = home_dir,
			default_cwd = default_cwd,
			default_prog = { linux_shell },
		},
	},
}

if platform.is_win then
	options.ssh_domains = {
		-- yazi's image preview on Windows will only work if launched via ssh from WSL
		{
			name = 'wsl.ssh',
			remote_address = 'localhost',
			multiplexing = 'None',
			default_cwd = default_cwd,
			default_prog = { linux_shell },
			assume_shell = 'Posix',
		},
	}
end

return options
