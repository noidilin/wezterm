local wezterm = require('wezterm')
local Cells = require('utils.cells')

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
local GLYPH_DOT_SEPARATOR = nf.oct_dot_fill --[[ '' ]]

---@type table<string, {icon: string, label: string}>
local MODE_MAP = {
   resize_pane = { icon = GLYPH_RESIZE, label = 'resize' },
   move_tab = { icon = GLYPH_MOVE, label = 'move' },
   copy_mode = { icon = GLYPH_COPY, label = 'copy' },
   search_mode = { icon = GLYPH_SEARCH, label = 'search' },
}

---@type table<string, Cells.SegmentColors>
local colors = {
   default = { bg = '#2a2a2a', fg = '#dcdcdc' },
   scircle = { bg = '#191919', fg = '#2a2a2a' },
   context = { bg = '#191919', fg = '#707070' },
   admin = { bg = '#191919', fg = '#d6caab' },
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
   :add_segment('workspace_text', '', colors.context, attr(attr.intensity('Bold')))
   :add_segment('separator', ' ' .. GLYPH_DOT_SEPARATOR .. ' ', colors.context)
   :add_segment('domain_text', '', colors.context, attr(attr.intensity('Bold')))
   :add_segment('admin', '', colors.admin)

local function safe_lower(text)
   return string.lower(text or '')
end

local function truncate(text, max_len)
   if #text <= max_len then
      return text
   end
   return text:sub(1, max_len - 1) .. '…'
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

M.setup = function()
   wezterm.on('update-right-status', function(window, pane)
      local mode_icon, mode_label = resolve_mode(window)
      local workspace = truncate(wezterm.mux.get_active_workspace() or 'default', 18)
      local domain = truncate(pane:get_domain_name() or 'local', 22)
      local admin = is_admin_context(pane) and (' ' .. GLYPH_ADMIN) or ''

      cells
         :update_segment_text('mode_icon', mode_icon)
         :update_segment_text('mode_label', ' ' .. mode_label)
         :update_segment_text('workspace_text', workspace)
         :update_segment_text('domain_text', domain)
         :update_segment_text('admin', admin)

      local res = cells:render({
         'scircle_left',
         'mode_icon',
         'mode_label',
         'scircle_right',
         'workspace_text',
         'separator',
         'domain_text',
         'admin',
      })

      window:set_left_status(wezterm.format(res))
   end)
end

return M
