return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					debounce = 75,
					keymap = {
						accept = "<S-TAB>",
						accept_word = "<C-l>",
						accept_line = "<C-j>",
						dismiss = "<C-k>",
					},
				},
			})
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("codecompanion").setup({
				adapters = {
					opts = { show_defaults = false, show_model_choices = true },
					copilot = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "claude-3.5-sonnet",
								},
							},
						})
					end,
					gemini = function()
						return require("codecompanion.adapters").extend("gemini", {
							env = { api_key = os.getenv("GEMINI_API_KEY") },
							schema = {
								model = {
									default = "gemini-2.5-flash-preview-05-20",
								},
							},
						})
					end,
				},
			})
			vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code Companion: Chat" })
			vim.keymap.set("v", "<leader>ci", "<cmd>CodeCompanion<cr>", { desc = "Code Companion: Inline Chat" })
		end,
	},
}
