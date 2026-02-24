local wezterm = require('wezterm')
local Cells = require('utils.cells')
local palette = require('colors._palette')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_DEFAULT_MODE = nf.seti_powershell --[[ '' ]]
local GLYPH_LEADER = nf.cod_debug_breakpoint_data --[[ '' ]]
local GLYPH_RESIZE = nf.md_arrow_expand --[[ '󰊓' ]]
local GLYPH_MOVE = nf.md_cursor_move --[[ '󰆾' ]]
local GLYPH_COPY = nf.md_content_copy --[[ '󰆏' ]]
local GLYPH_SEARCH = nf.md_magnify --[[ '󰍉' ]]
local GLYPH_ADMIN = nf.md_shield --[[ '󰒘' ]]
local GLYPH_WSL = nf.md_arch --[[ '󰣇' ]]

---@type table<string, {icon: string, label: string}>
local MODE_MAP = {
   resize_pane = { icon = GLYPH_RESIZE, label = 'resize' },
   move_tab = { icon = GLYPH_MOVE, label = 'move' },
   copy_mode = { icon = GLYPH_COPY, label = 'copy' },
   search_mode = { icon = GLYPH_SEARCH, label = 'search' },
}

---@type table<string, Cells.SegmentColors>
local colors = {
   default = { bg = palette.mono05, fg = palette.mono24 },
   scircle = { bg = palette.mono02, fg = palette.mono05 },
   context = { bg = palette.mono02, fg = palette.mono14 },
   admin = { bg = palette.mono02, fg = palette.yellow00 },
   wsl = { bg = palette.mono02, fg = palette.blue00 },
}

local cells = Cells:new()

cells
   :add_segment(
      'scircle_left',
      ' ' .. GLYPH_SEMI_CIRCLE_LEFT,
      colors.scircle,
      attr(attr.intensity('Bold'))
   )
   :add_segment('mode_icon', GLYPH_DEFAULT_MODE, colors.default, attr(attr.intensity('Bold')))
   :add_segment('mode_label', 'noid', colors.default, attr(attr.intensity('Bold')))
   :add_segment(
      'scircle_right',
      GLYPH_SEMI_CIRCLE_RIGHT .. ' ',
      colors.scircle,
      attr(attr.intensity('Bold'))
   )
   :add_segment('workspace_text', '', colors.context)
   :add_segment('separator', ' ', colors.context)
   :add_segment('domain_text', '', colors.context)
   :add_segment('admin', '', colors.admin)
   :add_segment('wsl', '', colors.wsl)
   :add_segment('padding', ' |', colors.context, attr(attr.intensity('Bold')))

local function safe_lower(text)
   return string.lower(text or '')
end

local function truncate(text, max_len)
   if #text <= max_len then
      return text
   end
   return text:sub(1, max_len - 1) .. '…'
end

---@param proc string
---@return string
local function clean_process_name(proc)
   local a = string.gsub(proc, '(.*[/\\])(.*)', '%2')
   return a:gsub('%.exe$', '')
end

---@param window Window
---@return string, string
local function resolve_mode(window)
   if window:leader_is_active() then
      return GLYPH_LEADER, 'lead'
   end

   if window:composition_status() then
      return GLYPH_LEADER, 'comp'
   end

   local key_table = window:active_key_table()
   if key_table then
      local mode = MODE_MAP[key_table]
      if mode then
         return mode.icon, mode.label
      end
      return GLYPH_LEADER, safe_lower(key_table)
   end

   return GLYPH_DEFAULT_MODE, 'noid'
end

---@param pane Pane
---@return boolean
local function is_admin_context(pane)
   local ok, title = pcall(function()
      return pane:get_title()
   end)

   if not ok or type(title) ~= 'string' then
      return false
   end

   return title:match('^Administrator: ') ~= nil or title:match('%(Admin%)') ~= nil
end

---@param pane Pane
---@return boolean
local function is_wsl_context(pane)
   local ok, process_name = pcall(function()
      return pane:get_foreground_process_name()
   end)

   if not ok or type(process_name) ~= 'string' or process_name == '' then
      return false
   end

   return clean_process_name(process_name):match('^wsl') ~= nil
end

M.setup = function()
   wezterm.on('update-right-status', function(window, pane)
      local mode_icon, mode_label = resolve_mode(window)
      local workspace = truncate(wezterm.mux.get_active_workspace() or 'default', 18)
      local domain = truncate(pane:get_domain_name() or 'local', 22)
      local admin = is_admin_context(pane) and (' ' .. GLYPH_ADMIN) or ''
      local wsl = is_wsl_context(pane) and (' ' .. GLYPH_WSL) or ''

      cells
         :update_segment_text('mode_icon', mode_icon)
         :update_segment_text('mode_label', ' ' .. mode_label)
         :update_segment_text('workspace_text', workspace)
         :update_segment_text('domain_text', domain)
         :update_segment_text('admin', admin)
         :update_segment_text('wsl', wsl)

      local res = cells:render({
         'scircle_left',
         'mode_icon',
         'mode_label',
         'scircle_right',
         'workspace_text',
         'separator',
         'domain_text',
         'admin',
         'wsl',
         'padding',
      })

      window:set_left_status(wezterm.format(res))
   end)
end

return M
