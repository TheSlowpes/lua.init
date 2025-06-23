return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			panel = {
				enabled = true,
				auto_refresh = true,
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymaps = {
					accept = "<C-y>",
					accept_word = "<C-l>",
					accept_line = "<C-S-j>",
					next = "<C-j>",
					previous = "<C-k>",
					dismiss = "<C-e>",
				},
			},
		},
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			keymaps = {},
		},
		config = function(_, opts)
			require("codecompanion").setup(opts)
			vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code Companion: Chat" })
			vim.keymap.set("n", "<leader>ci", "<cmd>CodeCompanion<cr>", { desc = "Code Companion: Inline Chat" })
		end,
	},
}
