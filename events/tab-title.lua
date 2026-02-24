-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614 --

local wezterm = require('wezterm')
local Cells = require('utils.cells')

-- Constants and icons
local nf = wezterm.nerdfonts

local M = {}

---@type table<number, boolean>
local bell_tabs = {}

local GLYPH_CIRCLE = nf.cod_circle_filled --[[  ]]
local GLYPH_DEBUG = nf.md_bug_outline --[[ 󰨰 ]]
local GLYPH_SEARCH = nf.cod_search_fuzzy --[[  ]]
local GLYPH_ZOOM = ' '
local GLYPH_BELL = ' '
local GLYPH_PROGRESS_ICONS = { '󰪞', '󰪟', '󰪠', '󰪡', '󰪢', '󰪣', '󰪤', '󰪥' }
local GLYPH_PROGRESS_ERROR = ' '
local GLYPH_PROGRESS_INDETERMINATE = ' 󰪡'

local TITLE_INSET = 5

local SHELL_PROCESSES = {
   nu = true,
   bash = true,
   zsh = true,
   fish = true,
   pwsh = true,
   powershell = true,
   cmd = true,
   cmd64 = true,
}

local RENDER_VARIANTS = {
   'title',
   'unseen_output',
   'zoom',
   'attention',
   'progress',
   'padding',
}


---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
   text_default          = { bg = '#191919', fg = '#414141' },
   text_hover            = { bg = '#191919', fg = '#555555' },
   text_active           = { bg = '#191919', fg = '#9d9d9d' },

   unseen_output_default = { bg = '#191919', fg = '#414141' },
   unseen_output_hover   = { bg = '#191919', fg = '#555555' },
   unseen_output_active  = { bg = '#2a2a2a', fg = '#9d9d9d' },

   zoom_default          = { bg = '#191919', fg = '#414141' },
   zoom_hover            = { bg = '#191919', fg = '#555555' },
   zoom_active           = { bg = '#2a2a2a', fg = '#9d9d9d' },

   attention_default     = { bg = '#191919', fg = '#d6caab' },
   attention_hover       = { bg = '#191919', fg = '#ebd6b7' },
   attention_active      = { bg = '#2a2a2a', fg = '#ebd6b7' },

   progress_default      = { bg = '#191919', fg = '#414141' },
   progress_hover        = { bg = '#191919', fg = '#555555' },
   progress_active       = { bg = '#2a2a2a', fg = '#9d9d9d' },
}

-- Helper functions
---@param proc string
local function clean_process_name(proc)
   local a = string.gsub(proc, '(.*[/\\])(.*)', '%2')
   return a:gsub('%.exe$', '')
end

---@param process_name string
local function is_shell_process(process_name)
   return SHELL_PROCESSES[process_name:lower()] == true
end

---@param value string
local function compact_path_label(value)
   local normalized = value:gsub('\\', '/'):gsub('/+$', '')
   if normalized == '' then
      return value
   end
   if normalized == '~' then
      return '~'
   end

   local leaf = normalized:match('([^/]+)$')
   if leaf and leaf ~= '' then
      return leaf
   end
   return normalized
end

---@param base_title string
local function cwd_label_from_title(base_title)
   local sanitized = base_title:gsub('^Administrator:%s*', ''):gsub('%s*%(Admin%)%s*$', '')

   local unix_like_path = sanitized:match('([~./][^%s]*)$')
   if unix_like_path then
      return compact_path_label(unix_like_path)
   end

   local windows_path = sanitized:match('([A-Za-z]:[\\/][^%s]*)$')
   if windows_path then
      return compact_path_label(windows_path)
   end

   if sanitized:find('/') or sanitized:find('\\') then
      return compact_path_label(sanitized)
   end

   return sanitized
end

---@param value string
---@param max_len number
local function truncate_with_ellipsis(value, max_len)
   if value:len() <= max_len then
      return value
   end

   if max_len <= 3 then
      return value:sub(1, max_len)
   end

   return value:sub(1, max_len - 3) .. '...'
end

