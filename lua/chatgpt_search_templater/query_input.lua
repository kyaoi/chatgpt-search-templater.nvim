local M = {}

---フローティングウィンドウでテキスト入力を受け付けます。
---@param opts table|nil
---@param on_submit fun(text:string|nil)
function M.open(opts, on_submit)
	opts = opts or {}
	assert(type(on_submit) == "function", "on_submit callback is required")

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = true
	vim.bo[buf].filetype = opts.filetype or "biginput"

	local columns, lines = vim.o.columns, vim.o.lines
	local width = opts.width or math.max(60, math.floor(columns * 0.6))
	local height = opts.height or math.max(10, math.floor(lines * 0.3))
	local row = math.max(0, math.floor((lines - height) / 2 - 1))
	local col = math.max(0, math.floor((columns - width) / 2))

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = opts.border or "rounded",
		title = opts.title or "Input",
		title_pos = "center",
		width = width,
		height = height,
		row = row,
		col = col,
		zindex = 200,
	})

	if win == 0 then
		vim.api.nvim_buf_delete(buf, { force = true })
		vim.notify("chatgpt-search-templater: failed to open input window", vim.log.levels.ERROR)
		return
	end

	local lines_init = {}
	if opts.prompt and #opts.prompt > 0 then
		table.insert(lines_init, opts.prompt)
		table.insert(lines_init, "")
	end
	if opts.preset and #opts.preset > 0 then
		for s in tostring(opts.preset):gmatch("([^\n]*)\n?") do
			if s ~= "" or #lines_init > 0 then
				table.insert(lines_init, s)
			end
		end
	end
	if #lines_init > 0 then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines_init)
	end

	local fired = false
	local function finish(text)
		if fired then
			return
		end
		fired = true
		pcall(vim.cmd, "stopinsert")
		local function close()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
		close()
		vim.schedule(function()
			on_submit(text)
		end)
	end

	local function submit()
		if not vim.api.nvim_buf_is_valid(buf) then
			return finish(nil)
		end
		local lines_content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		if opts.prompt and #lines_content > 0 and lines_content[1] == opts.prompt then
			table.remove(lines_content, 1)
			if #lines_content > 0 and lines_content[1] == "" then
				table.remove(lines_content, 1)
			end
		end
		finish(table.concat(lines_content, "\n"))
	end

	local function cancel()
		finish(nil)
	end

	vim.keymap.set({ "n", "i" }, "<C-s>", submit, { buffer = buf, silent = true })
	vim.keymap.set({ "n", "i" }, "<Esc>", cancel, { buffer = buf, silent = true })
	vim.keymap.set("n", "q", cancel, { buffer = buf, silent = true })

	local start_row = (#lines_init > 0) and #lines_init or 1
	vim.api.nvim_win_set_cursor(win, { start_row, 0 })
	vim.cmd("startinsert")
end

return M
