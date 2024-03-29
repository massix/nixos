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
    end,
  },

  {
    "catppuccin/nvim",
    lazy = false,
    priority = 10000,
    name = "catppuccin",
    enabled = true,
    opts = {
      flavour = "mocha",
      term_colors = true,
      transparent_background = false,
      show_end_of_buffer = false,
      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.15,
      },
      integrations = {
        alpha = true,
        mini = {
          enabled = true,
          indentscope_color = "mauve",
        },
        neotest = true,
        rainbow_delimiters = true,
        overseer = true,
        ufo = true,
        dap = true,
        dap_ui = true,
        cmp = true,
        neogit = true,
        noice = true,
        notify = true,
        window_picker = true,
        lsp_trouble = true,
        which_key = true,
        treesitter = true,
        flash = true,
        gitsigns = true,
        headlines = false,
        markdown = true,
        telescope = {
          enabled = true,
        },
        indent_blankline = {
          enabled = true,
          scope_color = "mauve",
          colored_indent_levels = true,
        },
        lsp_saga = true,
      },
    },
  },

  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 10000,
    enabled = true,
    opts = {
      style = "vulgaris",
    },
    config = function(_, opts)
      require("bamboo").setup(opts)
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 10000,
    enabled = true,
  },

  {
    "baliestri/aura-theme",
    lazy = false,
    priority = 10000,
    enabled = true,
    opts = {},
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
    end,
  },

  {
    "savq/melange-nvim",
    lazy = false,
    priority = 10000,
    enabled = true,
    config = false,
  },

  {
    "luisiacc/gruvbox-baby",
    lazy = false,
    priority = 10000,
    enabled = true,
    config = false,
  },
}
