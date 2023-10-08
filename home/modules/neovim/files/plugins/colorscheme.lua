-- Install TokyoNight colorscheme
return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    name = "tokyonight",
    opts = {
      style = "moon",
    },
  },

  {
    "catppuccin/nvim",
    priority = 10000,
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      term_colors = true,
      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.30,
      },
      integrations = {
        mini = true,
        neotest = true,
        notify = true,
        window_picker = true,
        lsp_trouble = true,
        which_key = true,
      },
    },
  },
}
