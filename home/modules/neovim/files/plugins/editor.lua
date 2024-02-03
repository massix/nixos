local Util = require("util.defaults")

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

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      key_labels = {
        ["<space>"] = "SPC",
        ["<cr>"] = "RET",
        ["<tab>"] = "TAB",
      },
    },
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      local wk = require("which-key")
      wk.register({
        -- Lazy Handling
        ["<leader>l"] = { name = "+lazy" },
        ["<leader>ll"] = { "<cmd>Lazy<cr>", "UI" },
        ["<leader>lh"] = { "<cmd>Lazy health<cr>", "HealthCheck" },

        ["<leader>s"] = { name = "+search" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>f"] = { name = "+file" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>u"] = { name = "+misc" },
        ["<leader>x"] = { name = "+list" },
        ["<leader>q"] = { name = "+quit" },
        ["<leader>w"] = { name = "+window" },
        ["<leader><tab>"] = { name = "+tab" },
        ["<leader>n"] = { name = "+nix" },
      })
    end,
  },

  -- Command Palette
  {
    "mrjones2014/legendary.nvim",
    priority = 10000,
    lazy = false,
    enabled = true,
    opts = {
      extensions = {
        lazy_nvim = true,
        which_key = {
          auto_register = true,
          do_binding = false,
          use_groups = true,
        },
      },
    },
    keys = {
      { "<leader><space>", "<cmd>Legendary<cr>", desc = "Legendary" },
    },
  },

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
      ---@diagnostic disable-next-line: undefined-global
      { "<leader>fo", function() MiniFiles.open() end, desc = "Open Files", },
    }
