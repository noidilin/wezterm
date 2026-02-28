local platform = require('utils.platform')
local custom = require('utils.custom')

local default_shell = custom.get_platform('executable.default_shell', 'nu')

local options = {
	default_prog = {},
	launch_menu = {},
}

if platform.is_win then
	options.default_prog = { default_shell }
	options.launch_menu = {
		{ label = 'wsl arch', domain = { DomainName = 'wsl.arch' } },
		{ label = 'nu', args = { 'nu' } },
		{ label = 'pwsh', args = { 'pwsh', '-NoLogo' } },
		{ label = 'cmd', args = { 'cmd' } },
		{ label = 'powershell', args = { 'powershell' } },
	}
elseif platform.is_mac then
	options.default_prog = { default_shell, '-l' }
	options.launch_menu = {
		{ label = 'bash', args = { 'bash', '-l' } },
		{ label = 'fish', args = { '/opt/homebrew/bin/fish', '-l' } },
		{ label = 'nu', args = { '/opt/homebrew/bin/nu', '-l' } },
		{ label = 'zsh', args = { 'zsh', '-l' } },
	}
elseif platform.is_linux then
	options.default_prog = { default_shell, '-l' }
	options.launch_menu = {
		{ label = 'bash', args = { 'bash', '-l' } },
		{ label = 'fish', args = { 'fish', '-l' } },
		{ label = 'zsh', args = { 'zsh', '-l' } },
	}
end

return options