---@param process_name string
---@param base_title string
---@param max_width number
---@param inset number
local function create_title(process_name, base_title, max_width, inset)
   local title = cwd_label_from_title(base_title)
   if process_name:len() > 0 and not is_shell_process(process_name) then
      title = process_name
   end

   if base_title == 'Debug' then
      title = GLYPH_DEBUG .. ' DEBUG'
      inset = inset - 2
   end

   if base_title:match('^InputSelector:') ~= nil then
      title = base_title:gsub('InputSelector:', GLYPH_SEARCH)
      inset = inset - 2
   end

   local text_width = math.max(0, max_width - inset)
   if title:len() > text_width then
      title = truncate_with_ellipsis(title, text_width)
   else
      local padding = text_width - title:len()
      title = title .. string.rep(' ', padding)
   end

   return title
end

---@param panes any[] WezTerm https://wezfurlong.org/wezterm/config/lua/pane/index.html
local function check_unseen_output(panes)
   local unseen_output = false

   for i = 1, #panes, 1 do
      if panes[i].has_unseen_output then
         unseen_output = true
         break
      end
   end

   return unseen_output
end

---@param value number
local function clamp_progress(value)
   return math.max(0, math.min(100, math.floor(value)))
end

---@param percentage number
local function progress_icon(percentage)
   local idx = math.floor(clamp_progress(percentage) / 12) + 1
   if idx > #GLYPH_PROGRESS_ICONS then
      idx = #GLYPH_PROGRESS_ICONS
   end
   return GLYPH_PROGRESS_ICONS[idx]
end

---@param pane any
---@return string, string|nil
local function get_progress_display(pane)
   local progress = pane.progress
   if progress == nil then
      return '', nil
   end

   if type(progress) == 'table' then
      if type(progress.Percentage) == 'number' then
         return ' ' .. progress_icon(progress.Percentage), '#778777'
      end

      if progress.Error ~= nil then
         if type(progress.Error) == 'number' then
            return ' ' .. progress_icon(progress.Error), '#b07878'
         end
         return GLYPH_PROGRESS_ERROR, '#b07878'
      end
   elseif progress == 'Indeterminate' then
      return GLYPH_PROGRESS_INDETERMINATE, '#7d96ad'
   end

   return '', nil
end

-- Tab class and API
---@class Tab
---@field title string
---@field cells FormatCells
---@field title_locked boolean
---@field locked_title string
---@field unseen_output boolean
---@field has_bell boolean
---@field is_zoomed boolean
---@field progress_text string
---@field progress_color string|nil
---@field is_active boolean
local Tab = {}
Tab.__index = Tab

function Tab:new()
   local tab = {
      title = '',
      cells = Cells:new(),
      title_locked = false,
      locked_title = '',
      unseen_output = false,
      has_bell = false,
      is_zoomed = false,
      progress_text = '',
      progress_color = nil,
   }
   return setmetatable(tab, self)
end

---@param tab any WezTerm https://wezfurlong.org/wezterm/config/lua/MuxTab/index.html
---@param max_width number
function Tab:set_info(tab, max_width)
   local process_name = clean_process_name(tab.active_pane.foreground_process_name)

   self.unseen_output = false
   self.has_bell = bell_tabs[tab.tab_id] == true
   self.is_zoomed = tab.active_pane.is_zoomed
   self.progress_text, self.progress_color = get_progress_display(tab.active_pane)

   if not tab.is_active then
      self.unseen_output = check_unseen_output(tab.panes)
   end

   local inset = TITLE_INSET
   if self.unseen_output then
      inset = inset + 2
   end

   if self.is_zoomed then
      inset = inset + 2
   end

   if self.has_bell then
      inset = inset + 2
   end

   if self.progress_text ~= '' then
      inset = inset + 2
   end

   if self.title_locked then
      self.title = create_title('', self.locked_title, max_width, inset)
      return
   end
   self.title = create_title(process_name, tab.active_pane.title, max_width, inset)
end

