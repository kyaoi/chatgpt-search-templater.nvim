local spec_data = require("chatgpt_search_templater.spec_data")
local models = spec_data.models

local M = {}

local defaults = {
	spec_path = nil,
	spec_data = nil,
	use_default_keymaps = true,
	keymaps = {
		visual = "<leader>cg",
		default_visual = "<leader>cG",
		query_input = "<leader>cq",
	},
	query_input = {
		title = "ChatGPT Query",
		border = "rounded",
		width = nil,
		height = nil,
		prompt = nil,
		preset = nil,
		append_selection = true,
		separator = "\n\n",
		fallback_text = "",
		template = {
			label = "カスタムクエリ入力",
			url = "https://chatgpt.com/?prompt={TEXT}",
			model = models[1],
			hintsSearch = false,
			temporaryChat = false,
		},
	},
}

local options = vim.deepcopy(defaults)

---@param opts table|nil
---@return table
function M.set(opts)
	if opts == nil then
		options = vim.deepcopy(defaults)
		return options
	end

	options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts)
	return options
end

---@return table
function M.get()
	return options
end

return M
