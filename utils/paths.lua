local wezterm = require('wezterm') ---@type Wezterm

local M = {}

---@param value string
---@return string
function M.decode_percent_encoded(value)
	return (value or ''):gsub('%%(%x%x)', function(hex)
		return string.char(tonumber(hex, 16))
	end)
end

---@param pane Pane
---@param fallback string|nil
---@return string
function M.cwd_path(pane, fallback)
	local ok, cwd = pcall(function()
		return pane:get_current_working_dir()
	end)

	if not ok or cwd == nil then
		return fallback or wezterm.home_dir
	end

	local path
	if type(cwd) == 'string' then
		path = cwd
	else
		path = cwd.file_path or cwd.path or tostring(cwd)
	end

	path = M.decode_percent_encoded(path or '')
	path = path:gsub('^file://[^/]*', '')

	if path == '' then
		return fallback or wezterm.home_dir
	end

	return path
end

---@param path string
---@return string
function M.basename(path)
	local normalized = (path or ''):gsub('\\', '/'):gsub('/+$', '')
	return normalized:match('([^/]+)$') or normalized
end

return M
