local M = {}

---ビジュアルモードの選択テキストを取得します。範囲が無効な場合は空文字を返します。
---@return string
function M.current_visual_text()
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

return M
