local config = require("chatgpt_search_templater.config")
local keymaps = require("chatgpt_search_templater.keymaps")
local spec = require("chatgpt_search_templater.spec")
local templates = require("chatgpt_search_templater.templates")

local M = {}

---@param opts table|nil
---@return table
function M.setup(opts)
	local options = config.set(opts)

	spec.set_spec_path(options.spec_path)
	spec.set_spec_data(options.spec_data)

	local spec_payload = spec.load()

	local payload = {
		options = options,
		spec = spec_payload,
		placeholders = spec.placeholders(),
		default_templates = templates.defaults(),
		custom_templates = templates.custom(),
	}

	keymaps.apply(options, payload)

	return payload
end

return M
