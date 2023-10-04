local nix = require("util.nix")

return {
	"Exafunction/codeium.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	opts = {
		tools = { language_server = nix.codeiumLs },
	},
	lazy = true,
	event = { "BufEnter" }
}

