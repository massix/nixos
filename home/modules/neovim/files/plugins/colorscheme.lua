-- Install TokyoNight colorscheme
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    name = "tokyonight",
    priority = 10000,
    opts = {
      style = "moon",
      transparent = false,
      terminal_colors = true,
      hide_inactive_statusline = true,
      dim_inactive = true,
      lualine_bold = true,
      styles = {
        floats = "dark",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      require("tokyonight").load()
    end,
  },

  {
    "catppuccin/nvim",
    lazy = false,
    priority = 10000,
    name = "catppuccin",
    enabled = false,
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

    {
      "ribru17/bamboo.nvim",
      lazy = false,
      priority = 10000,
      enabled = false,
      opts = {
        style = "vulgaris",
      },
      config = function(_, opts)
        require("bamboo").setup(opts)
        require("bamboo").load()
      end,
    },
  },
}
