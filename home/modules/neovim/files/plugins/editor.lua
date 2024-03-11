-- Here all the plugins for the editor
return {

  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      render = "default",
      stages = "slide",
      top_down = true,
    },
  },

  -- Noice
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },

        -- TS-Action spams a lot
        {
          filter = {
            event = "notify",
            kind = "info",
            any = {
              { find = "No node found at cursor" },
            },
          },
          opts = { skip = true },
        },

        {
          -- Skip messages from null-ls
          filter = {
            event = "lsp",
            kind = "progress",
            cond = function(message)
              local client = vim.tbl_get(message.opts, "progress", "client")
              return client == "null-ls"
            end,
          },
          opts = { skip = true },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
    },

    keys = {
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect Cmdline",
      },
      {
        "<leader>snl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Noice Last Message",
      },
      {
        "<leader>snh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Noice History",
      },
      {
        "<leader>sna",
        function()
          require("noice").cmd("all")
        end,
        desc = "Noice All",
      },
      {
        "<leader>snd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss All",
      },
      {
        "<c-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll forward",
        mode = { "i", "n", "s" },
      },
      {
        "<c-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll backward",
        mode = { "i", "n", "s" },
      },
    },
  },

  -- search/replace in multiple files
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>S"] = { name = "+spectre" },
      })
    end,
    opts = {
      open_cmd = "noswapfile vnew",
      live_update = true,
      is_open_target_win = true,
      is_insert_mode = true,
      is_block_ui_break = true,
    },
    -- stylua: ignore
    keys = {
      { "<leader>So", function() require("spectre").toggle() end, desc = "Toggle Spectre" },
      { "<leader>Sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search current word", mode = "v" },
      { "<leader>Sw", function() require("spectre").open_visual() end, desc = "Search current word", mode = "n" },
      { "<leader>Sp", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search on current file" },
    },
  },

  -- Icon Picker
  {
    "ziontee113/icon-picker.nvim",
    cmd = { "IconPickerNormal", "IconPickerYank", "IconPickerInsert" },
    opts = {
      disable_legacy_commands = true,
    },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>I"] = { name = "+insert" },
      })
    end,
    keys = {
      { "<leader>Ii", "<cmd>IconPickerNormal<cr>", desc = "Icon Picker" },
      { "<C-i>", mode = "i", "<cmd>IconPickerInsert<cr>", desc = "Icon Picker (insert)" },
    },
  },

  -- Better MatchParen
  {
    "utilyre/sentiment.nvim",
    lazy = false,
    config = true,
    init = function()
      vim.g.loaded_matchparen = 1
    end,
  },

  -- Surround motion
  {
    "echasnovski/mini.surround",
    version = "*",
    lazy = false,
    config = true,
    init = function()
      local wk = require("which-key")
      wk.register({
        ["gs"] = { name = "+surround" },
      })
    end,
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },

  -- Zen-Mode
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 120,
        height = 1,
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
          cursorline = false,
          foldcolumn = "0",
        },
      },
      plugins = {
        kitty = {
          enabled = true,
          font = "+2",
        },
        gitsigns = { enabled = true },
        options = {
          enabled = true,
          ruler = true,
          showcmd = true,
        },
      },
      on_open = function()
        if vim.g.neovide then
          vim.g.neovide_zen_old_scale = vim.g.neovide_scale_factor
          vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.5
        end
      end,
      on_close = function()
        if vim.g.neovide then
          vim.g.neovide_scale_factor = vim.g.neovide_zen_old_scale or 1.0
        end
      end,
    },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>z"] = { name = "+zen" },
      })
    end,
    commands = { "ZenMode" },
    keys = {
      { "<leader>zz", "<CMD>ZenMode<CR>", desc = "Start Zen Mode" },
    },
  },

  -- Dim inactive portions of code
  {
    "folke/twilight.nvim",
    lazy = false,
    opts = {
      context = 10,
      expand = {
        "function",
        "method",
        "table",
        "if_statement",
        "preproc_function_def",
        "function_definition",
        "paragraph",
        "list",
      },
    },
    keys = {
      { "<leader>zt", "<CMD>Twilight<CR>", desc = "Toggle Twilight" },
    },
  },

  -- Code outline and navigation
  {
    "stevearc/aerial.nvim",
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        default_direction = "prefer_left",
        placement = "edge",
      },

      highlight_on_hover = true,
      show_guides = true,
    },
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>co", "<cmd>AerialToggle<cr>", desc = "Open outline" },
      { "<leader>cn", "<cmd>AerialNavToggle<cr>", desc = "Open float outline" },
    },
  },

  -- Highlight ranges
  {
    "winston0410/range-highlight.nvim",
    dependencies = { "winston0410/cmd-parser.nvim" },
    event = { "BufEnter", "BufWinEnter" },
    opts = {},
  },

  -- buffer switcher
  {
    "matbme/JABS.nvim",
    cmd = "JABSOpen",
    main = "jabs",
    opts = {
      relative = "cursor",
      border = "rounded",
      split_filename = true,
      symbols = {
        current = "󰄾",
        split = "",
        alternate = "⫝",
        hidden = "󰘓",
        locked = "",
        ro = "",
        edited = "",
        terminal = "",
        default_file = "",
        terminal_symbol = "",
      },
    },
    keys = {
      { "<leader>bj", "<cmd>JABSOpen<cr>", desc = "JABS Open" },
    },
  },

  -- Better tab scoping
  {
    "tiagovla/scope.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Trailspaces and stuff
  {
    "echasnovski/mini.trailspace",
    version = "*",
    event = { "BufEnter", "BufWinEnter" },
    opts = {
      only_in_normal_buffers = true,
    },
    config = function(_, opts)
      require("mini.trailspace").setup(opts)
      vim.g.remove_trailspaces = true

      function _G.Toggle_trailspaces()
        if vim.g.remove_trailspaces then
          vim.notify("Disabling automatic trim of whitespaces", vim.log.levels.INFO)
          vim.g.remove_trailspaces = false
        else
          vim.notify("Enabling automatic trim of whitespaces", vim.log.levels.INFO)
          vim.g.remove_trailspaces = true
        end
      end

      vim.api.nvim_set_keymap(
        "n",
        "<leader>cw",
        "<cmd>lua Toggle_trailspaces()<CR>",
        { noremap = true, desc = "Toggle Trailspaces" }
      )

      local group = vim.api.nvim_create_augroup("TrimWhitespaces", { clear = true })
      vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        group = group,
        pattern = "*",
        callback = function()
          if vim.g.remove_trailspaces and vim.bo.buftype == "" then
            ---@diagnostic disable-next-line: undefined-global
            MiniTrailspace.trim()
          end
        end,
      })
    end,
  },

  -- Autopairs
  {
    "echasnovski/mini.pairs",
    version = "*",
    event = { "BufEnter", "BufWinEnter" },
    opts = {},
  },

  -- Move selection
  {
    "echasnovski/mini.move",
    version = "*",
    event = { "BufEnter", "BufWinEnter" },
    opts = {},
  },

  -- Headlines
  {
    "lukas-reineke/headlines.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "org", "norg", "markdown" },
    opts = {
      markdown = {
        fat_headlines = false,
        codeblock_highlight = false,
      },
      org = {
        fat_headlines = false,
        codeblock_highlight = false,
      },
      norg = {
        fat_headlines = false,
        codeblock_highlight = false,
      },
      rmd = {
        fat_headlines = false,
        codeblock_highlight = false,
      },
    },
  },

  -- Table mode for creating tables
  {
    "dhruvasagar/vim-table-mode",
    event = { "BufEnter", "BufWinEnter" },
    init = function()
      vim.g.table_mode_syntax = 0
      require("which-key").register({
        ["<leader>t"] = { name = "+table" },
      })
    end,
    config = false,
  },

  -- Better quickfix
  {
    "kevinhwang91/nvim-bqf",
    dependencies = {
      "junegunn/fzf",
    },
    opts = {},
    ft = { "qf" },
  },

  -- Mini.align for aligning text
  {
    "echasnovski/mini.align",
    opts = {},
    keys = {
      { "ga", mode = { "n", "v" }, desc = "Align" },
      { "gA", mode = { "n", "v" }, desc = "Align with preview" },
    },
  },
}
