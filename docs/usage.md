# Usage

The plugin exposes a single entry point:

```lua
local templater = require('chatgpt_search_templater')
local payload = templater.setup({
  -- Both spec_path and spec_data are optional.
  spec_path = vim.fn.stdpath('config') .. '/chatgpt/spec.json',
})

print(vim.inspect(payload.placeholders))
print(vim.inspect(payload.default_templates))
```

`payload.spec` mirrors the template spec used by the Chrome extension. The
plugin resolves the spec in the following order:

1. `spec_data` passed to `setup()`
2. JSON content loaded via `spec_path`
3. Bundled spec from `lua/chatgpt_search_templater/spec_data.lua`

Use `payload.placeholders` to render placeholder tooltips or validations and
`payload.default_templates` to seed UI components inside Neovim.

When you need to override the spec directly from Lua, pass a `spec_data` table:

```lua
require('chatgpt_search_templater').setup({
  spec_data = {
    placeholders = { '{TEXT}' },
    defaultTemplates = {
      { id = 'custom', label = 'Custom', url = 'https://chatgpt.com/?q={TEXT}', queryTemplate = '{TEXT}', enabled = true },
    },
  },
})
```
