local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_DEFAULT_MODE = nf.md_console --[[ '󰆍' ]]
local GLYPH_KEY = nf.md_key --[[ '󰌆' ]]
local GLYPH_RESIZE = nf.md_arrow_expand --[[ '󰊓' ]]
local GLYPH_MOVE = nf.md_cursor_move --[[ '󰆾' ]]
local GLYPH_COPY = nf.md_content_copy --[[ '󰆏' ]]
local GLYPH_SEARCH = nf.md_magnify --[[ '󰍉' ]]
local GLYPH_ADMIN = nf.md_shield_half_full --[[ '󰞀' ]]
local GLYPH_DOT_SEPARATOR = nf.oct_dot_fill --[[ '' ]]

---@type table<string, {icon: string, label: string}>
local MODE_MAP = {
   resize_pane = { icon = GLYPH_RESIZE, label = 'RESIZE' },
   move_tab = { icon = GLYPH_MOVE, label = 'MOVE TAB' },
   copy_mode = { icon = GLYPH_COPY, label = 'COPY' },
   search_mode = { icon = GLYPH_SEARCH, label = 'SEARCH' },
}

---@type table<string, Cells.SegmentColors>
local colors = {
   default = { bg = '#2a2a2a', fg = '#dcdcdc' },
   scircle = { bg = '#191919', fg = '#2a2a2a' },
   context = { bg = '#191919', fg = '#727272' },
   admin = { bg = '#191919', fg = '#d6caab' },
}

local cells = Cells:new()

cells
   :add_segment('scircle_left', GLYPH_SEMI_CIRCLE_LEFT, colors.scircle, attr(attr.intensity('Bold')))
   :add_segment('mode_icon', ' ' .. GLYPH_DEFAULT_MODE, colors.default, attr(attr.intensity('Bold')))
   :add_segment('mode_label', ' NORMAL ', colors.default, attr(attr.intensity('Bold')))
   :add_segment('scircle_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.scircle, attr(attr.intensity('Bold')))
   :add_segment('separator_1', ' ', colors.context)
   :add_segment('workspace_text', '', colors.context, attr(attr.intensity('Bold')))
   :add_segment('separator_2', ' ' .. GLYPH_DOT_SEPARATOR .. ' ', colors.context)
   :add_segment('domain_text', '', colors.context, attr(attr.intensity('Bold')))
   :add_segment('admin', '', colors.admin)
   :add_segment('tail_space', ' ', colors.context)

local function safe_upper(text)
   return string.upper(text or '')
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
      return GLYPH_KEY, 'LEADER'
   end

   if window:composition_status() then
      return GLYPH_KEY, 'COMPOSE'
   end

   local key_table = window:active_key_table()
   if key_table then
      local mode = MODE_MAP[key_table]
      if mode then
         return mode.icon, mode.label
      end
      return GLYPH_KEY, safe_upper(key_table)
   end

   return GLYPH_DEFAULT_MODE, 'NORMAL'
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
         :update_segment_text('mode_icon', ' ' .. mode_icon)
         :update_segment_text('mode_label', ' ' .. mode_label .. ' ')
         :update_segment_text('workspace_text', workspace)
         :update_segment_text('domain_text', domain)
         :update_segment_text('admin', admin)

      local res = cells:render({
         'scircle_left',
         'mode_icon',
         'mode_label',
         'scircle_right',
         'separator_1',
         'workspace_text',
         'separator_2',
         'domain_text',
         'admin',
         'tail_space',
      })

      window:set_left_status(wezterm.format(res))
   end)
end

return M
