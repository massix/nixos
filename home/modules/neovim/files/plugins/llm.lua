---@type LazyPluginSpec[]
return {
  -- Codeium with Blink
  {
    "Exafunction/codeium.nvim",
    event = { "BufEnter", "BufWinEnter" },
    opts = function()
      return {
        tools = {
          language_server = require("util.nix").codeium,
        },
        enable_chat = true,
        enable_cmp_source = false,
        virtual_text = { enabled = true },
      }
    end,
    config = function(_, opts)
      require("codeium").setup(opts)

      -- Refresh lualine
      require("codeium.virtual_text").set_statusbar_refresh(function()
        require("lualine").refresh()
      end)
    end,
  },
  -- Goose setup
  {
    "azorng/goose.nvim",
    branch = "main",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
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
