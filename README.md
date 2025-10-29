# chatgpt-search-templater.nvim

Neovim companion for the ChatGPT Search Templater Chrome extension. Use a visual
selection to open ChatGPT with either an interactive template picker or a
pre-selected default template.

:::tip
Parts of this plugin were originally generated with AI assistants (OpenAI Codex
and GitHub Copilot). The code has been curated, but feedback and PRs are still
welcome.
:::

## Highlights

- Visual-mode only workflow that streams the current selection into ChatGPT.
- Shares the same template specification as the Chrome extension, including
  placeholder replacement and default templates.
- Picks a template from a `vim.ui.select` menu or jumps straight to the default
  template via a dedicated keymap.
- Uses the platform-native browser opener (`xdg-open`, `open`, `wslview`,
  `cmd.exe /c start`).

## Requirements

- Neovim 0.8 or later with `vim.json` support.
- A browser opener available on your system (`xdg-open`, `open`, `wslview`, or
  Windows `start`).
- (Optional) A JSON file that mirrors the Chrome extension template schema when
  you want to override the bundled spec.

## Installation

Example configuration with [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
  "kyaoi/chatgpt-search-templater.nvim",
  config = function()
    require("chatgpt_search_templater").setup({
      spec_path = vim.fn.stdpath("config") .. "/lua/plugins/utils/chatgpt_search_templater/template.json",
    })
  end,
}
```

## Quick Start

```lua
require("chatgpt_search_templater").setup({
  spec_path = vim.fn.stdpath("config") .. "/chatgpt/spec.json", -- optional
  keymaps = {
    visual = "<leader>cg",         -- template picker
    default_visual = "<leader>cG", -- skip picker, use default template
  },
})
```

> **Note**
> `spec_path` should point to an absolute path. Use helpers such as
> `vim.fn.stdpath()` to avoid relative-path pitfalls.

### Template Specification

Both `spec_path` and `spec_data` accept the same schema as the Chrome extension.
The plugin normalises the table so that `{TEXT}` and any custom placeholder
strings are replaced consistently.

```json
{
  "hardLimit": 3000,
  "parentMenuTitle": "ChatGPTで検索",
  "templates": [
    {
      "id": "template-1",
      "label": "学習サポート",
      "url": "https://chatgpt.com/?q={TEXT}",
      "queryTemplate": "この内容を初学者向けに解説してください。\n\n{TEXT}",
      "default": true,
      "enabled": true
    },
    {
      "id": "template-2",
      "label": "日本語翻訳",
      "url": "https://chatgpt.com/?q={TEXT}",
      "queryTemplate": "以下の文章を日本語訳してください。\n\n{TEXT}",
      "enabled": true
    }
  ]
}

```

- Mark a template with `"default": true` (or `"isDefault": true`) to make it
  the first candidate everywhere, including the quick-launch keymap.
- When nothing is marked, the first enabled template becomes the default.
- The plugin falls back to the bundled spec under
  `lua/chatgpt_search_templater/spec_data.lua` when no overrides are provided.

### Default Keymaps

| Mode   | Mapping        | Behaviour                                          |
|--------|----------------|----------------------------------------------------|
| Visual | `<leader>cg`   | Open a template picker, then launch ChatGPT.       |
| Visual | `<leader>cG`   | Bypass the picker and use the default template.    |

Keymaps are only registered when `use_default_keymaps` is `true` (the default).
Set it to `false` to opt out entirely.

### Customising Keymaps

```lua
require("chatgpt_search_templater").setup({
  use_default_keymaps = true, -- toggle the auto-registration behaviour
  keymaps = {
    visual = "gs",         -- picker
    default_visual = "gS", -- default template
    force = false,          -- respect existing user mappings
  },
})
```

### Accessing the Spec Programmatically

`setup()` returns a payload containing the resolved specification along with
helper data that mirrors the Chrome extension:

```lua
local templater = require("chatgpt_search_templater")
local payload = templater.setup()

print(vim.inspect(payload.spec))              -- full spec table
print(vim.inspect(payload.default_templates)) -- enabled templates list
print(vim.inspect(payload.placeholders))      -- available placeholder tokens
```

Use this when building additional UI around the shared template data.

## Documentation

For more details, check the following documentation files:

- [Example Configuration](docs/example.md): Detailed directory and JSON examples.
- [Usage Guide](docs/usage.md): Step-by-step setup instructions.
- Japanese Documentation: [README.ja.md](README.ja.md) and [Usage Guide (Japanese)](docs/usage.ja.md).
