local script = debug.getinfo(1, 'S').source
if script:sub(1, 1) == '@' then
  script = script:sub(2)
end

local test_dir = vim.fn.fnamemodify(script, ':p:h')
local plugin_root = vim.fn.fnamemodify(test_dir, ':h')

vim.opt.runtimepath:append(plugin_root)

vim.g.mapleader = ' '
