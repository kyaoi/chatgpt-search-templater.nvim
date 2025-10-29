local M = {}

local applied = {}

local function clear_applied()
	for _, km in ipairs(applied) do
		pcall(vim.keymap.del, km.mode, km.lhs)
	end
	applied = {}
end

local function url_encode(text)
	text = (text or "")
		:gsub("\r\n", "\n")
		:gsub("\r", "\n")
		:gsub("([^%w%-_%.~ ])", function(char)
			return string.format("%%%02X", char:byte())
		end)
		:gsub(" ", "%%20")

	return text
end

local function trim_text(text)
	local normalized = text or ""
	normalized = normalized:gsub("^%s+", "")
	normalized = normalized:gsub("%s+$", "")
	return normalized
end

local function collect_visual_selection()
	local bufnr = vim.api.nvim_get_current_buf()
	local mode = vim.fn.mode(1)
	local visual_mode = ""
	if mode:match("[vV\022]") then
		visual_mode = mode
	else
		local ok, last_mode = pcall(vim.fn.visualmode)
		if ok then
			visual_mode = last_mode or ""
		end
	end

	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	if start_pos[2] <= 0 or end_pos[2] <= 0 then
		local visual_start = vim.fn.getpos("v")
		local cursor_position = vim.api.nvim_win_get_cursor(0)
		if visual_start[2] > 0 then
			start_pos = { 0, visual_start[2], visual_start[3], 0 }
			end_pos = { 0, cursor_position[1], cursor_position[2] + 1, 0 }
		end
	end

	local start_row = start_pos[2]
	local start_col = start_pos[3]
	local end_row = end_pos[2]
	local end_col = end_pos[3]

	if start_row <= 0 or end_row <= 0 then
		return ""
	end

	if start_row > end_row or (start_row == end_row and start_col > end_col) then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end

	local linewise = visual_mode == "V"

	start_row = start_row - 1
	start_col = math.max(start_col - 1, 0)
	end_row = end_row - 1

	local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ""
	local end_col_exclusive = end_col
	if linewise then
		start_col = 0
		end_col_exclusive = #end_line
	elseif end_col_exclusive > #end_line then
		end_col_exclusive = #end_line
	end

	local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col_exclusive, {})
	return table.concat(lines, "\n")
end

local function replace_placeholders(template, value, placeholders)
	if not template or template == "" then
		return template
	end

	local result = template
	if type(placeholders) == "table" then
		for _, placeholder in ipairs(placeholders) do
			result = result:gsub(vim.pesc(placeholder), function()
				return value
			end)
		end
	end
	result = result:gsub("{TEXT}", function()
		return value
	end)
	return result
end

local function resolve_query_template(spec_payload, template)
	if type(template) == "table" then
		local candidate = template.queryTemplate
		if type(candidate) == "string" and candidate ~= "" then
			return candidate
		end
	end

	if spec_payload then
		local fallback = spec_payload.defaultQueryTemplate
		if type(fallback) == "string" and fallback ~= "" then
			return fallback
		end
	end

	return "{TEXT}"
end

local function render_query_text(spec_payload, template, text)
	local query_template = resolve_query_template(spec_payload, template)
	local placeholders = spec_payload and spec_payload.placeholders or {}
	return replace_placeholders(query_template, text, placeholders)
end

local function find_default_template(spec_payload)
	local list = spec_payload.defaultTemplates or spec_payload.templates or {}
	for _, template in ipairs(list) do
		if template.enabled == nil or template.enabled == true then
			return template
		end
	end
	return list[1]
end

local function build_url(spec_payload, encoded_text, template_override)
	local template = template_override or find_default_template(spec_payload) or {}
	local placeholders = spec_payload.placeholders or {}

	local url_template = template.url or spec_payload.defaultTemplateUrl
	if not url_template or url_template == "" then
		return nil
	end

	return replace_placeholders(url_template, encoded_text, placeholders)
end

local function format_template_label(template)
	if type(template) ~= "table" then
		return ""
	end

	return template.label or template.id or template.url or "<unnamed template>"
end

local function collect_enabled_templates(default_templates)
	local source = {}
	if type(default_templates) == "table" then
		for _, template in ipairs(default_templates) do
			if type(template) == "table" then
				if template.enabled == nil or template.enabled == true then
					table.insert(source, template)
				end
			end
		end
	end
	return source
end

local function open_url(url)
	local command
	if vim.fn.has("macunix") == 1 then
		command = { "open", url }
	elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
		command = { "cmd.exe", "/c", "start", "", url }
	elseif vim.fn.has("wsl") == 1 then
		if vim.fn.executable("wslview") == 1 then
			command = { "wslview", url }
		else
			command = { "cmd.exe", "/c", "start", "", url }
		end
	else
		command = { "xdg-open", url }
	end

	local job = vim.fn.jobstart(command, { detach = true })
	if job <= 0 then
		vim.notify(
			"chatgpt-search-templater: failed to open the browser. Please confirm that xdg-open (or an equivalent command) is available.",
			vim.log.levels.ERROR
		)
	end
end

local function apply_mapping(mode, lhs, callback, desc, force)
	if not lhs or lhs == "" then
		return
	end
	if not force and vim.fn.mapcheck(lhs, mode) ~= "" then
		vim.notify(
			("chatgpt-search-templater: skipped default keymap %s in %s-mode because it is already defined."):format(
				lhs,
				mode
			),
			vim.log.levels.WARN
		)
		return
	end

	vim.keymap.set(mode, lhs, callback, { desc = desc, silent = true })
	table.insert(applied, { mode = mode, lhs = lhs })
end

---@param options table
---@param payload table
function M.apply(options, payload)
	clear_applied()

	if not options.use_default_keymaps then
		return
	end

	local keymaps = options.keymaps or {}
	local normal_key = keymaps.normal
	local visual_key = keymaps.visual or normal_key
	local force = keymaps.force == true

	local function open_with_text(text)
		local cleaned = trim_text(text)
		if cleaned == "" then
			vim.notify("chatgpt-search-templater: search text is empty.", vim.log.levels.WARN)
			return
		end
		local enabled_templates = collect_enabled_templates(payload.default_templates)

		local function open_for_template(template)
			local rendered_query = render_query_text(payload.spec, template, cleaned)
			local trimmed_query = trim_text(rendered_query)
			if trimmed_query == "" then
				vim.notify("chatgpt-search-templater: resolved query is empty.", vim.log.levels.WARN)
				return
			end

			local encoded_query = url_encode(trimmed_query)
			local url = build_url(payload.spec, encoded_query, template)
			if not url then
				vim.notify("chatgpt-search-templater: failed to resolve a URL template.", vim.log.levels.ERROR)
				return
			end
			open_url(url)
		end

		if #enabled_templates <= 1 then
			open_for_template(enabled_templates[1])
			return
		end

		vim.ui.select(enabled_templates, {
			prompt = "Select ChatGPT template",
			format_item = format_template_label,
		}, function(choice)
			if not choice then
				return
			end
			open_for_template(choice)
		end)
	end

	if type(normal_key) == "string" and normal_key ~= "" then
		apply_mapping("n", normal_key, function()
			open_with_text(vim.fn.expand("<cword>"))
		end, "ChatGPT search (cursor word)", force)
	end

	if type(visual_key) == "string" and visual_key ~= "" then
		apply_mapping("x", visual_key, function()
			open_with_text(collect_visual_selection())
		end, "ChatGPT search (visual selection)", force)
	end
end

return M
