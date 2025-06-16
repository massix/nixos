---@type LazyPluginSpec[]
return {

  -- Oil
  {
    "stevearc/oil.nvim",
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
    event = "VeryLazy",
    opts = {
      default_file_explorer = false,
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
