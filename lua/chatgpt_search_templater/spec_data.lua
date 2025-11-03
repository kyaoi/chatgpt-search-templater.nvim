local default_templates = {
	{
		id = "template-1",
		label = "標準検索",
		url = "https://chatgpt.com/?q={TEXT}",
		queryTemplate = "{TEXT}",
		enabled = true,
		hintsSearch = false,
		temporaryChat = false,
		model = "gpt-5",
	},
	{
		id = "template-2",
		label = "Search + Temporary",
		url = "https://chatgpt.com/?q={TEXT}",
		queryTemplate = "{TEXT}",
		enabled = false,
		hintsSearch = true,
		temporaryChat = true,
		model = "gpt-5-thinking",
	},
}

local custom_query_template = {
	label = "カスタムクエリ入力",
	url = "https://chatgpt.com/?q={TEXT}",
	queryTemplate = "{TEXT}",
	enabled = true,
	hintsSearch = true,
	temporaryChat = false,
	model = "gpt-5-thinking",
}

return {
	placeholders = { "{選択した文字列}", "{TEXT}" },
	defaultTemplateUrl = "https://chatgpt.com/?q={TEXT}",
	defaultQueryTemplate = "{TEXT}",
	templateModelOptions = { "gpt-4o", "o3", "gpt-5", "gpt-5-thinking", "custom" },
	defaultHardLimit = 3000,
	hardLimit = 3000,
	defaultParentMenuTitle = "ChatGPTで検索",
	parentMenuTitle = "ChatGPTで検索",
	defaultTemplates = default_templates,
	templates = vim.deepcopy(default_templates),
	custom_query_template = custom_query_template,
	customQueryTemplate = vim.deepcopy(custom_query_template),
}
