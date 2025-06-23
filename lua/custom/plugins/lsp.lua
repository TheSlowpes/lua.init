return {
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"pyright",
				"tsserver",
				"html-lsp",
				"css-lsp",
				"emmet-ls",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function() end,
	},
}
