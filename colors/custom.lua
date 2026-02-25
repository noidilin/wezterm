local palette = require('colors._palette')

local scheme_name = 'achroma'

local scheme = {
	foreground = palette.mono21,
	background = palette.mono02,
	compose_cursor = palette.mono19,
	cursor_fg = palette.mono25,
	cursor_bg = palette.mono17,
	cursor_border = palette.mono17,
	selection_bg = palette.mono06,
	selection_fg = palette.mono19,

	-- order: black > red > green > yellow > blue > magenta > cyan > white
	ansi = {
		palette.mono10,
		palette.red00,
		palette.green00,
		palette.yellow00,
		palette.blue00,
		palette.magenta00,
		palette.cyan00,
		palette.acc07,
	},
	brights = {
		palette.mono13,
		palette.red01,
		palette.green01,
		palette.yellow01,
		palette.blue01,
		palette.magenta01,
		palette.cyan01,
		palette.acc08,
	},
	scrollbar_thumb = palette.mono11,

	tab_bar = {
		background = palette.mono02,
		active_tab = {
			bg_color = palette.mono04,
			fg_color = palette.mono19,
			intensity = 'Bold',
			underline = 'None',
			italic = false,
			strikethrough = false,
		},
		new_tab = {
			bg_color = palette.mono02,
			fg_color = palette.mono11,
		},
		new_tab_hover = {
			bg_color = palette.mono02,
			fg_color = palette.mono13,
		},
	},
	split = palette.mono07,
}

local theme = {
	color_scheme = scheme_name,
	color_schemes = {
		[scheme_name] = scheme,
	},

	-- Compatibility for modules that read `colors.custom.background`.
	active = scheme,
	background = scheme.background,
	foreground = scheme.foreground,

	command_palette_bg_color = palette.mono04,
	command_palette_fg_color = palette.mono19,

	-- TODO: reference option - review and enable if desired.
	-- char_select_bg_color = palette.mono04,
	-- TODO: reference option - review and enable if desired.
	-- char_select_fg_color = palette.mono21,

	-- TODO: reference option - review and enable if desired.
	-- pane_select_bg_color = palette.acc07,
	-- TODO: reference option - review and enable if desired.
	-- pane_select_fg_color = palette.mono02,

	-- TODO: reference option - review and enable if desired.
	-- bold_brightens_ansi_colors = 'No',

	-- TODO: reference options - review and enable if desired.
	-- colors = {
	--    copy_mode_active_highlight_bg = { Color = palette.yellow01 },
	--    copy_mode_active_highlight_fg = { Color = palette.mono02 },
	--    copy_mode_inactive_highlight_bg = { Color = palette.yellow00 },
	--    copy_mode_inactive_highlight_fg = { Color = palette.mono02 },
	--    quick_select_label_bg = { Color = palette.yellow01 },
	--    quick_select_label_fg = { Color = palette.mono02 },
	--    quick_select_match_bg = { Color = palette.yellow00 },
	--    quick_select_match_fg = { Color = palette.mono02 },
	--    input_selector_label_bg = { Color = palette.mono03 },
	--    input_selector_label_fg = { Color = palette.acc07 },
	-- },
}

return theme
