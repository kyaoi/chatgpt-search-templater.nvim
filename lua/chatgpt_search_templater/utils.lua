local M = {}

---余分な空白を取り除いた文字列を返します。nil の場合は空文字列。
---@param text string|nil
---@return string
function M.trim(text)
	local value = text or ""
	value = value:gsub("^%s+", "")
	value = value:gsub("%s+$", "")
	return value
end

---トリム後に空文字かどうかを判定します。
---@param text string|nil
---@return boolean
function M.is_empty(text)
	return M.trim(text) == ""
end

---URL エンコード済みの文字列を返します。
---@param text string|nil
---@return string
function M.url_encode(text)
	local value = text or ""
	value = value:gsub("\r\n", "\n")
	value = value:gsub("\r", "\n")
	value = value:gsub("([^%w%-_.~ ])", function(char)
		return string.format("%%%02X", char:byte())
	end)
	value = value:gsub(" ", "%%20")
	return value
end

---テンプレート内のプレースホルダーを置き換えます。
---@param template string
---@param replacement string
---@param placeholders table|nil
---@return string
function M.replace_placeholders(template, replacement, placeholders)
	if template == nil or template == "" then
		return template
	end

	local result = template
	if type(placeholders) == "table" then
		for _, placeholder in ipairs(placeholders) do
			if type(placeholder) == "string" and placeholder ~= "" then
				result = result:gsub(vim.pesc(placeholder), function()
					return replacement
				end)
			end
		end
	end

	result = result:gsub("{TEXT}", function()
		return replacement
	end)

	return result
end

---空でないトリム済み文字列を返します。空白のみの場合は nil。
---@param value any
---@return string|nil
function M.normalize_string(value)
	if type(value) ~= "string" then
		return nil
	end

	local trimmed = M.trim(value)
	if trimmed == "" then
		return nil
	end

	return trimmed
end

return M
