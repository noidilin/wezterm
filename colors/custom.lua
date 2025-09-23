-- A slightly altered version of catppucchin mocha
local colorscheme = {
   foreground = '#b3b3b3',
   background = '#191919',
   compose_cursor = '#9d9d9d',
   cursor_fg = '#eaeaea',
   cursor_bg = '#878787',
   cursor_border = '#878787',
   selection_bg = '#303030',
   selection_fg = '#9d9d9d',
   -- order: black > red > green > yellow > blue > magenta > cyan > white
   ansi = { '#474747', '#b07878', '#778777', '#d6caab', '#7d96ad', '#797994', '#769494', '#dad5c8' },
   brights = {
      '#5d5d5d',
      '#cc9393',
      '#9bb09b',
      '#ebd6b7',
      '#9db2cf',
      '#9f9fbd',
      '#92b3b3',
      '#faf5eb',
   },
   -- further customization
   cursor_border = '#878787',
   selection_fg = '#8e8e8e',
   cursor_fg = '#eaeaea',
   scrollbar_thumb = '#4e4e4e',

   tab_bar = {
      -- The color of the strip that goes along the top of the window
      -- (does not apply when fancy tab bar is in use)
      background = '#191919',
      active_tab = {
         bg_color = '#242424', -- background color
         fg_color = '#9d9d9d', -- text color
         intensity = 'Bold', -- default is "Normal" (options: "Half", "Normal" or "Bold")
         underline = 'Single', -- default is "None" (options: "None", "Single" or "Double")
         italic = false, -- default is false
         strikethrough = false, -- default is false
      },

      --[[ inactive_tab = { -- same options as `active_tab` section
			bg_color = "#191919",
			fg_color = "#4e4e4e",
			italic = true,
		}, ]]

      --[[ inactive_tab_hover = { -- same options as `active_tab` section
			bg_color = "#191919",
			fg_color = "#5d5d5d",
			italic = true,
		}, ]]

      new_tab = { -- same options as `active_tab` section
         bg_color = '#191919',
         fg_color = '#4e4e4e',
      },

      new_tab_hover = { -- same options as `active_tab` section
         bg_color = '#191919',
         fg_color = '#5d5d5d',
      },
   },
   split = '#353535',
   compose_cursor = '#5d5d5d',
}

return colorscheme
