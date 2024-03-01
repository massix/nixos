local load_textobjects = false
local util_defaults = require("util.defaults")

return {
  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
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
        enabled = true,
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
      },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c_sharp",
        "dhall",
        "dockerfile",
        "elisp",
        "elvish",
        "fish",
        "haskell",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "just",
        "kdl",
        "ledger",
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
        "toml",
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

      -- Add elisp grammar
      ---@diagnostic disable-next-line: inject-field
      require("nvim-treesitter.parsers").get_parser_configs().elisp = {
        install_info = {
          url = "https://github.com/Wilfred/tree-sitter-elisp",
          files = { "src/parser.c" },
          branch = "main",
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = "elisp",
      }

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

      vim.opt.foldenable = true
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldcolumn = "0"
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

  -- Direnv support
  {
    "direnv/direnv.vim",
    lazy = false,
    config = false,
    init = function()
      -- Stop spamming! I already have the lualine
      vim.g.direnv_silent_load = 1
    end,
    keys = {
      { "<leader>ne", "<cmd>DirenvExport<cr>", desc = "Direnv Export" },
    },
  },

  -- Enter nix develop automagically
  {
    "figsoda/nix-develop.nvim",
    event = "VeryLazy",
    config = function() end,
    keys = {
      { "<leader>nd", "<cmd>NixDevelop<cr>", desc = "Nix Develop" },
      { "<leader>ns", "<cmd>NixShell<cr>", desc = "Nix Shell" },
    },
  },

  -- yaml and json ls companion
  {
    "someone-stole-my-name/yaml-companion.nvim",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    event = { "VeryLazy" },
    config = false,
  },

  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "LspInfo" },
    dependencies = {
      -- Similar to .vscode things
      { "folke/neoconf.nvim" },
      { "folke/neodev.nvim" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "b0o/schemastore.nvim" },
      { "towolf/vim-helm" },
      { "Hoffs/omnisharp-extended-lsp.nvim" },
    },
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
      local cfg = require("yaml-companion").setup({
        lspconfig = {
          capabilities = capabilities,
          ---@param bufnr integer
          on_attach = function(_, bufnr)
            local wk = require("which-key")
            wk.register({
              ["<leader>cS"] = { "<cmd>Telescope yaml_schema<CR>", "Switch YAML schema", { buffer = bufnr } },
            })
          end,
        },
      })

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

      lspconfig.yamlls.setup(cfg)

      lspconfig.clangd.setup({
        cmd = {
          "clangd",
          "--all-scopes-completion",
          "--clang-tidy",
          "--enable-config",
          "--header-insertion=iwyu",
          "--import-insertions",
          "--completion-style=detailed",
          "--offset-encoding=utf-16",
          "--background-index",
          "--pch-storage=memory",
        },
        capabilities = capabilities,
        ---@param bufnr integer
        on_attach = function(_, bufnr)
          local wk = require("which-key")
          wk.register({
            ["<leader>cS"] = {
              "<cmd>ClangdSwitchSourceHeader<cr>",
              "Switch source and headers (C/C++)",
              { buffer = bufnr, mode = "n" },
            },
          })
        end,
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

      lspconfig.marksman.setup({
        capabilities = capabilities,
      })

      lspconfig.omnisharp.setup({
        cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
        handlers = {
          ["textDocument/definition"] = require("omnisharp_extended").handler,
        },
        -- capabilities = capabilities,
        enable_roslyn_analyzers = true,
        organize_imports_on_format = true,
        enable_import_completion = true,
        enable_editorconfig_support = true,
      })

      -- When using C# the Lspsaga go_to_definitions does not work, we have to rely on omnisharp_extended
      local c_sharp_group = vim.api.nvim_create_augroup("CSharp", { clear = true })
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "cs",
        group = c_sharp_group,
        callback = function()
          vim.api.nvim_buf_set_keymap(
            0,
            "n",
            "gD",
            "<cmd>lua require('omnisharp_extended').telescope_lsp_definitions()<CR>",
            { desc = "C# Goto definition" }
          )
        end,
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
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      { "rafamadriz/friendly-snippets" },
      { "honza/vim-snippets" },
    },
    config = function(_, opts)
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()
      require("luasnip").config.set_config(opts)
    end,
    opts = function()
      local types = require("luasnip.util.types")
      return {
        enable_autosnippets = true,
        history = true,
        updateevents = { "TextChanged", "TextChangedI" },
        ext_opts = {
          [types.choiceNode] = {
            active = {
              virt_text = { { "󱦱", "Error" } },
            },
          },
        },
      }
    end,
    keys = {
      {
        "<C-j>",
        function()
          require("luasnip").jump(1)
        end,
        mode = { "s", "i" },
      },
      {
        "<C-k>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "s", "i" },
      },
    },
  },

  -- completion engine
  {
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-calc" },
      { "hrsh7th/cmp-nvim-lsp-document-symbol" },
      { "hrsh7th/cmp-emoji" },
      { "davidsierradz/cmp-conventionalcommits" },
      { "L3MON4D3/LuaSnip" },
      { "saadparwaiz1/cmp_luasnip" },
    },
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup(opts)

      -- search
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "nvim_lsp_document_symbol" },
        }),
      })

      -- cmdline
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "cmdline" },
          { name = "path" },
        }),
      })

      -- Setup conventionalcommits for gitcommit files
      local group = vim.api.nvim_create_augroup("CmpExtra", { clear = true })
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = { "NeogitCommitMessage" },
        group = group,
        callback = function()
          if vim.g.cmp_conventionalcommits_source_id ~= nil then
            cmp.unregister_source(vim.g.cmp_conventionalcommits_source_id)
          end

          local source = require("cmp-conventionalcommits").new()

          ---@diagnostic disable-next-line: duplicate-set-field
          source.is_available = function()
            return vim.bo.filetype == "gitcommit" or vim.bo.filetype == "NeogitCommitMessage"
          end

          vim.g.cmp_conventionalcommits_source_id = cmp.register_source("conventionalcommits", source)

          cmp.setup.buffer({
            sources = cmp.config.sources({
              { name = "conventionalcommits" },
            }),
          })
        end,
      })
    end,

    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")

      ---@diagnostic disable-next-line: redefined-local
      local defaults = require("cmp.config.default")()

      return {
        enabled = function()
          local disabled_fts = {
            "TelescopePrompt",
            "toggleterm",
          }
          local ftype = vim.api.nvim_buf_get_option(0, "filetype")
          return not vim.tbl_contains(disabled_fts, ftype)
        end,
        completion = {
          completeopt = "menuone,noinsert,noselect,preview",
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        view = {
          docs = {
            auto_open = true,
          },
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
          { name = "luasnip" },
          { name = "mkdnflow" },
          { name = "orgmode" },
          { name = "path" },
          { name = "codeium" },
          { name = "emoji" },
          { name = "calc" },
        }, {
          { name = "buffer" },
        }),

        preselect = cmp.PreselectMode.None,
        formatting = {
          expandable_indicator = true,
          format = function(_, item)
            local icons = util_defaults.icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        matching = {
          disallow_fuzzy_matching = false,
          disallow_fullfuzzy_matching = false,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false,
        },
        experimental = {
          ghost_text = {
            enabled = true,
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
        extend_gitsigns = false,
      },
      lightbulb = {
        virtual_text = true,
      },
      outline = {
        win_position = "left",
        close_after_jump = true,
        auto_preview = false,
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
      { "<leader>ca", "<cmd>Lspsaga code_action<cr>", desc = "Code action" },
      { "<leader>cr", "<cmd>Lspsaga rename<cr>", desc = "LSP Rename" },

      -- goto things
      { "gpD", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek definition" },
      { "gD", "<cmd>Lspsaga goto_definition<cr>", desc = "Goto definition" },
      { "gpd", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek type definition" },
      { "gd", "<cmd>Lspsaga goto_type_definition<cr>", desc = "Goto type definition" },

      -- Misc
      { "K", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover" },

      -- Diagnostics
      { "<leader>cdp", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Previous diagnostic" },
      { "<leader>cdn", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next diagnostic" },
      { "<leader>cdw", "<cmd>Lspsaga show_workspace_diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>cdb", "<cmd>Lspsaga show_buf_diagnostics<cr>", desc = "Buffer diagnostics" },
      { "<leader>cdl", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Line diagnostics" },
      { "<leader>cdc", "<cmd>Lspsaga show_cursor_diagnostics<cr>", desc = "Line diagnostics" },
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
        ["<leader>cs"] = { "+scratch" },
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
