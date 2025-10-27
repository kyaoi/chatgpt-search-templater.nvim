local M = {}

local defaults = {
  spec_path = nil,
  spec_data = nil,
}

local options = vim.deepcopy(defaults)

---@param opts table|nil
---@return table
function M.set(opts)
  if opts == nil then
    options = vim.deepcopy(defaults)
    return options
  end

  options = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts)
  return options
end

---@return table
function M.get()
  return options
end

return M
