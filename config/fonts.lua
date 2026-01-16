local wezterm = require('wezterm')
local platform = require('utils.platform')

-- local font_family = 'Maple Mono Normal NF CN'
local font_family = 'CommitMono Nerd Font Mono'
local font_size = platform.is_win and 12.5 or 14
local line_height = platform.is_win and 1.5 or 1.3

return {
   font = wezterm.font({
      family = font_family,
      -- weight = 'Medium',
   }),
   font_size = font_size,
   line_height = line_height,
   command_palette_font = wezterm.font(font_family),
   command_palette_font_size = font_size,

   --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
   freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
