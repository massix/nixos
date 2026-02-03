local M = {}

M.shortcuts = function()
  MiniDeps.add({ source = "folke/flash.nvim" })
  MiniDeps.add({ source = "max397574/better-escape.nvim" })

  require("better_escape").setup({
    default_mappings = false,
    mappings = {
      i = {
        j = {
          j = "<esc>",
          k = "<esc>",
        },
      },
    },
  })

  require("flash").setup()

  -- stylua: ignore
  require("which-key").add({
    { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash", },
    { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter", },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash", },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search", },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search", },
  })
end

return M
