return {
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
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
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
    opts = {
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
        offsets = {
          {
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

  -- Golden ratio split
  {
    "nvim-focus/focus.nvim",
    enabled = true,
    lazy = false,
    init = function()
      -- Do not resize `nofile' buffers
      local group = vim.api.nvim_create_augroup("FocusDisable", { clear = true })
      local ignore_buftypes = { "nofile", "terminal", "prompt", "popup" }
      local ignore_filetypes = { "OverseerList" }
      vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = function(_)
          if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
            vim.w.focus_disable = true
          else
            vim.w.focus_disable = false
          end
        end,
        desc = "Disable focus for nofile buffers",
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(_)
          if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.focus_disable = true
          else
            vim.b.focus_disable = false
          end
        end,
        desc = "Disable focus for terminal, prompt, popup, and NvimTree",
      })
    end,
    opts = {
      ui = {
        signcolumn = false,
      },
    },
  },
}
