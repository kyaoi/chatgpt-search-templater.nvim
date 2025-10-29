local M = {}

function M.run()
  local plugin = require('chatgpt_search_templater')
  local payload = plugin.setup()

  assert(type(payload) == 'table', 'setup should return a table')
  assert(type(payload.spec) == 'table', 'spec payload is required')
  assert(type(payload.placeholders) == 'table', 'placeholders should be a list')
  assert(type(payload.default_templates) == 'table', 'default templates should be a list')
  assert(type(payload.spec.templates) == 'table', 'spec templates should be a list')
  assert(payload.spec.hardLimit == 3000, 'default hard limit should be 3000')

  local json_spec = {
    hardLimit = 3000,
    parentMenuTitle = 'ChatGPTで検索',
    templates = {
      {
        id = 'template-1',
        label = '日本語訳',
        url = 'https://chatgpt.com/?q={TEXT}',
        queryTemplate = '{TEXT}',
        enabled = true,
        hintsSearch = true,
        temporaryChat = false,
        model = 'gpt-5-thinking',
      },
      {
        id = 'template-2',
        label = '学習',
        url = 'https://chatgpt.com/?q={TEXT}',
        queryTemplate = '{TEXT}',
        enabled = false,
        hintsSearch = true,
        temporaryChat = false,
        model = 'gpt-5-thinking',
      },
    },
  }

  local json_payload = plugin.setup({ spec_data = json_spec })
  assert(#json_payload.default_templates == 2, 'JSON spec should expose two templates')
  assert(json_payload.spec.defaultTemplates[1].label == '日本語訳', 'first template should be 日本語訳')
  assert(json_payload.spec.templates[2].label == '学習', 'second template should be 学習')
  assert(json_payload.spec.parentMenuTitle == 'ChatGPTで検索', 'parentMenuTitle should be propagated')
  assert(json_payload.spec.hardLimit == 3000, 'hardLimit should be propagated')
  assert(type(json_payload.placeholders) == 'table', 'placeholders fallback to a table even when missing')
  assert(json_spec.templates[1].label == '日本語訳', 'setup should not mutate the provided spec')

  vim.notify('chatgpt-search-templater.nvim smoke test passed', vim.log.levels.INFO)
end

return M
