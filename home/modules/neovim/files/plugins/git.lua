local api = vim.api

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
    config = function(_, opts)
      require("neogit").setup(opts)
      local group = api.nvim_create_augroup("NeogitEvents", { clear = true })

      api.nvim_create_autocmd("User", {
        group = group,
        pattern = "NeogitPushComplete",
        callback = function()
          require("neogit").close()
        end,
      })
    end,
    keys = {
      {
        "<leader>gg",
        function()
          require("neogit").open()
        end,
        desc = "Open Neogit",
      },
    },
  },

  -- Git blame info
  {
    "f-person/git-blame.nvim",
    config = true,
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git blame" },
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = true,
    event = { "BufReadPre", "BufNewFile" },
  },
}

return spec