,
  },

  -- Oil
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>fm"] = { name = "+oil" },
      })
    end,
    opts = {
      default_file_explorer = false,
      constrain_cursor = "name",
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
    },
    keys = {
      { "<leader>fmo", "<cmd>Oil<cr>", desc = "Oil" },
      { "<leader>fmf", "<cmd>Oil --float<cr>", desc = "Oil (float)" },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep",
      "sharkdp/fd",
      "luc-tielen/telescope_hoogle",
    },
    keys = {
      { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
      { "<leader>/", Util.telescope("live_grep"), desc = "Grep (root dir)" },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },

      -- find
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>.", Util.telescope("files"), desc = "Find Files (root dir)" },
      { "<leader>ff", Util.telescope("files"), desc = "Find Files (root dir)" },
      { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", Util.telescope("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent (cwd)" },

      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gS", "<cmd>Telescope git_status<CR>", desc = "status" },

      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>sg", Util.telescope("live_grep"), desc = "Grep (root dir)" },
      { "<leader>sG", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>sp", "<cmd>Telescope projects<cr>", desc = "Open project" },
      { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>sw", Util.telescope("grep_string", { word_match = "-w" }), desc = "Word (root dir)" },
      { "<leader>sW", Util.telescope("grep_string", { cwd = false, word_match = "-w" }), desc = "Word (cwd)" },
      { "<leader>sw", Util.telescope("grep_string"), mode = "v", desc = "Selection (root dir)" },
      { "<leader>sW", Util.telescope("grep_string", { cwd = false }), mode = "v", desc = "Selection (cwd)" },
      { "<leader>uC", Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
      {
        "<leader>ss",
        Util.telescope("lsp_document_symbols", {
          symbols = {
            "Class",
            "Function",
            "Method",
            "Constructor",
            "Interface",
            "Module",
            "Struct",
            "Trait",
            "Field",
            "Property",
            "Enum",
            "Constant",
          },
        }),
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        Util.telescope("lsp_dynamic_workspace_symbols", {
          symbols = {
            "Class",
            "Function",
            "Method",
            "Constructor",
            "Interface",
            "Module",
            "Struct",
            "Trait",
            "Field",
            "Property",
            "Enum",
            "Constant",
          },
        }),
        desc = "Goto Symbol (Workspace)",
      },
    },
    opts = function()
      local actions = require("telescope.actions")

      local open_with_trouble = function(...)
        return require("trouble.providers.telescope").open_with_trouble(...)
      end
      local open_selected_with_trouble = function(...)
        return require("trouble.providers.telescope").open_selected_with_trouble(...)
      end
      local find_files_no_ignore = function()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        Util.telescope("find_files", { no_ignore = true, default_text = line })()
      end
      local find_files_with_hidden = function()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        Util.telescope("find_files", { hidden = true, default_text = line })()
      end

      return {
        defaults = vim.tbl_extend("force", require("telescope.themes").get_ivy(), {
          prompt_prefix = " ",
          selection_caret = " ",
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_selected_with_trouble,
              ["<a-i>"] = find_files_no_ignore,
              ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["q"] = actions.close,
            },
          },
        }),
      }
    end,
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

  -- Flash.nvim
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = false,
        }
      }
    },
  -- stylua: ignore
    keys = {
      { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
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
      context = 2,
    },
    keys = {
      { "<leader>zt", "<CMD>Twilight<CR>", desc = "Toggle Twilight" },
    },
  },

  -- Display images in NeoVim (experimental)
  {
    "3rd/image.nvim",
    lazy = false,
    event = "VeryLazy",
    enabled = false, -- too many issues for now :(
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
        neorg = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "norg" },
        },
      },
      window_overlap_clear_enabled = true,
      editor_only_render_when_focused = true,
    },
  },

  -- Better folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "BufEnter",
    opts = {
      open_fold_hl_timeout = 150,
      close_fold_kinds = { "imports", "comment" },
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
      preview = {
        win_config = {
          border = { "", "─", "", "", "", "─", "", "" },
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
        mappings = {
          scrollU = "<C-b>",
          scrollD = "<C-f>",
          jumpTop = "[",
          jumpBot = "]",
        },
      },
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    -- stylua: ignore
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds", },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds", },
      { "zp", function() require('ufo').peekFoldedLinesUnderCursor() end, desc = "Preview fold", },
    },
  },

  -- Code biscuits
  {
    "code-biscuits/nvim-biscuits",
    event = "BufEnter",
    opts = {
      show_on_start = false,
      cursor_line_only = true,
      on_events = { "CursorHoldI", "InsertLeave" },
      trim_by_words = false,
      default_config = {
        prefix_string = " ",
      },
      language_config = {
        org = { disabled = true },
        markdown = { disabled = true },
      },
    },
    keys = {
      {
        "<leader>cb",
        function()
          require("nvim-biscuits").toggle_biscuits()
        end,
        desc = "Toggle biscuits",
      },
    },
  },

  -- Better escape
  {
    "max397574/better-escape.nvim",
    event = "BufEnter",
    opts = {
      mapping = { "jk", "jj", "kj" },
      clear_empty_lines = true,
      keys = function()
        return vim.api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
      end,
    },
    config = function(_, opts)
      require("better_escape").setup(opts)
    end,
  },

  -- Code outline and navigation
  {
    "stevearc/aerial.nvim",
    opts = {
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

  -- Confirm before leaving Neovim
  {
    "yutkat/confirm-quit.nvim",
    event = "CmdlineEnter",
    opts = {
      overwrite_q_command = false,
    },
    config = function(_, opts)
      require("confirm-quit").setup(opts)
      vim.cmd([[
        function! s:solely_in_cmd(command)
          return (getcmdtype() == ':' && getcmdline() ==# a:command)
        endfunction

        cnoreabbrev <expr> q <SID>solely_in_cmd('q') ? 'ConfirmQuit' : 'q'
        cnoreabbrev <expr> qa <SID>solely_in_cmd('qa') ? 'ConfirmQuitAll' : 'qa'
        cnoreabbrev <expr> qq <SID>solely_in_cmd('qq') ? 'quit' : 'qq'
        cnoreabbrev <expr> wq <SID>solely_in_cmd('wq') ? 'w <bar> ConfirmQuit' : 'wq'
        cnoreabbrev <expr> wqa <SID>solely_in_cmd('wqa') ? 'wall <bar> ConfirmQuitAll' : 'wqa'
      ]])
    end,
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
      },
      org = {
        fat_headlines = false,
      },
      norg = {
        fat_headlines = false,
      },
      rmd = {
        fat_headlines = false,
      },
    },
  },

  -- Arrow for bookmarks
  {
    "otavioschwanck/arrow.nvim",
    event = "VeryLazy",
    opts = {
      show_icons = true,
      leader_key = ";",
    },
  },
}
