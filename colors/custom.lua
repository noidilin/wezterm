-- A slightly altered version of catppucchin mocha
-- stylua: ignore
local mocha = {
   rosewater = '#f5e0dc',
   flamingo  = '#f2cdcd',
   pink      = '#f5c2e7',
   mauve     = '#cba6f7',
   red       = '#f38ba8',
   maroon    = '#eba0ac',
   peach     = '#fab387',
   yellow    = '#f9e2af',
   green     = '#a6e3a1',
   teal      = '#94e2d5',
   sky       = '#89dceb',
   sapphire  = '#74c7ec',
   blue      = '#89b4fa',
   lavender  = '#b4befe',
   text      = '#cdd6f4',
   subtext1  = '#bac2de',
   subtext0  = '#a6adc8',
   overlay2  = '#9399b2',
   overlay1  = '#7f849c',
   overlay0  = '#6c7086',
   surface2  = '#585b70',
   surface1  = '#45475a',
   surface0  = '#313244',
   base      = '#1f1f28',
   mantle    = '#181825',
   crust     = '#11111b',
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
   -- scrollbar_thumb = '#4e4e4e',

   tab_bar = {
      -- The color of the strip that goes along the top of the window
      -- (does not apply when fancy tab bar is in use)
      background = '#191919',
      active_tab = {
         bg_color = '#242424',  -- background color
         fg_color = '#9d9d9d',  -- text color
         intensity = 'Bold',    -- default is "Normal" (options: "Half", "Normal" or "Bold")
         underline = 'Single',  -- default is "None" (options: "None", "Single" or "Double")
         italic = false,        -- default is false
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
   scrollbar_thumb = mocha.surface2,
   split = mocha.overlay0,
   compose_cursor = mocha.flamingo,
}

return colorscheme
