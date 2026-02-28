local platform = require('utils.platform')
local custom = require('config.custom')

local M = {}

---@param path string
---@param fallback any
---@return any
function M.get(path, fallback)
	local node = custom

	for key in string.gmatch(path, '([^.]+)') do
		if type(node) ~= 'table' then
			return fallback
		end

		node = node[key]
		if node == nil then
			return fallback
		end
	end

	return node
end

---@param path string
---@param fallback any
---@return any
function M.get_platform(path, fallback)
	local values = M.get(path, nil)

	if type(values) ~= 'table' then
		if values ~= nil then
			return values
		end
		return fallback
	end

	return values[platform.os] or values.mac or values.linux or values.windows or fallback
end

return M
