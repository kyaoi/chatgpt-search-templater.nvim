local M = {}

function M.run()
  local plugin = require('chatgpt_search_templater')
  local payload = plugin.setup()

  assert(type(payload) == 'table', 'setup should return a table')
  assert(type(payload.spec) == 'table', 'spec payload is required')
  assert(type(payload.placeholders) == 'table', 'placeholders should be a list')
  assert(type(payload.default_templates) == 'table', 'default templates should be a list')

  vim.notify('chatgpt-search-templater.nvim smoke test passed', vim.log.levels.INFO)
end

return M
