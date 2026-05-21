local wezterm = require('wezterm') ---@type Wezterm
local paths = require('utils.paths')

local M = {}

local function trim(value)
	return (value or ''):match('^%s*(.-)%s*$') or ''
end

---@param cwd string
---@return string
function M.root_for_cwd(cwd)
	local ok, success, stdout = pcall(wezterm.run_child_process, {
		'git',
		'-C',
		cwd,
		'rev-parse',
		'--show-toplevel',
	})

	if ok and success and trim(stdout) ~= '' then
		return trim(stdout)
	end

	return cwd
end

---@param root string
---@return string
function M.name_for_root(root)
	local name = paths.basename(root)

	if name == '' then
		return 'main'
	end

	return name
end

---@param pane Pane
---@return {cwd: string, root: string, name: string}
function M.from_pane(pane)
	local cwd = paths.cwd_path(pane, wezterm.home_dir)
	local root = M.root_for_cwd(cwd)

	return {
		cwd = cwd,
		root = root,
		name = M.name_for_root(root),
	}
end

return M
