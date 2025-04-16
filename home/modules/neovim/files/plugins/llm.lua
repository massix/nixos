---@type LazyPluginSpec[]
return {
  -- Codeium setup
  {
    "Exafunction/codeium.vim",
    event = { "VeryLazy" },
    init = function()
      local wk = require("which-key")

      -- Configuration options
      vim.g.codeium_disable_bindings = 1 -- Disable default bindings
      vim.g.codeium_bin = require("util.nix").codeium -- Inject path to language server
      vim.g.codeium_enabled = true -- Enable completion globally

      -- Filetype specific settings
      vim.g.codeium_filetypes = {
        org = false, -- Disable completion for org files
        orgagenda = false, -- Disable completion for orgagenda files
        md = false, -- Disable completion for markdown files
        toggleterm = false, -- Disable completion for toggleterm
        vimwiki = false, -- Disable completion for vimwiki files
      }

      -- Keybindings
      -- stylua: ignore
      wk.add({
        {
          mode = { "i", "n" },
          { "<C-c>C", group = "codeium" },
          { "<C-c>Ct", function() return vim.fn["codeium#Chat"]() end, desc = "Open Chat", silent = true, expr = true },
          { "<C-c>Cn", function() return vim.fn["codeium#CycleCompletions"](1) end, desc = "Next Suggestion", silent = true, expr = true },
          { "<C-c>Cp", function() return vim.fn["codeium#CycleCompletions"](-1) end, desc = "Previous Suggestion", silent = true, expr = true },
          { "<C-c>Cc", function() return vim.fn["codeium#Clear"]() end, desc = "Clear Suggestion", silent = true, expr = true },
          { "<C-c>CC", function() return vim.fn["codeium#Complete"]() end, desc = "Force Suggestion", silent = true, expr = true },
          { "<C-c>C<CR>", function() return vim.fn["codeium#Accept"]() end, desc = "Accept Suggestion", silent = true, expr = true },
        },
      })
    end,
  },

  -- Goose setup
  {
    "azorng/goose.nvim",
    branch = "main",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
        },
      },
    },
    opts = {},
    enabled = function()
      -- Enable only if goose binary is in the path
      return vim.fn.executable("goose") == 1
    end,
    cmd = { "GooseTogglePane", "Goose" },
    keys = {
      { "<leader>gg", "<cmd>GooseTogglePane<cr>", desc = "Toggle Goose UI" },
      { "<leader>gi", "<cmd>GooseOpenInput<cr>", desc = "Goose focus input" },
      { "<leader>go", "<cmd>GooseOpenOutput<cr>", desc = "Goose focus output" },
    },
  },
}
