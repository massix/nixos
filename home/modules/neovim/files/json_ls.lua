return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				jsonls = { cmd = { "json-languageserver", "--stdio" } },
			},
		},
	},
}
