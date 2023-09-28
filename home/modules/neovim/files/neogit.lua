return {
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"sindrets/diffview.nvim",
			"ibhagwan/fzf-lua",
		},

		-- Nothing to configure
		config = true,
		enable = true,
		keys = {
			{
				"<leader>gn",
				function()
					require("neogit").open({ kind = "replace" })
				end,
				desc = "Open NeoGit",
			},
		},
	},
}
