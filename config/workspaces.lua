local wezterm = require('wezterm') ---@type Wezterm
local act = wezterm.action
local projects = require('utils.projects')

local M = {}

---@param window Window
---@param pane Pane
function M.switch_to_current_project(window, pane)
	local project = projects.from_pane(pane)

	window:perform_action(
		act.SwitchToWorkspace({
			name = project.name,
			spawn = { cwd = project.root },
		}),
		pane
	)
end

---@return Action
function M.workspace_picker()
	return act.Multiple({
		act.ShowLauncherArgs({ title = 'mux', flags = 'FUZZY|WORKSPACES' }),
		'PopKeyTable',
	})
end

---@return Action
function M.prompt_new_workspace()
	return act.Multiple({
		act.PromptInputLine({
			description = 'New workspace:',
			action = wezterm.action_callback(function(window, pane, line)
				if line and line ~= '' then
					window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
		'PopKeyTable',
	})
end

---@return table[]
function M.key_table()
	return {
		{ key = 'o', action = M.workspace_picker() },
		{
			key = 'p',
			action = act.Multiple({
				wezterm.action_callback(M.switch_to_current_project),
				'PopKeyTable',
			}),
		},
		{ key = 'n', action = M.prompt_new_workspace() },
		{ key = 'h', action = act.SwitchWorkspaceRelative(-1) },
		{ key = 'l', action = act.SwitchWorkspaceRelative(1) },
		{ key = 'Escape', action = 'PopKeyTable' },
		{ key = 'Enter', action = 'PopKeyTable' },
		{ key = 'q', action = 'PopKeyTable' },
	}
end

return M
