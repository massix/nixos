local M = {}

M.notetaking = function()
  MiniDeps.add({ source = "echaya/neowiki.nvim" })
  local neowiki = require("neowiki")
  neowiki.setup({ discover_nested_roots = true })

  -- stylua: ignore
	require("which-key").add({
		{ "<leader>w", group = "wiki" },
		{ "<leader>ww", function() neowiki.open_wiki() end, desc = "Open", },
		{ "<leader>wW", function() neowiki.open_wiki_floating() end, desc = "Open in floating window", },
		{ "<leader>wT", function() neowiki.open_wiki_new_tab() end, desc = "Open in new tab", },
	})
end

return M
