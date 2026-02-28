return {
	name = {
		status_label = 'noid',
		ssh_user = 'noid',
		wsl_user = 'noid',
		workspace = 'main',
	},

	executable = {
		default_shell = {
			windows = 'nu',
			mac = '/opt/homebrew/bin/nu',
			linux = 'fish',
		},
		starship = {
			windows = 'starship',
			mac = '/opt/homebrew/bin/starship',
			linux = 'starship',
		},
	},

	font = {
		family = 'CommitMono Nerd Font Mono',
		size = {
			windows = 12.5,
			mac = 14,
			linux = 14,
		},
		line_height = {
			windows = 1.5,
			mac = 1.3,
			linux = 1.3,
		},
	},
}
