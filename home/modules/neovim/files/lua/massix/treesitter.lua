local M = {}

M.treesitter = function()
  MiniDeps.add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "master",
    monitor = "main",
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  })

  ---@diagnostic disable-next-line: missing-fields
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "bash",
      "c_sharp",
      "dhall",
      "dockerfile",
      "elvish",
      "fish",
      "gitcommit",
      "go",
      "gleam",
      "haskell",
      "html",
      "http",
      "java",
      "javascript",
      "jsdoc",
      "json",
      "jsonc",
      "just",
      "kdl",
      "kotlin",
      "ledger",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "nix",
      "nu",
      "purescript",
      "query",
      "racket",
      "regex",
      "rust",
      "terraform",
      "tsx",
      "toml",
      "typescript",
      "typst",
      "vim",
      "yaml",
      "xml",
    },
    highlight = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
  })

  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
end

return M
