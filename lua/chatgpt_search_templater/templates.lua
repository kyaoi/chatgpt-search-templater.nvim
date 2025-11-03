local spec = require("chatgpt_search_templater.spec")
local utils = require("chatgpt_search_templater.utils")

local M = {}

---@return table
function M.defaults()
	return spec.default_templates()
end

---@return table
function M.custom()
	return spec.custom_template()
end

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

---@param template table|nil
---@return boolean
local function template_is_default(template)
	if type(template) ~= "table" then
		return false
	end
	if template.default == true or template.isDefault == true then
		return true
	end
	return false
end

---@param list table|nil
---@return table
function M.collect_enabled(list)
	local defaults, others = {}, {}
	if type(list) ~= "table" then
		return defaults
	end

	for _, template in ipairs(list) do
		if type(template) == "table" then
			local allowed = template.enabled == nil or template.enabled == true
			if allowed then
				if template_is_default(template) then
					defaults[#defaults + 1] = template
				else
					others[#others + 1] = template
				end
			end
		end
	end

	for _, template in ipairs(others) do
		defaults[#defaults + 1] = template
	end

	return defaults
end

---@param spec_payload table|nil
---@return table|nil
function M.find_default(spec_payload)
	if type(spec_payload) ~= "table" then
		return nil
	end

	local candidates = spec_payload.defaultTemplates or spec_payload.templates or {}
	local default_candidate
	local first_enabled
	for _, template in ipairs(candidates) do
		if type(template) == "table" then
			local enabled = template.enabled == nil or template.enabled == true
			if template_is_default(template) then
				if enabled then
					return template
				end
				default_candidate = default_candidate or template
			end
			if enabled and not first_enabled then
				first_enabled = template
			end
		end
	end

	return first_enabled or default_candidate or candidates[1]
end

---@param spec_payload table|nil
---@param default_templates table|nil
---@return table|nil
function M.select_default(spec_payload, default_templates)
	local defaults = M.collect_enabled(default_templates)
	if #defaults > 0 then
		return defaults[1]
	end
	return M.find_default(spec_payload)
end

---@param spec_payload table|nil
---@param template table|nil
---@return string
local function resolve_query_template(spec_payload, template)
	if type(template) == "table" then
		local candidate = template.queryTemplate
		if type(candidate) == "string" and candidate ~= "" then
			return candidate
		end
	end

	if type(spec_payload) == "table" then
		local fallback = spec_payload.defaultQueryTemplate
		if type(fallback) == "string" and fallback ~= "" then
			return fallback
		end
	end

	return "{TEXT}"
end

---@param spec_payload table|nil
---@param template table|nil
---@param text string
---@return string
function M.render_query(spec_payload, template, text)
	local query_template = resolve_query_template(spec_payload, template)
	local placeholders = spec_payload and spec_payload.placeholders or {}
	return utils.replace_placeholders(query_template, text, placeholders)
end

---@param value any
---@return string|nil
local function normalize_hints(value)
	if value == nil then
		return nil
	end
	if type(value) == "boolean" then
		return value and "search" or nil
	end
	return utils.normalize_string(value)
end

---@param value any
---@return string|nil
local function normalize_bool_param(value)
	if value == nil then
		return nil
	end
	if type(value) == "boolean" then
		return value and "true" or nil
	end
	return utils.normalize_string(value)
end

---@param url string
---@param name string
---@param value string|nil
---@return string
local function set_query_param(url, name, value)
	if value == nil or value == "" then
		return url
	end
	local encoded_value = utils.url_encode(tostring(value))
	local escaped = vim.pesc(name)
	local updated, count = url:gsub("([%?&])" .. escaped .. "=[^&]*", function(prefix)
		return prefix .. name .. "=" .. encoded_value
	end, 1)
	if count == 0 then
		local separator = url:find("?", 1, true) and "&" or "?"
		updated = url .. separator .. name .. "=" .. encoded_value
	end
	return updated
end

---@param spec_payload table|nil
---@param template table|nil
---@param rendered_query string
---@return string|nil url
---@return string|nil error_message
function M.build_url(spec_payload, template, rendered_query)
	if type(template) ~= "table" then
		return nil, "no template"
	end

	local url_template = template.url
	local placeholders = {}
	if type(spec_payload) == "table" then
		url_template = url_template or spec_payload.defaultTemplateUrl
		if type(spec_payload.placeholders) == "table" then
			placeholders = spec_payload.placeholders
		end
	end

	if not url_template or url_template == "" then
		return nil, "missing url template"
	end

	local encoded_query = utils.url_encode(utils.trim(rendered_query))
	local url = utils.replace_placeholders(url_template, encoded_query, placeholders)

	local model = utils.normalize_string(template.model)
	local hints_value = normalize_hints(template.hintsSearch)
	local temporary_chat_value = normalize_bool_param(template.temporaryChat)

	if model then
		url = set_query_param(url, "model", model)
	end
	if hints_value then
		url = set_query_param(url, "hints", hints_value)
	end
	if temporary_chat_value then
		url = set_query_param(url, "temporary-chat", temporary_chat_value)
	end

	return url, nil
end

return M
