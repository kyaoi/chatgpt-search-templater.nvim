local utils = require("chatgpt_search_templater.utils")
local selection = require("chatgpt_search_templater.selection")
local templates = require("chatgpt_search_templater.templates")
local query_input = require("chatgpt_search_templater.query_input")
local browser = require("chatgpt_search_templater.browser")

local M = {}

local applied = {}

local function clear_applied()
	for _, km in ipairs(applied) do
		pcall(vim.keymap.del, km.mode, km.lhs)
	end
	applied = {}
end

local function notify(level, message)
	vim.notify("chatgpt-search-templater: " .. message, level)
end

local function warn(message)
	notify(vim.log.levels.WARN, message)
end

local function err(message)
	notify(vim.log.levels.ERROR, message)
end

local function format_template_label(template)
	if type(template) ~= "table" then
		return ""
	end
	return template.label or template.id or template.url or "<unnamed template>"
end

local function select_default_template(payload)
	return templates.select_default(payload.spec, payload.default_templates)
end

local function open_template(payload, template, text)
	if type(template) ~= "table" then
		warn("no template resolved for the action.")
		return
	end

	local rendered_query = templates.render_query(payload.spec, template, text)
	local trimmed_query = utils.trim(rendered_query)
	if trimmed_query == "" then
		warn("resolved query is empty.")
		return
	end

	local url, build_err = templates.build_url(payload.spec, template, trimmed_query)
	if not url then
		err(build_err and ("failed to build URL (" .. build_err .. ").") or "failed to resolve a URL template.")
		return
	end

	browser.open(url)
end

local function open_default_with_text(payload, text)
	local cleaned = utils.trim(text)
	if cleaned == "" then
		warn("search text is empty.")
		return
	end

	local template = select_default_template(payload)
	if not template then
		warn("no default template available.")
		return
	end

	open_template(payload, template, cleaned)
end

local function open_with_text(payload, text)
	local cleaned = utils.trim(text)
	if cleaned == "" then
		warn("search text is empty.")
		return
	end

	local enabled_templates = templates.collect_enabled(payload.default_templates)
	if #enabled_templates == 0 then
		open_template(payload, select_default_template(payload), cleaned)
		return
	end

	if #enabled_templates == 1 then
		open_template(payload, enabled_templates[1], cleaned)
		return
	end

	vim.ui.select(enabled_templates, {
		prompt = "Select ChatGPT template",
		format_item = format_template_label,
	}, function(choice)
		if choice then
			open_template(payload, choice, cleaned)
		end
	end)
end

local function build_input_template(base_template, overrides, query_template)
	local template = base_template and vim.deepcopy(base_template) or {}
	template.queryTemplate = query_template

	if type(overrides) ~= "table" then
		return template
	end

	local field_aliases = {
		label = { "label" },
		id = { "id" },
		url = { "url" },
		model = { "model" },
		hintsSearch = { "hintsSearch", "hints_search" },
		temporaryChat = { "temporaryChat", "temporary_chat" },
	}

	for field, keys in pairs(field_aliases) do
		for _, key in ipairs(keys) do
			if overrides[key] ~= nil then
				template[field] = overrides[key]
				break
			end
		end
	end

	return template
end

local function open_with_input(options, payload, text)
	local cleaned = utils.trim(text)
	local query_input_opts = options.query_input or {}

	local input_opts = {
		title = query_input_opts.title or "ChatGPT Query",
	}
	if type(query_input_opts.border) == "string" then
		input_opts.border = query_input_opts.border
	end
	if type(query_input_opts.width) == "number" then
		input_opts.width = query_input_opts.width
	end
	if type(query_input_opts.height) == "number" then
		input_opts.height = query_input_opts.height
	end
	if type(query_input_opts.prompt) == "string" and query_input_opts.prompt ~= "" then
		input_opts.prompt = query_input_opts.prompt
	end
	if type(query_input_opts.preset) == "string" and query_input_opts.preset ~= "" then
		input_opts.preset = query_input_opts.preset
	end

	query_input.open(input_opts, function(query)
		if query == nil then
			return
		end

		local query_text = utils.trim(query)
		if query_text == "" then
			warn("search query is empty.")
			return
		end

		local append_selection = query_input_opts.append_selection
		if append_selection == nil then
			append_selection = true
		end

		local final_template = query_text
		if append_selection and not final_template:find("{TEXT}", 1, true) then
			local separator = type(query_input_opts.separator) == "string" and query_input_opts.separator or "\n\n"
			final_template = final_template .. separator .. "{TEXT}"
		end

		local overrides = type(query_input_opts.template) == "table" and query_input_opts.template or nil
		local template = build_input_template(select_default_template(payload), overrides, final_template)

		local placeholder_text = cleaned
		if utils.is_empty(placeholder_text) and type(query_input_opts.fallback_text) == "string" then
			placeholder_text = query_input_opts.fallback_text
		end
		placeholder_text = placeholder_text or ""

		open_template(payload, template, placeholder_text)
	end)
end

local function apply_mapping(mode, lhs, callback, desc, force)
	if not lhs or lhs == "" then
		return
	end
	if not force and vim.fn.mapcheck(lhs, mode) ~= "" then
		warn(("skipped default keymap %s in %s-mode because it is already defined."):format(lhs, mode))
		return
	end

	vim.keymap.set(mode, lhs, callback, { desc = desc, silent = true })
	applied[#applied + 1] = { mode = mode, lhs = lhs }
end

---@param options table
---@param payload table
function M.apply(options, payload)
	clear_applied()

	if not options.use_default_keymaps then
		return
	end

	local keymap_opts = options.keymaps or {}
	local visual_key = keymap_opts.visual
	local default_visual_key = keymap_opts.default_visual
	local query_input_key = keymap_opts.query_input
	local force = keymap_opts.force == true

	if type(visual_key) == "string" and visual_key ~= "" then
		apply_mapping("x", visual_key, function()
			open_with_text(payload, selection.current_visual_text())
		end, "ChatGPT search (visual selection)", force)
	end

	if type(default_visual_key) == "string" and default_visual_key ~= "" then
		apply_mapping("x", default_visual_key, function()
			open_default_with_text(payload, selection.current_visual_text())
		end, "ChatGPT search (default template, visual selection)", force)
	end

	if type(query_input_key) == "string" and query_input_key ~= "" then
		apply_mapping("x", query_input_key, function()
			open_with_input(options, payload, selection.current_visual_text())
		end, "ChatGPT search (input query)", force)
	end
end

return M
