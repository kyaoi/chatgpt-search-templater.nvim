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

You can also mirror the Chrome extension JSON format directly. For example,
create a JSON file with the following contents:

```json
{
  "hardLimit": 3000,
  "parentMenuTitle": "ChatGPTで検索",
  "templates": [
    {
      "id": "template-1",
      "label": "日本語訳",
      "url": "https://chatgpt.com/?q={TEXT}",
      "queryTemplate": "以下の文章を日本語訳してください。 またこの中で使われている単語や熟語について解説するとともに、文中の語句で簡単な物語を作成してください。\n\n{TEXT}",
      "default": true,
      "enabled": true,
      "hintsSearch": true,
      "temporaryChat": false,
      "model": "gpt-5-thinking"
    },
    {
      "id": "template-2",
      "label": "学習",
      "url": "https://chatgpt.com/?q={TEXT}",
      "queryTemplate": "以下の文章について初学者にもわかるように丁寧に解説してください。 また、合わせてこの内容に関する抑えておいたほうがいいことなどあれば教えて下さい。\n\n{TEXT}",
      "enabled": false,
      "hintsSearch": true,
      "temporaryChat": false,
      "model": "gpt-5-thinking"
    }
  ]
}
```

Then point the plugin at it:

```lua
require('chatgpt_search_templater').setup({
  spec_path = vim.fn.stdpath('config') .. '/chatgpt/spec.json',
})
```

Templates marked with `"default": true` (or `"isDefault": true`) are
prioritised by the quick-launch keymap. When nothing is marked, the first
enabled template is used.

`setup()` also installs a default keymap that opens the first enabled template in
your browser when you are in visual mode. A separate key skips the picker and
launches the template marked as default (`"default": true` or `"isDefault": true`):

```text
Visual (picker): <leader>cg
Visual (default): <leader>cG
```

Normal mode での検索はサポートしていません。必ずビジュアル選択から実行してください。

Disable it entirely with `use_default_keymaps = false`, or override the bindings:

```lua
require('chatgpt_search_templater').setup({
  keymaps = {
    visual = '<leader>qs',
    default_visual = '<leader>qS',
  },
})
```
