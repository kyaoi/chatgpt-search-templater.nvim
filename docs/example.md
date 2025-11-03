# Example Configuration for Search Templater

The following document illustrates the directory structure, Lua configuration, and JSON templates used by the plugin creator. These setups serve as an example to help others understand how to implement and adapt the `chatgpt-search-templater.nvim` plugin.

For a broader usage guide and troubleshooting tips, refer to the [Usage Guide](./usage.md).

For installation instructions and plugin highlights, visit the [README](../README.md).

## Directory Structure
The structure below shows how the plugin-related files are organized:

```
lua/plugins/utils/search-templater
├── plugin.lua   # Main Lua configuration file
└── template.json # JSON file defining the templates
```

## Lua Configuration
The Lua configuration example demonstrates how to set up the `chatgpt-search-templater.nvim` plugin. The `spec_path` specifies the path to the JSON file containing the templates:

```lua
return {
  "kyaoi/chatgpt-search-templater.nvim",
  branch = "develop",
  version = false,
  config = function()
    require("chatgpt_search_templater").setup({
      spec_path = vim.fn.stdpath("config") .. "/lua/plugins/utils/search-templater/template.json",
      query_input = {
        template = {
          model = "gpt-5-thinking",
          hintsSearch = true,
          temporaryChat = false,
        },
      },
    })
  end,
}
```

### Explanation:
- `spec_path`: Points to the `template.json` file where the templates are stored.
- `require("chatgpt_search_templater")`: Loads the plugin and applies the configuration specified in the `setup` function.

## JSON Template
The JSON file defines the templates used by the plugin. Each template specifies the behavior and context for the searches. Below is an example JSON configuration:

```json
{
  "hardLimit": 3000,
  "parentMenuTitle": "ChatGPTで検索",  // Title of the plugin menu in Japanese
  "templates": [
    {
      "id": "template-1",
      "label": "日本語翻訳",  // Template for Japanese translation

      "url": "https://chatgpt.com/?q={TEXT}",
      "queryTemplate": "以下の文章を日本語訳してください。\nまたこの中で使われている単語や熟語について解説するとともに、文中の語句で簡単な物語を作成してください。\n\n{TEXT}",
      "enabled": true,
      "hintsSearch": true,
      "temporaryChat": false,
      "model": "gpt-5-thinking"
    },
    {
      "id": "template-2",
      "label": "学習",  // Template for learning-focused explanations
      "url": "https://chatgpt.com/?q={TEXT}",
      "queryTemplate": "以下の文章について初学者にもわかるように丁寧に解説してください。\nまた、合わせてこの内容に関する抑えておいたほうがいいことなどあれば教えて下さい。\n\n{TEXT}",

      "default": true,
      "enabled": true,

      "hintsSearch": true,
      "temporaryChat": false,
      "model": "gpt-5-thinking"
    },
    {
      "id": "template-c0536ce9-da63-4281-a0a9-47828c38c35d",
      "label": "英語翻訳",  // Template for English translation
      "url": "https://chatgpt.com/?q={TEXT}",
      "queryTemplate": "以下の文章を英語訳してください。\nまた、この中で使われている単語や文法のワンポイント解説をお願いします。\n\n{TEXT}",
      "enabled": true,
      "hintsSearch": false,
      "temporaryChat": true,
      "model": "gpt-5"
    }
  ]
}
```

### Explanation of Key Fields:
- `hardLimit`: Maximum allowed characters for processing.
- `parentMenuTitle`: Title displayed in the plugin's menu.
- `templates`: Array of templates for different use cases.
  - `id`: A unique identifier for each template.
  - `label`: The name of the template displayed in the menu.
  - `url`: The base URL for the search query.
  - `queryTemplate`: The template for the query, where `{TEXT}` is replaced with the user's input.
  - `enabled`: Indicates whether the template is active.
  - `hintsSearch`: Specifies whether search hints are enabled.
  - `temporaryChat`: Determines if the context is reset after the query.
  - `model`: The AI model used for processing.

For more advanced setup and integration tips, revisit the [Usage Guide](./usage.md).
