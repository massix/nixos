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
        virtual_text = {
          enabled = true,
          key_bindings = {
            accept = "<S-CR>",
            clear = "<C-]>",
          },
        },
      }
    end,
    config = function(_, opts)
      require("codeium").setup(opts)
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
    opts = {
      default_global_keymaps = false,
      keymap = {
        global = {
          toggle = "<leader>Gg",
          open_input = "<leader>Gi",
          open_input_new_session = "<leader>GI",
          open_output = "<leader>Go",
          toggle_focus = "<leader>Gt",
          close = "<leader>Gq",
          toggle_fullscreen = "<leader>Gf",
          select_session = "<leader>Gs",
          goose_mode_chat = "<leader>Gmc",
          goose_mode_auto = "<leader>Gma",
          configure_provider = "<leader>Gp",
          diff_open = "<leader>Gd",
          diff_next = "<leader>G]",
          diff_prev = "<leader>G[",
          diff_close = "<leader>Gc",
          diff_revert_all = "<leader>Gra",
          diff_revert_this = "<leader>Grt",
        },
      },
    },
    enabled = function()
      -- Enable only if goose binary is in the path
      return vim.fn.executable("goose") == 1
    end,
    cmd = { "GooseTogglePane", "Goose" },
    keys = {
      { "<leader>Gg", "<cmd>GooseTogglePane<cr>", desc = "Toggle UI" },
      { "<leader>Gt", "<cmd>GooseToggleFocus<cr>", desc = "Toggle focus" },
      { "<leader>Gs", "<cmd>GooseSelectSession<cr>", desc = "Select session" },
    },
  },
}
