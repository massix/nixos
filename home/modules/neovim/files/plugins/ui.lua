---@type LazyPluginSpec[]
return {
  -- Dressing (better vim ui)
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      select = {
        backend = { "telescope" },
        telescope = require("telescope.themes").get_ivy(),
      },
    },
  },

  -- indent guides for Neovim
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "Trouble",
          "lazy",
          "notify",
          "toggleterm",
        },
      },
    },
    main = "ibl",
  },

  -- Active indent guide and indent text objects. When you're browsing
  -- code, this highlights the current level of indentation, and animates
  -- the highlighting.
  {
    "echasnovski/mini.indentscope",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- symbol = "▏",
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "Trouble",
          "lazy",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- ui components
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Fancy tabs and buffers
  {
    "akinsho/bufferline.nvim",
    event = { "BufEnter", "BufWinEnter" },
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bC", "<CMD>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
      { "<leader>b<CR>", "<CMD>BufferLinePick<CR>", desc = "Pick buffer" },
    },
    dependencies = {
      -- buffer remove
      {
        "echasnovski/mini.bufremove",
        version = "*",
        -- stylua: ignore
        keys = {
          { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
          { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
        },
      },
    },
    opts = function()
      return {
        highlights = require("catppuccin.groups.integrations.bufferline").get(),
        options = {
          -- stylua: ignore
          close_command = function(n) require("mini.bufremove").delete(n, false) end,
          right_mouse_command = nil,
          numbers = "ordinal",
          diagnostics = "nvim_lsp",
          always_show_bufferline = true,
          separator_style = "thick",
          show_tab_indicators = true,
          diagnostics_indicator = function(_, _, diag)
            local icons = require("util.defaults").icons.diagnostics
            local ret = (diag.error and icons.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.Warn .. diag.warning or "")
            return vim.trim(ret)
          end,
          color_icons = true,
          indicator = {
            icon = "▎",
            style = "icon",
          },
        },
      }
    end,
  },

  -- Automatically highlights other instances of the word under your cursor.
  -- This works with LSP, Treesitter, and regexp matching to find the other
  -- instances.
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference" })
      end

      map("g]", "next")
      map("g[", "prev")
    end,
  },

  -- Reactive HLGroups
  {
    "rasulomaroff/reactive.nvim",
    event = "VimEnter",
    opts = {
      load = {
        "catppuccin-mocha-cursor",
        "catppuccin-mocha-cursorline",
      },
    },
    config = function(_, opts)
      require("reactive").setup(opts)
      vim.opt.cursorline = true
      vim.wo.cursorline = true

      -- issue: https://github.com/nvim-telescope/telescope.nvim/issues/2027#issuecomment-1561836585
      -- FIXME: this causes a minor problem with 'project.nvim'
      vim.api.nvim_create_autocmd("WinLeave", {
        callback = function()
          if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
          end
        end,
      })
    end,
  },

  -- Internal statusline
  {
    "b0o/incline.nvim",
    -- stylua: ignore
    enabled = function() return vim.g.neovide == nil end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    opts = function()
      return {
        hide = {
          only_win = true,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local ft_icon, _ = require("nvim-web-devicons").get_icon_color(filename)
          local modified = vim.bo[props.buf].modified

          return {
            ft_icon and { " ", ft_icon, " " } or "",
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
          }
        end,
      }
    end,
    event = { "VeryLazy" },
  },

  -- Foldsign
  {
    "yaocccc/nvim-foldsign",
    opts = {
      offset = -2,
      foldsigns = {
        open = "󰅀", -- mark the beginning of a fold
        close = "󰅂", -- show a closed fold
        seps = { "", "" }, -- open fold middle marker
      },
    },
    event = { "BufEnter", "BufWinEnter" },
  },
}
