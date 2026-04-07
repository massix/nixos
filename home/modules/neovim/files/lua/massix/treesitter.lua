local M = {}

local needed_parsers = {
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
}

M.treesitter = function()
  MiniDeps.add({
    source = "nvim-treesitter/nvim-treesitter",
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  })

  require("nvim-treesitter").setup({
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

  local installed_parsers = require("nvim-treesitter.config").get_installed()
  local to_be_installed = vim
    .iter(needed_parsers)
    :filter(function(p)
      return not vim.tbl_contains(installed_parsers, p)
    end)
    :totable()
  require("nvim-treesitter").install(to_be_installed)

  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      pcall(vim.treesitter.start)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return M
