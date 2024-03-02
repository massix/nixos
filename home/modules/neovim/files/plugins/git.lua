local spec = {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      { "sindrets/diffview.nvim", lazy = false },
      { "ibhagwan/fzf-lua", lazy = false },
    },
    opts = {
      disable_hint = false,
      disable_signs = false,
      disable_line_numbers = false,
      console_timeout = 15000,
      status = {
        recent_commit_count = 50,
      },
      graph_style = "unicode",
      signs = {
        hunk = { "", "" },
        item = { " ", " " },
        section = { " ", " " },
      },
      integrations = {
        telescope = true,
        diffview = true,
      },
    },
    --stylua: ignore
    keys = {
      { "<leader>gg", function() require("neogit").open({ kind = "auto" }) end, desc = "Open Neogit", },
      { "<leader>gt", function() require("neogit").open({ kind = "tab" }) end, desc = "Open Neogit in new tab", },
    },
    cmd = { "Neogit" },
  },

  -- Fugitive
  {
    "tpope/vim-fugitive",
    opts = {},
    config = function() end,
    cmd = { "G", "Git", "Gstatus" },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>g"] = { mode = "v", name = "+git" },
      })
    end,
    keys = {
      {
        "<leader>gB",
        "<cmd>Gitsigns toggle_current_line_blame<cr>",
        desc = "Toggle Git blame",
      },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
      { "<leader>gP", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview hunk (inline)" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk", mode = { "n", "v" } },
      { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo stage Hunk" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset hunk", mode = { "n", "v" } },
    },
  },

  -- Easily copy shareable links for different platforms
  {
    "linrongbin16/gitlinker.nvim",
    cmd = { "GitLink" },
    opts = {},
  },
}

return spec
