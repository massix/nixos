local load_textobjects = false
local util_defaults = require("util.defaults")

return {
  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- disable rtp plugin, as we only need its queries for mini.ai
          -- In case other textobject modules are enabled, we will load them
          -- once nvim-treesitter is loaded
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
          load_textobjects = true
        end,
      },
      {
        "IndianBoy42/tree-sitter-just",
        lazy = false,
        config = false,
      },
    },
    cmd = { "TSUpdateSync" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Decrement selection", mode = "x" },
    },
    opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "org" },
      },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "dhall",
        "dockerfile",
        "elvish",
        "fish",
        "haskell",
        "html",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "just",
        "kdl",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "nix",
        "norg",
        "org",
        "purescript",
        "query",
        "racket",
        "regex",
        "rust",
        "terraform",
        "typescript",
        "vim",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("tree-sitter-just").setup({})
      require("nvim-treesitter.configs").setup(opts)

      if load_textobjects then
        -- PERF: no need to load the plugin, if we only need its queries for mini.ai
        if opts.textobjects then
          for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
            if opts.textobjects[mod] and opts.textobjects[mod].enable then
              local Loader = require("lazy.core.loader")
              Loader.disabled_rtp_plugins["nvim-treesitter-textobjects"] = nil
              local plugin = require("lazy.core.config").plugins["nvim-treesitter-textobjects"]
              require("lazy.core.loader").source_runtime(plugin.dir, "plugin")
              break
            end
          end
        end
      end

      -- Once treesitter loaded, we can change the foldmethod
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },

  -- Comments
  { "numToStr/Comment.nvim", lazy = false, config = true },

  -- Fork of null-ls
  {
    "nvimtools/none-ls.nvim",
    name = "null-ls",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ThePrimeagen/refactoring.nvim",
      "ckolkey/ts-node-action",
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local nls = require("null-ls")
      return {
        root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        notify_format = nil,
        sources = {
          -- Diagnostics --
          nls.builtins.diagnostics.fish,
          nls.builtins.diagnostics.deadnix,
          nls.builtins.diagnostics.ansiblelint,
          nls.builtins.diagnostics.gitlint,
          nls.builtins.diagnostics.hadolint,
          nls.builtins.diagnostics.terraform_validate,
          nls.builtins.diagnostics.tfsec,

          -- Formatting --
          nls.builtins.formatting.fish_indent,
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.shfmt,
          nls.builtins.formatting.nixpkgs_fmt,

          -- Code Actions --
          nls.builtins.code_actions.statix,
          nls.builtins.code_actions.refactoring,
          nls.builtins.code_actions.ts_node_action,
        },
      }
    end,
  },

  -- highlights TODO and similar comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    config = function(_, opts)
      require("todo-comments").setup(opts)
    end,
  },

  -- better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").previous({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous trouble/quickfix item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next trouble/quickfix item",
      },
    },
  },

  -- Enter nix develop automagically
  {
    "figsoda/nix-develop.nvim",
    cmd = { "NixDevelop", "NixShell" },
    lazy = true,
    ft = { "nix" },
    keys = {
      { "<leader>nd", "<cmd>NixDevelop<cr>", desc = "Nix Develop" },
      { "<leader>ns", "<cmd>NixShell<cr>", desc = "Nix Shell" },
    },
  },

  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "LspInfo" },
    version = false,
    config = function()
      -- Make sure we load neoconf and neodev before configuring the lsp
      require("neoconf").setup()
      local neodev_opts = {}

      if require("util.nix").dapConfigured then
        neodev_opts = {
          library = {
            plugins = { "nvim-dap-ui" },
            types = true,
          },
        }
      end
      require("neodev").setup(neodev_opts)

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.nil_ls.setup({
        capabilities = capabilities,
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })

      lspconfig.jsonls.setup({
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
          jsonc = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      lspconfig.yamlls.setup({
        settings = {
          yaml = {
            schemaStore = {
              -- You must disable built-in schemaStore support if you want to use
              -- this plugin and its advanced options like `ignore`.
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      lspconfig.terraformls.setup({
        capabilities = capabilities,
      })

      lspconfig.dockerls.setup({
        capabilities = capabilities,
      })

      lspconfig.helm_ls.setup({
        capabilities = capabilities,
      })

      lspconfig.tsserver.setup({
        capabilities = capabilities,
      })

      lspconfig.purescriptls.setup({
        capabilities = capabilities,
      })

      -- If there are both yamlls and helm_ls, then detach yamlls
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "helm",
        group = vim.api.nvim_create_augroup("Helm", { clear = true }),
        callback = function(args)
          local clients = vim.lsp.get_active_clients({ bufnr = args.buf })
          for _, client in ipairs(clients) do
            if client.name == "yamlls" and vim.lsp.buf_is_attached(args.buf, client.id) then
              vim.lsp.buf_detach_client(args.buf, client.id)
              break
            end
          end
        end,
      })
    end,
    dependencies = {
      -- Similar to .vscode things
      { "folke/neoconf.nvim" },
      { "folke/neodev.nvim" },

      -- Completion engine for lsp
      { "hrsh7th/cmp-nvim-lsp" },
      { "b0o/schemastore.nvim" },
      { "towolf/vim-helm" },
    },
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<C-tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<C-Tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      {
        "<tab>",
        function()
          require("luasnip").jump(1)
        end,
        mode = "s",
      },
      {
        "<s-tab>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "i", "s" },
      },
    },
  },

  -- completion engine
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-nvim-lsp-document-symbol" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "L3MON4D3/LuaSnip" },
    },
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup(opts)

      -- cmdline
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "nvim_lsp_document_symbol" },
          { { name = "buffer" } },
        }),
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" },
        }),
      })
    end,
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")

      ---@diagnostic disable-next-line: redefined-local
      local defaults = require("cmp.config.default")()

      return {
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        view = {
          docs_auto_open = true,
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Tab>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false }),
          ["<S-Tab>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "codeium" },
          { name = "orgmode" },
          { name = "mkdnflow" },
          { name = "path" },
          { name = "buffer" },
        }),
        preselect = cmp.PreselectMode.None,
        formatting = {
          format = function(_, item)
            local icons = util_defaults.icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      }
    end,
  },

  -- LSP Interactions
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    opts = {
      hover = {
        open_cmd = "!xdg-open",
      },
      code_action = {
        show_server_name = true,
        extend_gitsigns = true,
      },
      lightbulb = {
        virtual_text = true,
      },
      outline = {
        win_position = "left",
        close_after_jump = true,
      },
      finder = {
        default = "ref+def+impl",
      },
      ui = {
        code_action = util_defaults.icons.diagnostics.Hint,
        border = "single",
      },
    },
    keys = {
      -- Leader prefixed
      { "<leader>cpD", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek definition" },
      { "<leader>cgD", "<cmd>Lspsaga goto_definition<cr>", desc = "Goto definition" },
      { "<leader>cpd", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek type definition" },
      { "<leader>cgd", "<cmd>Lspsaga goto_type_definition<cr>", desc = "Goto type definition" },
      { "<leader>cf", "<cmd>Lspsaga finder<cr>", desc = "See references/implementations" },
      { "<leader>ch", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover" },
      { "<leader>co", "<cmd>Lspsaga outline<cr>", desc = "Code outline" },
      { "<leader>ca", "<cmd>Lspsaga code_action<cr>", desc = "Code action" },

      -- goto things
      { "gpD", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek definition" },
      { "gD", "<cmd>Lspsaga goto_definition<cr>", desc = "Goto definition" },
      { "gpd", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek type definition" },
      { "gd", "<cmd>Lspsaga goto_type_definition<cr>", desc = "Goto type definition" },

      -- Misc
      { "K", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover" },

      -- Diagnostics Quickjumps
      { "<leader>cdp", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Previous diagnostic" },
      { "<leader>cdn", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next diagnostic" },
    },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>c"] = { name = "+code" },
        ["<leader>cd"] = { name = "+diagnostics" },
        ["<leader>cp"] = { name = "+peek" },
        ["<leader>cg"] = { name = "+goto" },
        ["gp"] = { name = "+peek" },
      })
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = "BufEnter",
    opts = {
      formatters = {
        purstidy = {
          command = "purs-tidy",
          args = "format",
          stdin = true,
        },
      },
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "nixpkgs-fmt" },
        purescript = { "purstidy" },
      },
      format_on_save = function(_)
        if util_defaults.has_autoformat() then
          return { lsp_fallback = true }
        else
          return
        end
      end,
      format_after_save = function(_)
        if util_defaults.has_autoformat() then
          return { lsp_fallback = true, async = true }
        else
          return
        end
      end,
    },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>cF"] = { name = "+format" },
      })
    end,
    keys = {
      {
        "<leader>cFf",
        function()
          require("conform").format({ lsp_fallback = true })
        end,
        desc = "Format Document",
      },
      {
        "<leader>cFt",
        function()
          util_defaults.toggle_autoformat()
        end,
        desc = "Toggle Autoformatting",
      },
    },
  },

  -- jdtls
  {
    "mfussenegger/nvim-jdtls",
    lazy = true,
    ft = { "java" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {},
    config = function(_, _)
      local fname = vim.api.nvim_buf_get_name(0)
      local root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir

      local project_name = function(rdir)
        return rdir and vim.fs.basename(rdir)
      end
      --
      -- Where are the config and workspace dirs for a project?
      local jdtls_config_dir = function(prname)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. prname .. "/config"
      end

      local jdtls_workspace_dir = function(prname)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. prname .. "/workspace"
      end

      local jdtls = require("jdtls")
      local jdtls_tests = require("jdtls.tests")
      local jdtls_dap = require("jdtls.dap")

      local jdtls_options = {
        cmd = {
          "jdt-language-server",
          "-configuration",
          jdtls_config_dir(project_name(root_dir(fname))),
          "-data",
          jdtls_workspace_dir(project_name(root_dir(fname))),
        },

        root_dir = root_dir(fname),
        init_options = {
          bundles = {},
        },
      }

      -- Create autocommand to attach to all the java filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java" },
        callback = function()
          jdtls.start_or_attach(jdtls_options)
        end,
      })

      --
      -- Create some more bindings once the LSP is attached
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local wk = require("which-key")

          if client and client.name == "jdtls" then
            wk.register({
              ["<leader>cx"] = { name = "+extract" },
              ["<leader>cxv"] = { jdtls.extract_variable_all, "Extract Variable" },
              ["<leader>cxc"] = { jdtls.extract_constant, "Extract Constant" },
              ["gs"] = { jdtls.super_implementation, "Goto Super" },
              ["gS"] = { jdtls_tests.goto_subjects, "Goto Subjects" },
              ["<leader>co"] = { jdtls.organize_imports, "Organize Imports" },
            }, { mode = "n", buffer = args.buf })

            local nix_config = require("util.nix")
            if nix_config.dapConfigured then
              vim.list_extend(jdtls_options.init_options.bundles, nix_config.jdtls.bundles)

              -- Configure dap for java
              jdtls.setup_dap({ hotcodereplace = "auto", config_overrides = {} })
              jdtls_dap.setup_dap_main_class_configs()

              wk.register({
                ["<leader>t"] = { name = "+test" },
                ["<leader>tt"] = { jdtls_dap.test_class, "Run All Test" },
                ["<leader>tr"] = { jdtls_dap.test_nearest_method, "Run Nearest Test" },
                ["<leader>tT"] = { jdtls_dap.pick_test, "Run Test" },
              }, { mode = "n", buffer = args.buf })
            end
          end
        end,
      })

      -- Avoid race condition by attaching for the first time here
      jdtls.start_or_attach(jdtls_options)
    end,
  },

  -- Overseer
  {
    "stevearc/overseer.nvim",
    opts = {},
    lazy = true,
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<C-c>o"] = { name = "+overseer" },
      })
    end,
    keys = {
      { "<C-c>or", [[<cmd>OverseerRun<cr>]], desc = "Overseer Run" },
      { "<C-c>ot", [[<cmd>OverseerToggle<cr>]], desc = "Overseer Toggle" },
      { "<C-c>oq", [[<cmd>OverseerQuickAction<cr>]], desc = "Overseer Quick Action" },
      { "<C-c>ob", [[<cmd>OverseerBuild<cr>]], desc = "Overseer Build" },
    },
  },

  -- ScratchPad
  {
    "LintaoAmons/scratch.nvim",
    lazy = true,
    init = function()
      local wk = require("which-key")
      wk.register({
        [ "<leader>cs" ] = { "+scratch" },
      })
    end,
    keys = {
      { "<leader>csn", [[<CMD>Scratch<CR>]], desc = "Create new scratch" },
      { "<leader>cso", [[<CMD>ScratchOpen<CR>]], desc = "Open existing scratch" },
      { "<leader>css", [[<CMD>ScratchOpenFzf<CR>]], desc = "Search in scratches" },
      { "<leader>csp", [[<CMD>ScratchPad<CR>]], desc = "Open ScratchPad" },
    },
  },
}
