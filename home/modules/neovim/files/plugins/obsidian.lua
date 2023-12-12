local obsidianWork = vim.fn.expand("~") .. "/Documents/Obsidian Work"
local obsidianPersonal = vim.fn.expand("~") .. "/Documents/Obsidian Personal"

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  init = function()
    local wk = require("which-key")
    wk.register({
      ["<leader>O"] = { name = "+obsidian" },
      ["<leader>Ow"] = { name = "+workspace" },
    })
  end,

  opts = {
    workspaces = {
      {
        name = "Personal",
        path = obsidianPersonal .. "/",
      },
      {
        name = "Work",
        path = obsidianWork .. "/",
      },
    },

    detect_cwd = true,

    completion = {
      nvim_cmp = true,
      new_notes_location = "current_dir",
    },

    templates = {
      subdir = "Templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },

    finder = "telescope.nvim",
  },
  keys = {
    { "<leader>Oww", [[<cmd>ObsidianWorkspace Work<cr>]], desc = "Open Work Vault" },
    { "<leader>Owp", [[<cmd>ObsidianWorkspace Personal<cr>]], desc = "Open Personal Vault" },
    { "<leader>Oo", [[<cmd>ObsidianOpen<cr>]], desc = "Open in Obsidian" },
    { "<leader>Ov", [[<cmd>ObsidianPasteImg<cr>]], desc = "Paste Image" },
    { "<leader>Ov", [[<cmd>ObsidianLink<cr>]], desc = "Link to file", mode = "v" },
    { "<leader>Of", [[<cmd>ObsidianQuickSwitch<cr>]], desc = "Quick switch" },
    { "<leader>O/", [[<cmd>ObsidianSearch<cr>]], desc = "Search in Obsidian" },
    { "<leader>Ot", [[<cmd>ObsidianTemplate<cr>]], desc = "Add template" },
  },
}
