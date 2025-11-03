local spec = require("chatgpt_search_templater.spec")

local M = {}

---@return table
function M.defaults()
	return spec.default_templates()
end

-- ---@return table
-- function M.custom()
-- 	return spec.custom_query_template()
-- end

---@param templates table
---@return table
function M.normalize(templates)
	local source = templates or {}
	local normalized = {}
	for _, template in ipairs(source) do
		local copy = vim.deepcopy(template)
		table.insert(normalized, copy)
	end
	return normalized
end

return M
