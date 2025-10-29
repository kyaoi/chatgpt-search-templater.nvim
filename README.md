# chatgpt-search-templater.nvim

Parts of this plugin were generated with AI assistants (OpenAI Codex and GitHub Copilot). I’ve reviewed and adapted the code, but there may still be rough edges. Feedback and PRs are welcome.

Neovim plugin companion for the Chrome extension. It ships with the same
template specification baked into `lua/chatgpt_search_templater/spec_data.lua`
and exposes helpers for reading placeholders and default templates inside
Neovim automation.

## Features

- Consume the shared ChatGPT template specification without depending on
  TypeScript assets.
- Provide a `setup()` entry point that exposes templates/placeholders.

## Installation

Add the repository to your Neovim plugin manager. Example using
[`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
  'kyaoi/chatgpt-search-templater',
  dir = vim.fn.stdpath('config') .. '/plugins/chatgpt-search-templater',
  config = function()
    require('chatgpt_search_templater').setup()
  end,
}
```

## Configuration

By default the plugin consumes the bundled spec from
`lua/chatgpt_search_templater/spec_data.lua`, so no extra files are needed.
When you need to override the templates you have two options. The resolution
order is:

1. `spec_data` option (highest priority)
2. `spec_path` option (JSON file)
3. Bundled spec (fallback)

### Load a JSON file

Pass an explicit path to a JSON file that matches the bundled structure:

```lua
require('chatgpt_search_templater').setup({
  spec_path = '/path/to/spec.json',
})
```

### Provide the spec directly from Lua

You can also provide the full spec table when you prefer to keep everything in
Lua code:

```lua
require('chatgpt_search_templater').setup({
  spec_data = {
    placeholders = { '{TEXT}' },
    defaultTemplates = { ... },
  },
})
```

### Default keymaps

`setup()` registers a default mapping that prompts you to choose from the
enabled templates (falling back to the only available one) and then opens the
selection in your browser using the word under the cursor (normal mode) or the
current visual selection:

- Normal / Visual: `<leader>cg`

Use `use_default_keymaps = false` to disable the mapping entirely, or override
the key combinations:

```lua
require('chatgpt_search_templater').setup({
  keymaps = {
    normal = '<leader>qs',
    visual = '<leader>qs',
    force = true, -- set to true when you want to override user mappings
  },
})
```
