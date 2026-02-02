local M = {}

M.which_key = function()
  MiniDeps.add({ source = "folke/which-key.nvim" })
  local wk = require("which-key")
  wk.setup({
    preset = "helix",
    triggers = {
      { "<auto>", mode = "nixsotc" },
      { "<C-c>", mode = "nivxc" },
    },
  })

  -- stylua: ignore
	wk.add({
		{ "<leader>s", group = "search" },
		{ "<leader>g", group = "git", mode = { "n", "v" } },
		{ "<leader>f", group = "files" },
		{ "<leader>c", group = "code" },
		{ "<leader>q", group = "quit" },
		{ "<leader>u", group = "display" },
		{ "<leader>x", group = "lists" },
		{ "<leader><tab>", group = "tabs" },
		{ "gs", group = "surround" },
		{ "gp", group = "peek" },
		{ "gr", group = "vim.lsp" },
	})
end

return M
