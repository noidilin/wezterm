local platform = require('utils.platform')
local custom = require('utils.custom')

local ssh_user = custom.get('name.ssh_user', 'noid')
local wsl_user = custom.get('name.wsl_user', ssh_user)
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
			username = wsl_user,
			default_cwd = '/home/' .. wsl_user,
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
			default_cwd = '/home/' .. ssh_user,
			default_prog = { linux_shell },
			assume_shell = 'Posix',
		},
	}
end

return options
