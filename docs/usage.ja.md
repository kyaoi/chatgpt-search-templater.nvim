# Usage Guide（日本語）

`chatgpt-search-templater.nvim` を Neovim で利用する手順と設定方法をまとめています。

## 1. 基本セットアップ

1. 任意のプラグインマネージャーで本プラグインをインストールします（README 参照）。
2. 初期化時に `setup()` を呼びます。以下はバンドル済みテンプレートと既定キーマップをそのまま利用する例です。

   ```lua
   require("chatgpt_search_templater").setup()
   ```

3. テキストをビジュアル選択し、`<leader>cg` でテンプレートを選択、`<leader>cG` で既定テンプレートへ即ジャンプできます。

本プラグインが登録するキーマップはビジュアルモードのみです。別のキーを使いたい場合は後述の `keymaps` オプションで上書きしてください。

## 2. テンプレートの提供方法

Chrome 拡張と同じ仕様のテンプレート定義を、Lua テーブルまたは JSON ファイルで渡せます。

### 2.1 JSON（`spec_path`）を使う

```lua
require("chatgpt_search_templater").setup({
  spec_path = vim.fn.stdpath("config") .. "/chatgpt/spec.json",
})
```

- `spec_path` は必ず絶対パスで指定してください。
- JSON の構造は Chrome 拡張のテンプレート仕様と同一です。

### 2.2 Lua テーブル（`spec_data`）を使う

```lua
require("chatgpt_search_templater").setup({
  spec_data = {
    placeholders = { "{TEXT}" },
    defaultTemplates = {
      {
        id = "default",
        label = "クイック検索",
        url = "https://chatgpt.com/?prompt={TEXT}",
        queryTemplate = "要約してください:\n\n{TEXT}",
        default = true,
        enabled = true,
      },
    },
  },
})
```

`spec_data` と `spec_path` を同時に指定した場合は `spec_data` が優先されます。

## 3. テンプレートのフラグとプレースホルダー

- `default` / `isDefault`: クイック起動用キーマップやピッカーで最優先に利用されます。
- `enabled`: ピッカーで選択可能かどうかを制御します。`false` のテンプレートは無視されます。
- `queryTemplate`: `{TEXT}` や `placeholders` に登録された任意のプレースホルダーを利用できます。プラグイン側で余分な空白を削除した上で URL エンコードします。

## 4. キーマップ一覧

| キー           | モード | 説明                                 |
|----------------|--------|--------------------------------------|
| `<leader>cg`   | Visual | `vim.ui.select` を使ったテンプレート選択 |
| `<leader>cG`   | Visual | 既定テンプレートを即時実行              |

キーマップの自動登録を避けたい場合は `use_default_keymaps = false` を指定します。

```lua
require("chatgpt_search_templater").setup({
  use_default_keymaps = false,
})
```

## 5. インタラクティブ入力ウィンドウ

`query_input` オプションを設定すると、ビジュアル選択と併用できるフローティング入力ウィンドウを調整できます。入力内容と `{TEXT}` を組み合わせ、起動ごとに一時テンプレートを生成します。

```lua
local chatgpt_search_templater = require("chatgpt_search_templater")
local models = chatgpt_search_templater.models
chatgpt_search_templater.setup({
  query_input = {
    title = "ChatGPT Query",
    border = "rounded",
    width = 80,
    height = 16,
    prompt = "必要内容を記述してください",
    preset = "Please help with:\n",
    append_selection = true,
    separator = "\n\n",
    fallback_text = "TODO:",
    template = {
      url = "https://chatgpt.com/?prompt={TEXT}",
      model = models[2],
      hintsSearch = true,
      temporaryChat = false,
    },
  },
})
```

- `append_selection` が `true` の場合、入力に `{TEXT}` が含まれていなければ `separator` で連結して追記します。
- `fallback_text` はビジュアル選択が空だったときに `{TEXT}` として利用されます。
- `template` に含めたキーは、この起動時に使用するテンプレート設定を上書きします。

## 6. `setup()` の戻り値を活用する

`setup()` はテンプレート仕様を含むテーブルを返します。周辺ツールで再利用したい場合に便利です。

```lua
local payload = require("chatgpt_search_templater").setup()

print(vim.inspect(payload.spec))              -- 正規化済みテンプレート
print(vim.inspect(payload.default_templates)) -- 有効テンプレート一覧
print(vim.inspect(payload.placeholders))      -- プレースホルダー一覧
```

## 7. トラブルシューティング

- **「search text is empty」と表示される**: ビジュアル選択が空になっていないか確認してください。空白のみの場合も弾かれます。
- **テンプレートの順序が意図通りでない**: 優先したいテンプレートに `"default": true` を付与してください。複数ある場合は最初の `enabled = true` が使われます。
- **ブラウザが開かない**: `xdg-open` / `open` / `wslview` / `start` などが PATH 上にあるか確認してください。

より詳しい情報は README（英語 / 日本語）も併せて参照してください。
