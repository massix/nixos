return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		enabled = true,
		opts = {
			flavour = "frappe",
			background = {
				dark = "macchiato",
				light = "latte",
			},
			dim_inactive = {
				enable = true,
			},
			show_end_of_buffer = false,
			integrations = {
				neotree = true,
				mini = true,
			},
		},
	},
	{ "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
	{ "nvim-lualine/lualine.nvim", opts = { options = { theme = "catppuccin" } } },
}
