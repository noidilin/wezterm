local gpu_adapters = require('utils.gpu-adapter')
-- local backdrops = require('utils.backdrops')
local theme = require('colors.custom')
local is_dark = true

return {
   max_fps = 60,
   front_end = 'WebGpu', ---@type 'WebGpu' | 'OpenGL' | 'Software'
   webgpu_power_preference = 'HighPerformance',
   webgpu_preferred_adapter = gpu_adapters:pick_best(),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Dx12', 'IntegratedGpu'),
   -- webgpu_preferred_adapter = gpu_adapters:pick_manual('Gl', 'Other'),
   underline_thickness = '1.5pt',

   -- cursor
   animation_fps = 60,
   cursor_blink_ease_in = 'EaseOut',
   cursor_blink_ease_out = 'EaseOut',
   default_cursor_style = 'BlinkingBar',
   cursor_blink_rate = 650,

   -- color schemes
   color_schemes = theme.color_schemes,
   color_scheme = theme.color_scheme,

   -- background
   -- background = backdrops:create_opts(),

   -- scrollbar
   enable_scroll_bar = false,

   -- tab bar
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = false,
   use_fancy_tab_bar = false,
   tab_max_width = 25,
   show_tab_index_in_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

   -- window
   window_decorations = 'RESIZE',
   window_padding = {
      left = 10,
      right = 10,
      top = 10,
      bottom = 10,
   },
   adjust_window_size_when_changing_font_size = false,
   window_close_confirmation = 'NeverPrompt',
   window_frame = {
      active_titlebar_bg = '#090909',
      -- font = fonts.font,
      -- font_size = fonts.font_size,
   },
   inactive_pane_hsb = {
      saturation = 0.1,
      brightness = is_dark and 0.8 or 0.95,
   },

   command_palette_bg_color = theme.command_palette_bg_color,
   command_palette_fg_color = theme.command_palette_fg_color,
   command_palette_rows = 14,

   -- TODO: reference option - review and enable if desired.
   -- char_select_bg_color = theme.char_select_bg_color,
   -- TODO: reference option - review and enable if desired.
   -- char_select_fg_color = theme.char_select_fg_color,
   -- TODO: reference option - review and enable if desired.
   -- pane_select_bg_color = theme.pane_select_bg_color,
   -- TODO: reference option - review and enable if desired.
   -- pane_select_fg_color = theme.pane_select_fg_color,

   -- TODO: reference option - review and enable if desired.
   -- colors = theme.colors,
   -- TODO: reference option - review and enable if desired.
   -- bold_brightens_ansi_colors = theme.bold_brightens_ansi_colors,

   visual_bell = {
      fade_in_function = 'EaseIn',
      fade_in_duration_ms = 250,
      fade_out_function = 'EaseOut',
      fade_out_duration_ms = 250,
      target = 'CursorColor',
   },
}
