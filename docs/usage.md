# Usage Guide

This document explains how to configure and operate
`chatgpt-search-templater.nvim` from Neovim.

## 1. Basic Setup

1. Install the plugin with your preferred manager (see the README for examples).
2. Call `setup()` during startup. The simplest configuration mirrors the
   bundled template specification and registers the default keymaps:

   ```lua
   require("chatgpt_search_templater").setup()
   ```

3. Visually select text and press `<leader>cg` to choose a template, or
   `<leader>cG` to launch the default template immediately.

The plugin only binds visual-mode mappings. If you prefer alternative keys,
override them via the `keymaps` table.

### Reference:
For detailed examples of directory structure and configurations, consult the [Example Configuration](./example.md) document.

## 2. Providing Your Own Templates

You can supply the Chrome extension template specification either as Lua data or
as JSON.

### 2.1 JSON via `spec_path`

```lua
require("chatgpt_search_templater").setup({
  spec_path = vim.fn.stdpath("config") .. "/chatgpt/spec.json",
})
```

- Always resolve `spec_path` to an absolute path.
- The JSON schema matches the Chrome extension exactly.

### 2.2 Lua table via `spec_data`

```lua
require("chatgpt_search_templater").setup({
  spec_data = {
    placeholders = { "{TEXT}" },
    defaultTemplates = {
      {
        id = "default",
        label = "Quick lookup",
        url = "https://chatgpt.com/?q={TEXT}",
        queryTemplate = "Summarise:\n\n{TEXT}",
        default = true,
        enabled = true,
      },
    },
  },
})
```

When both `spec_data` and `spec_path` are provided, `spec_data` wins.

For detailed configuration examples, see the [Example Configuration](./example.md).

## 3. Template Flags and Placeholders

- `default` / `isDefault`: marks a template as the primary option for the quick
  launch keymap and the top entry in the picker.
- `enabled`: controls whether the template is selectable. Disabled templates are
  ignored unless you customise the picker yourself.
- `queryTemplate`: can reference `{TEXT}` or any placeholder listed under
  `placeholders`. The plugin resolves whitespace and replaces placeholders before
  encoding the URL.

## 4. Keymap Reference

| Mapping        | Mode   | Description                                  |
|----------------|--------|----------------------------------------------|
| `<leader>cg`   | Visual | Open the template picker (`vim.ui.select`).  |
| `<leader>cG`   | Visual | Use the default template immediately.        |

Set `use_default_keymaps = false` if you prefer to manage mappings manually.

```lua
require("chatgpt_search_templater").setup({
  use_default_keymaps = false,
})
```

## 5. Interactive Query Input

`query_input` tweaks the floating window used when you trigger the dedicated
mapping. It combines the current visual selection with additional text and
produces a one-off template on the fly.

```lua
require("chatgpt_search_templater").setup({
  query_input = {
    title = "ChatGPT Query",
    border = "rounded",
    width = 80,
    height = 16,
    prompt = "Describe what you need",
    preset = "Please help with:\n",
    append_selection = true,
    separator = "\n\n",
    fallback_text = "TODO:",
    template = {
      url = "https://chatgpt.com/?q={TEXT}",
      model = "gpt-5-thinking",
      hintsSearch = true,
      temporaryChat = false,
    },
  },
})
```

- `append_selection` appends `{TEXT}` (with `separator`) when your input does
  not already contain it. This keeps the selection attached to the query.
- `fallback_text` supplies `{TEXT}` when the selection is empty.
- Keys inside `template` override the resolved template for this launch only.

## 6. Consuming the Returned Payload

`setup()` returns a table with useful data:

```lua
local payload = require("chatgpt_search_templater").setup()

-- full spec (normalised)
print(vim.inspect(payload.spec))

-- list of enabled templates in selection order
print(vim.inspect(payload.default_templates))

-- available placeholders for validation tooling
print(vim.inspect(payload.placeholders))
```

This is handy when building custom pickers, status lines, or linting logic that
understands the shared template schema.

## 7. Troubleshooting

- **“search text is empty”**: ensure you have an active visual selection. The
  plugin trims whitespace and refuses to continue with empty input.
- **Templates appear in the wrong order**: add `"default": true` to the template
  you want to prioritise. Enabled defaults are always first.
- **Browser does not open**: confirm that your platform command (`xdg-open`,
  `open`, `wslview`, or `start`) is accessible from `$PATH`.

For additional context, refer to the README or the Japanese documentation.
