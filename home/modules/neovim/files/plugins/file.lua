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
        use_as_default_explorer = false,
      },
    },

    -- stylua: ignore
    keys = {
      { "<leader>fm", function() MiniFiles.open() end, desc = "mini.files", },
    },
  },

  -- Oil
  {
    "stevearc/oil.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      {
        "SirZenith/oil-vcs-status",
        config = function()
          local status_const = require("oil-vcs-status.constant.status")
          local StatusType = status_const.StatusType
          require("oil-vcs-status").setup({
            status_symbol = {
              [StatusType.Added] = "",
              [StatusType.Copied] = "󰆏",
              [StatusType.Deleted] = "",
              [StatusType.Ignored] = "",
              [StatusType.Modified] = "",
              [StatusType.Renamed] = "",
              [StatusType.TypeChanged] = "󰉺",
              [StatusType.Unmodified] = " ",
              [StatusType.Unmerged] = "",
              [StatusType.Untracked] = "",
              [StatusType.External] = "",
              [StatusType.UpstreamAdded] = "󰈞",
              [StatusType.UpstreamCopied] = "󰈢",
              [StatusType.UpstreamDeleted] = "",
              [StatusType.UpstreamIgnored] = " ",
              [StatusType.UpstreamModified] = "󰏫",
              [StatusType.UpstreamRenamed] = "",
              [StatusType.UpstreamTypeChanged] = "󱧶",
              [StatusType.UpstreamUnmodified] = " ",
              [StatusType.UpstreamUnmerged] = "",
              [StatusType.UpstreamUntracked] = " ",
              [StatusType.UpstreamExternal] = "",
            },
          })
        end,
      },
    },
    event = "VeryLazy",
    opts = {
      default_file_explorer = true,
      constrain_cursor = "editable",
      watch_for_changes = true,
      skip_confirm_for_simple_edits = true,
      win_options = {
        signcolumn = "yes:2",
      },
      keymaps = {
        q = "actions.close",
      },
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
    },
    keys = {
      { "<leader>fo", "<cmd>Oil<cr>", desc = "Oil" },
      { "<leader>ff", "<cmd>Oil --float<cr>", desc = "Oil (float)" },
    },
  },
}
