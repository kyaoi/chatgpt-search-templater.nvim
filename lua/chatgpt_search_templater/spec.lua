local spec_data = require("chatgpt_search_templater.spec_data")

local M = {}

local cached_spec
local override_path
local override_spec

local function clone(value)
	return vim.deepcopy(value)
end

local function read_file(path)
	local fd, open_err = io.open(path, "r")
	if not fd then
		return nil, open_err or ("failed to open " .. path)
	end
	local ok, content = pcall(fd.read, fd, "*a")
	fd:close()
	if not ok then
		return nil, content
	end
	return content, nil
end

local function load_from_json(path)
	local expanded = vim.fn.fnamemodify(path, ":p")
	local content, err = read_file(expanded)
	if not content then
		return nil, err
	end

	local ok, decoded = pcall(vim.json.decode, content)
	if not ok then
		return nil, decoded
	end

	return decoded, nil
end

local function copy_templates(list)
	if type(list) ~= "table" then
		return nil
	end
	return vim.deepcopy(list)
end

local function normalize_spec(data)
	if type(data) ~= "table" then
		return {}
	end

	local normalized = vim.deepcopy(data)

	if normalized.templates == nil and type(normalized.defaultTemplates) == "table" then
		normalized.templates = copy_templates(normalized.defaultTemplates)
	elseif normalized.defaultTemplates == nil and type(normalized.templates) == "table" then
		normalized.defaultTemplates = copy_templates(normalized.templates)
	end

	if normalized.defaultHardLimit == nil and normalized.hardLimit ~= nil then
		normalized.defaultHardLimit = normalized.hardLimit
	elseif normalized.hardLimit == nil and normalized.defaultHardLimit ~= nil then
		normalized.hardLimit = normalized.defaultHardLimit
	end

	if normalized.defaultParentMenuTitle == nil and normalized.parentMenuTitle ~= nil then
		normalized.defaultParentMenuTitle = normalized.parentMenuTitle
	elseif normalized.parentMenuTitle == nil and normalized.defaultParentMenuTitle ~= nil then
		normalized.parentMenuTitle = normalized.defaultParentMenuTitle
	end

	if type(normalized.defaultTemplates) == "table" then
		local first = normalized.defaultTemplates[1]
		if type(first) == "table" then
			if normalized.defaultTemplateUrl == nil and type(first.url) == "string" then
				normalized.defaultTemplateUrl = first.url
			end
			if normalized.defaultQueryTemplate == nil and type(first.queryTemplate) == "string" then
				normalized.defaultQueryTemplate = first.queryTemplate
			end
		end
	end
	return normalized
end

local function resolve_spec()
	if override_spec then
		return clone(override_spec)
	end

	if override_path then
		local data, err = load_from_json(override_path)
		if not data then
			error(("chatgpt_search_templater: failed to load spec from %s: %s"):format(override_path, err))
		end
		return normalize_spec(data)
	end

	return normalize_spec(spec_data)
end

---@param path string|nil
function M.set_spec_path(path)
	if path == nil or path == "" then
		override_path = nil
	else
		override_path = path
	end
	override_spec = nil
	cached_spec = nil
end

---@param data table|nil
function M.set_spec_data(data)
	if data == nil then
		override_spec = nil
	elseif type(data) ~= "table" then
		error("chatgpt_search_templater: spec data must be a table")
	else
		override_spec = normalize_spec(data)
	end
	cached_spec = nil
end

---@return table
function M.load()
	if cached_spec then
		return cached_spec
	end

	cached_spec = resolve_spec()
	return cached_spec
end

---@return table
function M.default_templates()
	local spec = M.load()
	return clone(spec.defaultTemplates or {})
end

---@return table
function M.custom_template()
	local spec = M.load()
	return clone(spec.customQueryTemplate)
end

---@return table
function M.placeholders()
	local spec = M.load()
	return clone(spec.placeholders or {})
end

---@return table
function M.model_options()
	local spec = M.load()
	return clone(spec.templateModelOptions or {})
end

return M
