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
      { "<leader>fm", function() MiniFiles.open() end, desc = "mini.files", },
    },
  },

  -- Dired
  {
    "X3eRo0/dired.nvim",
    opts = {
      show_icons = true,
      show_banner = true,
      hide_details = false,
      keybinds = {
        dired_enter = "<cr>",
        dired_back = "-",
        dired_up = "_",
        dired_rename = "R",
        dired_create = "d",
        dired_delete = "D",
        dired_delete_range = "D",
        dired_copy = "C",
        dired_copy_range = "C",
        dired_copy_marked = "MC",
        dired_move = "X",
        dired_move_range = "X",
        dired_move_marked = "MX",
        dired_paste = "P",
        dired_mark = "M",
        dired_mark_range = "M",
        dired_delete_marked = "MD",
        dired_toggle_hidden = ".",
        dired_toggle_sort_order = ",",
        dired_toggle_icons = "*",
        dired_toggle_colors = "c",
        dired_toggle_hide_details = "(",
        dired_quit = "q",
      },
    },
    cmd = { "Dired" },
    keys = {
      { "<leader>fd", "<cmd>Dired<cr>", desc = "Dired" },
    },
  },

  -- Oil
  {
    "stevearc/oil.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      { "SirZenith/oil-vcs-status" },
    },
    opts = {
      default_file_explorer = false,
      constrain_cursor = "editable",
      experimental_watch_for_changes = true,
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
