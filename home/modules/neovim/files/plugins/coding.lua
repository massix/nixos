local util_defaults = require("util.defaults")

return {
  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "VeryLazy" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", config = false },
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
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
        },
      },
      highlight = { enable = true },
      indent = { enable = false },
      ensure_installed = {
        "bash",
        "c_sharp",
        "dhall",
        "dockerfile",
        "elisp",
        "elvish",
        "fish",
        "gleam",
        "haskell",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "just",
        "kdl",
        "kotlin",
        "ledger",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "nix",
        "purescript",
        "query",
        "racket",
        "regex",
        "rust",
        "terraform",
        "tsx",
        "toml",
        "typescript",
        "typst",
        "vim",
        "yaml",
        "xml",
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

      -- Once treesitter loaded, we can change the foldmethod
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },

  -- Comments
  { "numToStr/Comment.nvim", lazy = false, config = true },

  {
    "ThePrimeagen/refactoring.nvim",
    cmd = "Refactor",
    opts = {},
    config = false,
  },

  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    opts = {},
    config = function()
      -- Add custom filetype for GitHub actions
      vim.filetype.add({
        pattern = {
          [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
          [".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
        },
      })

      require("lint").linters_by_ft = {
        yaml = { "yamllint" },
        terraform = { "tfsec", "trivy", "terraform_validate" },
        nix = { "statix", "deadnix" },
        dockerfile = { "hadolint" },
        fish = { "fish", "shellcheck" },
        bash = { "shellcheck" },
        sh = { "shellcheck" },
        go = { "golangcilint" },
        ghaction = { "actionlint" },
        lua = { "luacheck" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },

  -- highlights TODO and similar comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function(_, opts)
      require("todo-comments").setup(opts)
    end,
  },

  -- better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    event = { "LspAttach" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
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

  -- yaml and json ls companion
  -- TODO: revert back to upstream once https://github.com/someone-stole-my-name/yaml-companion.nvim/pull/50 gets merged
  {
    "agorgl/yaml-companion.nvim",
    branch = "patch-1",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    event = { "VeryLazy" },
    config = function()
      require("telescope").load_extension("yaml_schema")
    end,
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

      -- -- Capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities({ dynamicRegistration = true })

      ---@param client lsp.Client
      ---@param bufnr integer
      local attach_trouble = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          vim.api.nvim_buf_set_keymap(
            bufnr,
            "n",
            "<leader>co",
            "<cmd>Trouble symbols toggle focus=true win.position=left pinned=true<CR>",
            { desc = "LSP Symbols" }
          )
        end
      end

      local cfg = require("yaml-companion").setup({
        lspconfig = {
          capabilities = capabilities,
          filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.ghaction" },
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              validate = true,
              format = { enable = false },
              hover = true,
              schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
              },
              schemaDownload = { enable = true },
              schemas = {},
            },
          },
          ---@param bufnr integer
          on_attach = function(client, bufnr)
            -- stylua: ignore
            vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>cS", "<cmd>Telescope yaml_schema<CR>", { desc = "Switch YAML Schema" })
            attach_trouble(client, bufnr)
          end,
        },
      })

      lspconfig.nixd.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.helm_ls.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.jsonls.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
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
        on_attach = function(client, bufnr)
          -- stylua: ignore
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>cS", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch source and headers (C/C++)" })

          attach_trouble(client, bufnr)
        end,
      })

      lspconfig.terraformls.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
        -- See https://github.com/hashicorp/terraform-ls/issues/1655
        init_options = {
          terraform = {
            timeout = "30s",
          },
          validation = {
            enableEnhancedValidation = true,
          },
          experimentalFeatures = {
            prefillRequiredFields = false,
          },
        },
      })

      lspconfig.dockerls.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.tsserver.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.purescriptls.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.marksman.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.bashls.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.kotlin_language_server.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
        init_options = {
          storage_path = "/tmp/kotlinlangserver/",
        },
      })

      lspconfig.omnisharp.setup({
        cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
        handlers = {
          ["textDocument/definition"] = require("omnisharp_extended").handler,
        },
        -- capabilities = capabilities,
        settings = {
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
          },
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
          },
        },
        on_attach = function(client, bufnr)
          vim.api.nvim_buf_set_keymap(
            bufnr,
            "n",
            "gD",
            "<cmd>lua require('omnisharp_extended').telescope_lsp_definitions()<CR>",
            { desc = "C# Goto definition" }
          )

          attach_trouble(client, bufnr)
        end,
      })

      lspconfig.gleam.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.typst_lsp.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
      })

      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = attach_trouble,
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      -- Make sure that inlay hints are always enabled
      vim.api.nvim_create_augroup("LspInlayHints", {})
      vim.api.nvim_create_autocmd({ "LspAttach" }, {
        group = "LspInlayHints",
        callback = function(args)
          if not (args.data and args.data.client_id) then
            return
          end
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end
          local ip = client.server_capabilities.inlayHintProvider
          if ip == nil or ip == false then
            return
          end
          vim.lsp.inlay_hint.enable()
        end,
      })
    end,
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      { "rafamadriz/friendly-snippets" },
    },
    config = function(_, opts)
      require("luasnip.loaders.from_vscode").lazy_load()
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
      { "rcarriga/cmp-dap" },
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
        enabled = function()
          local disabled_commands = {
            IncRename = true,
            G = true,
            Git = true,
            ["G!"] = true,
            ["Git!"] = true,
          }

          local current_cmd = vim.fn.getcmdline():match("%S+")
          return not disabled_commands[current_cmd] or cmp.close()
        end,
      })

      cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        },
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
          local disabled_bts = {
            "nofile",
          }

          local ftype = vim.api.nvim_buf_get_option(0, "filetype")
          local btype = vim.api.nvim_get_option_value("buftype", { buf = 0 })

          return not (vim.tbl_contains(disabled_fts, ftype) or vim.tbl_contains(disabled_bts, btype))
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
          { name = "neorg" },
          { name = "orgmode" },
          { name = "path" },
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
            enabled = false, -- conflicts with codeium
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
    config = function(_, opts)
      require("lspsaga").setup(opts)
      vim.lsp.inlay_hint.enable(true)
    end,
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
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>cF"] = { name = "+format" },
      })

      vim.g.conform_autoformat = true

      vim.g.conform_toggle_autoformat = function()
        vim.g.conform_autoformat = not vim.g.conform_autoformat
        if vim.g.conform_autoformat then
          vim.notify("Autoformatting on")
        else
          vim.notify("Autoformatting off")
        end
      end
    end,
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
        nix = { "nixpkgs_fmt" },
        purescript = { "purstidy" },
        fish = { "fish_indent" },
        java = { "google-java-format" },
        rust = { "rustfmt" },
        go = { "gofumpt" },
        yaml = { "yamlfmt" },
      },
      format_on_save = function(_)
        if vim.g.conform_autoformat then
          return { lsp_fallback = true, timeout_ms = 2000 }
        else
          return
        end
      end,
      format_after_save = function(_)
        if vim.g.conform_autoformat then
          return { lsp_fallback = true, timeout_ms = 2000, async = true }
        else
          return
        end
      end,
    },
    -- stylua: ignore
    keys = {
      { "<leader>cFf", function() require("conform").format({ lsp_fallback = true }) end, desc = "Format Document" },
      { "<leader>cFt", function() vim.g.conform_toggle_autoformat() end, desc = "Toggle Autoformatting" },
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
      local nix_config = require("util.nix")

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
          "jdtls",
          "-configuration",
          jdtls_config_dir(project_name(root_dir(fname))),
          "-data",
          jdtls_workspace_dir(project_name(root_dir(fname))),
          "--jvm-arg=-javaagent:" .. nix_config.jdtls.lombok,
        },

        root_dir = root_dir(fname),

        init_options = {
          bundles = nix_config.jdtls.bundles,
        },

        on_attach = function(_, bufnr)
          jdtls.setup_dap()
          jdtls_dap.setup_dap_main_class_configs()

          require("which-key").register({
            ["j"] = {
              name = "+jdt",
              c = { "<CMD>JdtCompile<CR>", "Jdt Compile" },
              u = { "<CMD>JdtUpdateDebugConfig<CR>", "Jdt Update Debug Config" },
              U = { "<CMD>JdtUpdateConfig<CR>", "Jdt Update Config" },
              h = { "<CMD>JdtUpdateHotcode<CR>", "Jdt Hot Replace" },
              r = { "<CMD>JdtRestart<CR>", "Jdt Restart" },
              b = { "<CMD>JdtBytecode<CR>", "Jdt Bytecode" },
              S = { "<CMD>JdtJshell<CR>", "Jdt JShell" },
              R = { vim.lsp.codelens.refresh, "Force refresh Codelens" },
            },
          }, { mode = "n", buffer = bufnr, prefix = "<C-c>" })
        end,

        settings = {
          java = {
            completion = {
              enabled = true,
              favoriteStaticMembers = {
                "org.junit.jupiter.api.Assertions.*",
                "org.junit.jupiter.api.Assumptions.*",
                "org.junit.jupiter.api.DynamicContainer.*",
                "org.junit.jupiter.api.DynamicTest.*",
                "org.junit.Assert.*",
                "org.junit.Assume.*",
                "org.mockito.Mockito.*",
              },
            },
            format = {
              enabled = false,
            },
          },
        },
      }

      -- Create autocommand to attach to all the java filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java" },
        callback = function(args)
          jdtls.start_or_attach(jdtls_options)

          -- Register keys when in Java files
          local wk = require("which-key")
          wk.register({
            ["<leader>cx"] = { name = "+extract" },
            ["<leader>cxv"] = { jdtls.extract_variable_all, "Extract Variable" },
            ["<leader>cxc"] = { jdtls.extract_constant, "Extract Constant" },
            ["<leader>co"] = { jdtls.organize_imports, "Organize Imports" },
            ["gs"] = { jdtls.super_implementation, "Goto Super" },
          }, { mode = "n", buffer = args.buf })

          wk.register({
            ["t"] = { jdtls_dap.test_class, "[jdtls] run all test in class" },
            ["d"] = { jdtls_dap.test_nearest_method, "[jdtls] debug nearest" },
            ["r"] = { jdtls_dap.pick_test, "[jdtls] run test from buffer" },
            ["g"] = { jdtls_tests.generate, "[jdtls] generate test class" },
            ["G"] = { jdtls_tests.goto_subjects, "Goto Subjects" },
          }, { mode = "n", buffer = args.buf, prefix = "<C-c>n" })
        end,
      })

      -- Avoid race condition by attaching for the first time here
      jdtls.start_or_attach(jdtls_options)
    end,
  },

  -- Overseer
  {
    "stevearc/overseer.nvim",
    opts = {
      dap = false,
    },
    lazy = true,
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<C-c>o"] = { name = "+overseer" },
        ["<C-c>oT"] = {
          name = "+toggle",
          l = { "<cmd>OverseerToggle left<cr>", "Toggle left" },
          r = { "<cmd>OverseerToggle right<cr>", "Toggle right" },
          b = { "<cmd>OverseerToggle bottom<cr>", "Toggle bottom" },
        },
      })
    end,
    keys = {
      { "<C-c>or", [[<cmd>OverseerRun<cr>]], desc = "Overseer Run" },
      { "<C-c>ot", [[<cmd>OverseerToggle left<cr>]], desc = "Overseer Toggle" },
      { "<C-c>oq", [[<cmd>OverseerQuickAction<cr>]], desc = "Overseer Quick Action" },
      { "<C-c>ob", [[<cmd>OverseerBuild<cr>]], desc = "Overseer Build" },
    },
  },
}
