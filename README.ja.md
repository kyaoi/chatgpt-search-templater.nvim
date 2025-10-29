# chatgpt-search-templater.nvim（日本語ドキュメント）

ChatGPT Search Templater Chrome 拡張機能の Neovim 連携プラグインです。ビジュアルモードの選択範囲を基に、テンプレート選択ダイアログまたは既定テンプレートを介して ChatGPT を開きます。

> **補足**
> このプラグインの大部分ははAIアシスタント（OpenAI Codex / GitHub Copilot）により生成され、その後に人手で整備されています。
> そのため、コードが汚かったり間違った書き方をしている部分がある可能性があります。
> 改善提案やPRは大歓迎です！

## 特長

- ビジュアルモード専用のワークフローで、選択中のテキストを ChatGPT に即送信。
- Chrome 拡張と同じテンプレート仕様を利用し、プレースホルダー展開やデフォルトテンプレートにも対応。
- `vim.ui.select` ベースのテンプレートピッカーと、既定テンプレートへ直接飛ぶキーマップを両立。
- `xdg-open` / `open` / `wslview` / `cmd.exe /c start` など、OS 標準のブラウザ起動コマンドを呼び出し。

## 動作要件

- Neovim 0.8 以上（`vim.json` API が利用可能であること）。
- ブラウザ起動コマンドが利用可能な環境（macOS: `open`、Linux: `xdg-open`、Windows: `start`、WSL: `wslview` 推奨）。
- （任意）テンプレートを上書きしたい場合は、Chrome 拡張の仕様に準じた JSON ファイル。

## インストール例

[`lazy.nvim`](https://github.com/folke/lazy.nvim) を使った設定例です。

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

## クイックスタート

```lua
require("chatgpt_search_templater").setup({
  spec_path = vim.fn.stdpath("config") .. "/chatgpt/spec.json", -- 任意
  keymaps = {
    visual = "<leader>cg",         -- テンプレート選択ダイアログ
    default_visual = "<leader>cG", -- デフォルトテンプレートを即起動
  },
})
```

> **注意**
> `spec_path` は絶対パスで指定してください。`vim.fn.stdpath()` などを併用すると安全です。

### テンプレート仕様

`spec_path` と `spec_data` のどちらにも、Chrome 拡張と同じ JSON 構造（Lua テーブル）を渡せます。プラグイン側で正規化され、`{TEXT}` や任意プレースホルダーが正しく置換されます。

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

- `"default": true`（または `"isDefault": true`）を付けたテンプレートが最優先で利用されます。
- フラグが設定されていない場合は、最初に `enabled = true` のテンプレートが既定になります。
- 何も指定しない場合は、`lua/chatgpt_search_templater/spec_data.lua` に同梱されているテンプレートを利用します。

### デフォルトキーマップ

| モード | キー            | 動作内容                               |
|--------|-----------------|----------------------------------------|
| Visual | `<leader>cg`    | テンプレート選択ダイアログを開く       |
| Visual | `<leader>cG`    | 選択ダイアログを飛ばし既定テンプレート |

`use_default_keymaps` が `true`（既定値）の場合のみ自動登録されます。不要なときは `false` にしてください。

### キーマップのカスタマイズ

```lua
require("chatgpt_search_templater").setup({
  use_default_keymaps = true, -- 自動登録を無効にしたい場合は false
  keymaps = {
    visual = "gs",         -- ピッカー用
    default_visual = "gS", -- 既定テンプレート用
    force = false,          -- 既存のユーザー設定を優先
  },
})
```

### 取得できる戻り値

`setup()` は Chrome 拡張と同じ仕様のテンプレート情報を返します。必要に応じて他の UI に流用できます。

```lua
local templater = require("chatgpt_search_templater")
local payload = templater.setup()

print(vim.inspect(payload.spec))              -- 正規化済みスペック
print(vim.inspect(payload.default_templates)) -- 利用可能テンプレート一覧
print(vim.inspect(payload.placeholders))      -- プレースホルダー一覧
```

## ドキュメント

- [Usage Guide (英語)](docs/usage.md)
- [README (英語)](README.md)
- [Usage Guide (日本語)](docs/usage.ja.md)

## ライセンス

MIT License（詳細は `LICENSE` を参照）。
