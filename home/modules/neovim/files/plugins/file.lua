---@type LazyPluginSpec[]
return {
  -- Mini.files is an excellent file browser
  {
    "echasnovski/mini.files",
    version = "*",
    event = "VeryLazy",
    opts = {
      windows = {
        preview = true,
        width_focus = 50,
        with_nofocus = 30,
        width_preview = 70,
      },
      options = {
        use_as_default_explorer = true,
      },
    },

    -- stylua: ignore
    keys = {
      ---@diagnostic disable-next-line: undefined-global
      { "<leader>fo", function() MiniFiles.open() end, desc = "Open Files", },
    },
  },

  -- Oil
  {
    "stevearc/oil.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      { "SirZenith/oil-vcs-status" },
    },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>fm"] = { name = "+oil" },
      })
    end,
    opts = {
      default_file_explorer = false,
      constrain_cursor = "editable",
      experimental_watch_for_changes = true,
      win_options = {
        signcolumn = "yes:2",
      },
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
    },
    keys = {
      { "<leader>fmo", "<cmd>Oil<cr>", desc = "Oil" },
      { "<leader>fmf", "<cmd>Oil --float<cr>", desc = "Oil (float)" },
    },
  },
}
