local wezterm = require('wezterm') ---@type Wezterm
local custom = require('utils.custom')

-- local font_family = 'Maple Mono Normal NF CN'
local font_family = custom.get('font.family', 'CommitMono Nerd Font Mono')
local font_size = custom.get_platform('font.size', 14)
local line_height = custom.get_platform('font.line_height', 1.3)
local half_intensity_font = {
	family = font_family,
	weight = 'DemiLight',
}

return {
	font = wezterm.font({ family = font_family }),
	font_rules = {
		{
			intensity = 'Half', -- if match this rule
			font = wezterm.font(half_intensity_font), -- apply this font
		},
	},
	font_size = font_size,
	line_height = line_height,
	command_palette_font = wezterm.font(font_family),
	command_palette_font_size = font_size,
	underline_position = '-2pt',

	--ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
	freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
	freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
