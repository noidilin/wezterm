-- A slightly altered version of catppucchin mocha
-- stylua: ignore
local mocha = {
   rosewater = '#dcb5a5',
   flamingo  = '#c8a492',
   pink      = '#9f9fbd',
   mauve     = '#797994',
   red       = '#b07878',
   maroon    = '#cc9393',
   peach     = '#d6caab',
   yellow    = '#ebd6b7',
   green     = '#778777',
   teal      = '#9bb09b',
   sky       = '#92b3b3',
   sapphire  = '#769494',
   blue      = '#7d96ad',
   lavender  = '#9db2cf',
   text      = '#b3b3b3',
   subtext1  = '#9d9d9d',
   subtext0  = '#878787',
   overlay2  = '#707070',
   overlay1  = '#5d5d5d',
   overlay0  = '#4e4e4e',
   surface2  = '#414141',
   surface1  = '#353535',
   surface0  = '#2a2a2a',
   base      = '#1e1e1e',
   mantle    = '#191919',
   crust     = '#151515',
}

local colorscheme = {
   foreground = '#b3b3b3',
   background = '#191919',
   cursor_bg = '#878787',
   selection_bg = '#303030',
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
   compose_cursor = '#dad5c8',

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
   visual_bell = mocha.red,
   indexed = {
      [16] = mocha.peach,
      [17] = mocha.rosewater,
   },
   scrollbar_thumb = mocha.overlay0,
   split = mocha.overlay0,
}

return colorscheme