function Tab:create_cells()
   local attr = self.cells.attr
   self.cells
      :add_segment('title', ' ', nil, attr(attr.intensity('Bold')))
      :add_segment('unseen_output', ' ' .. GLYPH_CIRCLE)
      :add_segment('zoom', '')
      :add_segment('attention', '')
      :add_segment('progress', '')
      :add_segment('padding', ' ')
end

---@param title string
function Tab:update_and_lock_title(title)
   self.locked_title = title
   self.title_locked = true
end

---@param is_active boolean
---@param hover boolean
function Tab:update_cells(is_active, hover)
   local tab_state = 'default'
   if is_active then
      tab_state = 'active'
   elseif hover then
      tab_state = 'hover'
   end

   self.cells:update_segment_text('title', ' ' .. self.title)

   if not self.unseen_output then
      self.cells:update_segment_text('unseen_output', '')
   end

   if self.is_zoomed then
      self.cells:update_segment_text('zoom', GLYPH_ZOOM)
   else
      self.cells:update_segment_text('zoom', '')
   end

   if self.has_bell then
      self.cells:update_segment_text('attention', GLYPH_BELL)
   else
      self.cells:update_segment_text('attention', '')
   end

   self.cells:update_segment_text('progress', self.progress_text)

   self.cells
      :update_segment_colors('title', colors['text_' .. tab_state])
      :update_segment_colors('unseen_output', colors['unseen_output_' .. tab_state])
      :update_segment_colors('zoom', colors['zoom_' .. tab_state])
      :update_segment_colors('attention', colors['attention_' .. tab_state])
      :update_segment_colors('progress', colors['progress_' .. tab_state])
      :update_segment_colors('padding', colors['text_' .. tab_state])

   if self.progress_color then
      self.cells:update_segment_colors('progress', { fg = self.progress_color })
   end
end

---@return FormatItem[] (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)
function Tab:render()
   return self.cells:render(RENDER_VARIANTS)
end

---@type Tab[]
local tab_list = {}

M.setup = function()
   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   -- Tab name will remain locked until the `reset-tab-title` is triggered
   wezterm.on('tabs.manual-update-tab-title', function(window, pane)
      window:perform_action(
         wezterm.action.PromptInputLine({
            description = wezterm.format({
               { Foreground = { Color = '#FFFFFF' } },
               { Attribute = { Intensity = 'Bold' } },
               { Text = 'Enter new name for tab' },
            }),
            action = wezterm.action_callback(function(_window, _pane, line)
               if line ~= nil then
                  local tab = window:active_tab()
                  local id = tab:tab_id()
                  tab_list[id]:update_and_lock_title(line)
               end
            end),
         }),
         pane
      )
   end)

   -- CUSTOM EVENT
   -- Event listener to unlock manually set tab name
   wezterm.on('tabs.reset-tab-title', function(window, _pane)
      local tab = window:active_tab()
      local id = tab:tab_id()
      tab_list[id].title_locked = false
   end)

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   wezterm.on('tabs.toggle-tab-bar', function(window, _pane)
      local effective_config = window:effective_config()
      window:set_config_overrides({
         enable_tab_bar = not effective_config.enable_tab_bar,
         background = effective_config.background,
      })
   end)

   -- BUILTIN EVENT
   wezterm.on('bell', function(window, pane)
      local active_tab_id = window:active_tab():tab_id()
      local bell_tab_id = pane:tab():tab_id()

      if active_tab_id ~= bell_tab_id then
         bell_tabs[bell_tab_id] = true
      end
   end)

   -- BUILTIN EVENT
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
      if tab.is_active and bell_tabs[tab.tab_id] then
         bell_tabs[tab.tab_id] = nil
      end

      if not tab_list[tab.tab_id] then
         tab_list[tab.tab_id] = Tab:new()
         tab_list[tab.tab_id]:set_info(tab, max_width)
         tab_list[tab.tab_id]:create_cells()
         tab_list[tab.tab_id]:update_cells(tab.is_active, hover)
         return tab_list[tab.tab_id]:render()
      end

      tab_list[tab.tab_id]:set_info(tab, max_width)
      tab_list[tab.tab_id]:update_cells(tab.is_active, hover)
      return tab_list[tab.tab_id]:render()
   end)
end

return M
