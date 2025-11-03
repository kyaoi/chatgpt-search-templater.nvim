# サーチテンプレーターの設定例

このドキュメントでは、プラグイン作成者が実際に使用しているディレクトリ構造、Lua設定、およびJSONテンプレートを示しています。これらの設定例は、`chatgpt-search-templater.nvim`プラグインを実装し適応させる方法を理解するのに役立ちます。

## ディレクトリ構造
以下は、プラグイン関連ファイルがどのように整理されているかを示した構造です：

```
lua/plugins/utils/search-templater
├── plugin.lua   # メインのLua設定ファイル
└── template.json # テンプレートを定義するJSONファイル
```

## Lua設定
以下のLua設定例は、`chatgpt-search-templater.nvim`プラグインをどのようにセットアップするかを示しています。`spec_path`はテンプレートが含まれるJSONファイルへのパスを指定します：

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

### 説明：
- `spec_path`: テンプレートが保存されている`template.json`ファイルを指します。
- `require("chatgpt_search_templater")`: プラグインを読み込み、`setup`関数で指定された設定を適用します。

## JSONテンプレート
JSONファイルは、プラグインで使用されるテンプレートを定義します。各テンプレートは検索の動作とコンテキストを指定します。以下はJSON設定の例です：

```json
{
  "hardLimit": 3000,
  "parentMenuTitle": "ChatGPTで検索",  // プラグインメニューのタイトル
  "templates": [
    {
      "id": "template-1",
      "label": "日本語翻訳",  // 日本語翻訳用テンプレート

      "url": "https://chatgpt.com/?q={TEXT}",
      "queryTemplate": "以下の文章を日本語訳してください。\nまたこの中で使われている単語や熟語について解説するとともに、文中の語句で簡単な物語を作成してください。\n\n{TEXT}",
      "enabled": true,
      "hintsSearch": true,
      "temporaryChat": false,
      "model": "gpt-5-thinking"
    },
    {
      "id": "template-2",
      "label": "学習",  // 学習向け解説テンプレート
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
      "label": "英語翻訳",  // 英語翻訳用テンプレート
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

### 主なフィールドの説明：
- `hardLimit`: 処理可能な最大文字数。
- `parentMenuTitle`: プラグインメニューに表示されるタイトル。
- `templates`: さまざまなユースケース用のテンプレート配列。
  - `id`: 各テンプレートの一意の識別子。
  - `label`: メニューに表示されるテンプレートの名前。
  - `url`: 検索クエリのベースURL。
  - `queryTemplate`: クエリのテンプレート。`{TEXT}`はユーザー入力で置き換えられます。
  - `enabled`: テンプレートが有効かどうかを示します。
  - `hintsSearch`: 検索ヒントが有効かどうかを指定します。
  - `temporaryChat`: クエリ後にコンテキストをリセットするかどうかを決定します。
  - `model`: 処理に使用するAIモデル。

