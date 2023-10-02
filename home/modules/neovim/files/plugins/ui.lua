return {
  -- Scrollbar
  {
    "Xuyuanp/scrollbar.nvim",
    lazy = false,

    -- Register auto commands
    init = function()
      local api = vim.api

      api.nvim_create_autocmd(
        { "WinScrolled", "VimResized", "QuitPre" },
        { pattern = "*", command = [[silent! lua require('scrollbar').show()]] }
      )
      api.nvim_create_autocmd(
        { "WinEnter", "FocusGained" },
        { pattern = "*", command = [[silent! lua require('scrollbar').show()]] }
      )
      api.nvim_create_autocmd(
        { "WinLeave", "FocusLost", "BufLeave", "BufWinLeave" },
        { pattern = "*", command = [[silent! lua require('scrollbar').clear()]] }
      )
    end,
  },

  -- Smooth Scrolling
  {
    "karb94/neoscroll.nvim",
    lazy = false,

    opts = {
      extra_keymaps = true,
      extended_keymaps = true,
      override_keymaps = true,
    },
  },

  -- nvim tree file explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,

    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      hijack_cursor = true,
      view = {
        side = "right",
        width = 50,
      },
      renderer = {
        icons = { show = { modified = true } },
        highlight_modified = "all",
      },
      modified = { enable = true },
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeFocus<cr>", desc = "Focus the explorer" },
      { "<leader>fE", "<cmd>NvimTreeFocus<cr>", desc = "Focus the explorer" },
      { "<leader>fc", "<cmd>NvimTreeClose<cr>", desc = "Close the explorer" },
      { "<leader>fx", "<cmd>NvimTreeFindFile<cr>", desc = "Focus current file in explorer" },
      { "<leader>f+", "<cmd>NvimTreeResize +5<cr>", desc = "Increment explorer width" },
      { "<leader>f-", "<cmd>NvimTreeResize -5<cr>", desc = "Decrement explorer width" },
    },
  },

  -- Dressing (better vim ui)
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end

      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
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
          "neo-tree",
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
    version = false, -- wait till new 0.7.0 release to put it back on semver
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
          "neo-tree",
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
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    },
    dependencies = {
      -- buffer remove
      {
        "echasnovski/mini.bufremove",
        -- stylua: ignore
        keys = {
          { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
          { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
        },
      },
    },
    opts = {
      options = {
        -- stylua: ignore
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
        -- stylua: ignore
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "slant",
        name_formatter = function(buf)
          return buf.bufnr .. " " .. buf.name
        end,
        diagnostics_indicator = function(_, _, diag)
          local icons = require("util.defaults").icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        color_icons = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
          },
        },
      },
    },
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

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },

  {
    "levouh/tint.nvim",
    event = "VeryLazy",
    opts = {},
  },
}

