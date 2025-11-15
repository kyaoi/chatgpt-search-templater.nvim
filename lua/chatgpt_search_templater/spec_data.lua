local M = {}

M.models = {
	"gpt-5.1",
	"gpt-5.1-thinking",
	"gpt-5",
	"gpt-5-thinking",
	"custom",
}

local default_templates = {
	{
		id = "template-1",
		label = "標準検索",
		url = "https://chatgpt.com/?prompt={TEXT}",
		queryTemplate = "{TEXT}",
		enabled = true,
		hintsSearch = false,
		temporaryChat = false,
		model = M.models[1],
	},
	{
		id = "template-2",
		label = "Search + Temporary",
		url = "https://chatgpt.com/?prompt={TEXT}",
		queryTemplate = "{TEXT}",
		enabled = false,
		hintsSearch = true,
		temporaryChat = true,
		model = M.models[2],
	},
}

local custom_query_template = {
	label = "カスタムクエリ入力",
	url = "https://chatgpt.com/?prompt={TEXT}",
	queryTemplate = "{TEXT}",
	enabled = true,
	hintsSearch = true,
	temporaryChat = false,
	model = M.models[1],
}

M.spec = {
	placeholders = { "{選択した文字列}", "{TEXT}" },
	defaultTemplateUrl = "https://chatgpt.com/?prompt={TEXT}",
	defaultQueryTemplate = "{TEXT}",
	templateModelOptions = M.models,
	defaultHardLimit = 3000,
	hardLimit = 3000,
	defaultParentMenuTitle = "ChatGPTで検索",
	parentMenuTitle = "ChatGPTで検索",
	defaultTemplates = default_templates,
	templates = vim.deepcopy(default_templates),
	custom_query_template = custom_query_template,
	customQueryTemplate = vim.deepcopy(custom_query_template),
}

return M
