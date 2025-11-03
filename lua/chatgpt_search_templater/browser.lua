local M = {}

---既定ブラウザで URL を開きます。
---@param url string
---@return boolean success
function M.open(url)
	if type(url) ~= "string" or url == "" then
		return false
	end

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
		return false
	end

	return true
end

return M
