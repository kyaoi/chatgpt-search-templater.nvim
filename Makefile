NVIM ?= nvim

.PHONY: check

check:
	@$(NVIM) --headless --clean -u tests/minimal_init.lua -c "lua require('chatgpt_search_templater.tests.smoke').run()" -c qa
