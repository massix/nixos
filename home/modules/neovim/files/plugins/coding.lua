local util_defaults = require("util.defaults")
local nix = require("util.nix")

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
      {
        "grafana/vim-alloy",
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
        "gitcommit",
        "go",
        "gleam",
        "haskell",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
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
    "mfussenegger/nvim-ansible",
    event = "VeryLazy",
    opts = {},
    config = function()
      vim.filetype.add({
        pattern = {
          [".*playbook.*%.ya?ml"] = "yaml.ansible",
          [".*roles/.*/defaults/.*%.ya?ml"] = "yaml.ansible",
          [".*roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
        },
      })

      local group = vim.api.nvim_create_augroup("AnsibleAutoCmds", { clear = true })
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "yaml.ansible",
        group = group,
        callback = function(evt)
          require("which-key").add({
            buffer = evt.buf,
            mode = { "i", "n", "v" },
            { "<C-c>a", group = "ansible" },
            {
              "<C-c>ar",
              function()
                require("ansible").run()
              end,
              desc = "Run playbook",
              silent = true,
            },
          })
        end,
      })
    end,
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
        fish = { "fish" },
        bash = { "shellcheck" },
        sh = { "shellcheck" },
        go = { "golangcilint" },
        ghaction = { "actionlint" },
        lua = { "luacheck" },
        ansible = { "ansible_lint" },
        git = { "gitlint" },
        haskell = { "hlint" },
        dotenv = { "dotenv_linter" },
        editorconfig = { "editorconfig-checker" },
        gitcommit = { "commitlint" },
        c = { "clangtidy" },
        cpp = { "clangtidy" },
        python = { "pylint" },
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

  -- lazydev
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true },
    },
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        "lazy.nvim",
      },
    },
  },

  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "LspInfo" },
    dependencies = {
      -- Similar to .vscode things
      { "folke/neoconf.nvim" },
      { "b0o/schemastore.nvim" },
      { "Hoffs/omnisharp-extended-lsp.nvim" },
      { "chlihismail/yaml-companion.nvim", branch = "fix/deprecation" },
    },
    config = function()
      -- Make sure we load neoconf before configuring the lsp
      require("neoconf").setup()
      local lspconfig = require("lspconfig")

      -- Add new filetype for Gitlab CI
      vim.filetype.add({
        filename = {
          [".gitlab-ci.yml"] = "yaml.gitlab",
          [".gitlab-ci.yaml"] = "yaml.gitlab",
        },
      })

      local yaml_configuration = require("yaml-companion").setup({
        schemas = {
          {
            name = "Kubernetes 1.30.2",
            uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.2-standalone-strict/all.json",
          },
          {
            name = "Flux all schemas",
            uri = "https://github.com/fluxcd-community/flux2-schemas/raw/refs/heads/main/all.json",
          },
        },
        lspconfig = {
          flags = { debounce_text_changes = 150 },
          filetypes = { "yaml", "yaml.ghaction", "yaml.ansible", "yaml.gitlab" },
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              validate = true,
              format = { enable = false },
              schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
              },
              schemaDownload = { enable = true },
              schemas = {
                kubernetes = "",
              },
            },
          },
          on_attach = function()
            vim.keymap.set("n", "<leader>ys", function()
              require("yaml-companion").open_ui_select()
            end, { desc = "Select YAML Schema", buffer = true })
            vim.keymap.set("n", "<leader>yy", function()
              local schema = require("yaml-companion").get_buf_schema(0)
              if schema.result[1].name == "none" then
                vim.notify("No schema found", vim.log.levels.WARN)
              else
                vim.notify(schema.result[1].name, vim.log.levels.INFO)
              end
            end, { desc = "Print YAML Schema", buffer = true })
          end,
        },
      })

      ---@param client vim.lsp.Client
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

      vim.lsp.enable("nixd")
      vim.lsp.config("nixd", {
        settings = {
          nixd = {
            nixpkgs = { expr = "import <nixpkgs> {}" },
            options = {
              nixos = {
                expr = '(builtins.getFlake "' .. nix.flakePath .. '").nixosConfigurations.elendil.options',
              },
              ["home-manager"] = {
                expr = '(builtins.getFlake "' .. nix.flakePath .. '").homeConfigurations."massi@elendil".options',
              },
            },
          },
        },
        on_attach = attach_trouble,
      })

      vim.lsp.enable("lua_ls")
      vim.lsp.config("lua_ls", {
        on_attach = attach_trouble,
      })

      vim.lsp.enable("helm_ls")
      vim.lsp.config("helm_ls", {
        on_attach = attach_trouble,
      })

      vim.lsp.enable("jsonls")
      vim.lsp.config("jsonls", {
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

      -- FIXME: find a better way to make this work
      lspconfig.yamlls.setup(yaml_configuration)

      vim.lsp.enable("clangd")
      vim.lsp.config("clangd", {
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
        ---@param bufnr integer
        on_attach = function(client, bufnr)
          -- stylua: ignore
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>cS", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch source and headers (C/C++)" })

          attach_trouble(client, bufnr)
        end,
      })

      vim.lsp.enable("terraformls")
      vim.lsp.config("terraformls", {
        on_attach = attach_trouble,
        filetypes = { "terraform", "tf", "tfvars", "terraform-vars" },
        init_options = {
          terraform = {
            timeout = "30s",
          },
          validation = {
            enableEnhancedValidation = true,
          },
          experimentalFeatures = {
            prefillRequiredFields = true,
          },
        },
      })

      vim.lsp.enable("dockerls")
      vim.lsp.config("dockerls", {
        on_attach = attach_trouble,
      })

      vim.lsp.enable("ts_ls")
      vim.lsp.config("ts_ls", {
        on_attach = attach_trouble,
      })

      vim.lsp.enable("purescriptls")
      vim.lsp.config("purescriptls", {
        on_attach = attach_trouble,
      })

      vim.lsp.enable("bashls")
      vim.lsp.config("bashls", {
        on_attach = attach_trouble,
      })

      vim.lsp.enable("omnisharp")
      vim.lsp.config("omnisharp", {
        cmd = { "OmniSharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
        handlers = {
          ["textDocument/definition"] = require("omnisharp_extended").handler,
        },
        ---@diagnostic disable-next-line: missing-fields
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
            "<cmd>lua require('omnisharp_extended').lsp_definition()<CR>",
            { desc = "C# Goto definition" }
          )

          attach_trouble(client, bufnr)
        end,
      })

      vim.lsp.enable("gleam")
      vim.lsp.config("gleam", {
        on_attach = attach_trouble,
      })

      vim.lsp.enable("tinymist")
      vim.lsp.config("tinymist", {
        on_attach = attach_trouble,
      })

      vim.lsp.enable("gopls")
      vim.lsp.config("gopls", {
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

      vim.lsp.enable("ansiblels")
      vim.lsp.enable("nginx_language_server")
      vim.lsp.enable("fish_lsp")
      vim.lsp.enable("gitlab_ci_ls")
      vim.lsp.enable("pyright")

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

  -- Blink.cmp
  {
    "saghen/blink.cmp",
    dependencies = {
      { "rafamadriz/friendly-snippets" },
      { "onsails/lspkind.nvim" },
      { "saghen/blink.compat", version = "*" },
      { "hrsh7th/cmp-emoji" },
      { "hrsh7th/cmp-calc" },
    },
    version = "1.*",
    build = "nix run .#build-plugin",
    event = { "VeryLazy" },
    opts = {
      keymap = { preset = "super-tab" },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 1000,
        },
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local icon = ctx.kind_icon
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                    if dev_icon then
                      icon = dev_icon
                    end
                  else
                    icon = require("lspkind").symbolic(ctx.kind, {
                      mode = "symbol",
                    })
                  end
                  return icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  local hl = ctx.kind_hl
                  if vim.tbl_contains({ "Path" }, ctx.source_name) then
                    local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                    if dev_icon then
                      hl = dev_hl
                    end
                  end
                  return hl
                end,
              },
            },
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
            },
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "emoji", "calc" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          emoji = {
            name = "emoji",
            module = "blink.compat.source",
            score_offset = -30,
          },
          calc = {
            name = "calc",
            module = "blink.compat.source",
            score_offset = -40,
          },
        },
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
      },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
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
        virtual_text = false,
        sign = true,
      },
      outline = {
        win_position = "left",
        close_after_jump = true,
        auto_preview = true,
      },
      implement = {
        enable = true,
        sign = true,
      },
      finder = {
        default = "ref+def+impl",
      },
      breadcrumb = {
        enable = true,
        hide_keyword = true,
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
      vim.diagnostic.config({
        severity_sort = true,
      })
    end,
    init = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>c", group = "code" },
        { "<leader>cd", group = "diagnostics" },
        { "<leader>cp", group = "peek" },
        { "<leader>cg", group = "goto" },
        { "gp", group = "peek" },
      })
    end,
  },

  -- Inline diagnostics
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    config = function()
      require("tiny-inline-diagnostic").setup({ preset = "modern" })
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = "BufEnter",
    init = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>cF", group = "format" },
      })

      vim.g.conform_autoformat = true

      ---@diagnostic disable-next-line: duplicate-set-field
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
        gleam = { "gleam" },
        lua = { "stylua" },
        nix = { "nixpkgs_fmt" },
        purescript = { "purstidy" },
        fish = { "fish_indent" },
        java = { "google-java-format" },
        rust = { "rustfmt" },
        go = { "gofumpt" },
        yaml = { "yamlfmt" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        python = { "ruff_format" },
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

          require("which-key").add({
            {
              buffer = bufnr,
              { "<C-c>j", group = "jdt" },
              { "<C-c>jc", "<cmd>JdtCompile<CR>", desc = "Jdt Compile" },
              { "<C-c>ju", "<cmd>JdtUpdateDebugConfig<CR>", desc = "Jdt Update Debug Config" },
              { "<C-c>jU", "<cmd>JdtUpdateConfig<CR>", desc = "Jdt Update Config" },
              { "<C-c>jh", "<cmd>JdtUpdateHotcode<CR>", desc = "Jdt Hot Replace" },
              { "<C-c>jr", "<cmd>JdtRestart<CR>", desc = "Jdt Restart" },
              { "<C-c>jb", "<cmd>JdtBytecode<CR>", desc = "Jdt Bytecode" },
              { "<C-c>jS", "<cmd>JdtJshell<CR>", desc = "Jdt JShell" },
              { "<C-c>jR", vim.lsp.codelens.refresh, desc = "Force refresh Codelens" },
            },
          })
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
          wk.add({
            {
              buffer = args.buf,
              { "<leader>cx", group = "extract" },
              { "<leader>cxv", jdtls.extract_variable_all, desc = "Extract Variable" },
              { "<leader>cxc", jdtls.extract_constant, desc = "Extract Constant" },
              { "<leader>co", jdtls.organize_imports, desc = "Organize Imports" },
              { "gs", jdtls.super_implementation, desc = "Goto Super" },
              { "<C-c>nt", jdtls_dap.test_class, desc = "[jdtls] run all test in class" },
              { "<C-c>nd", jdtls_dap.test_nearest_method, desc = "[jdtls] debug nearest" },
              { "<C-c>nr", jdtls_dap.pick_test, desc = "[jdtls] run test from buffer" },
              { "<C-c>ng", jdtls_tests.generate, desc = "[jdtls] generate test class" },
              { "<C-c>nG", jdtls_tests.goto_subjects, desc = "Goto Subjects" },
            },
          })
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
      dap = true,
    },
    lazy = true,
    init = function()
      local wk = require("which-key")
      wk.add({
        { "<C-c>o", group = "overseer" },
        { "<C-c>oT", group = "toggle" },
      })
    end,
    keys = {
      { "<C-c>or", "<CMD>OverseerRun<cr>", desc = "Overseer Run" },
      { "<C-c>ot", "<CMD>OverseerToggle left<cr>", desc = "Overseer Toggle" },
      { "<C-c>oq", "<CMD>OverseerQuickAction<cr>", desc = "Overseer Quick Action" },
      { "<C-c>ob", "<CMD>OverseerBuild<cr>", desc = "Overseer Build" },
      { "<C-c>oTl", "<CMD>OverseerToggle left<cr>", desc = "Toggle left" },
      { "<C-c>oTr", "<CMD>OverseerToggle right<cr>", desc = "Toggle right" },
      { "<C-c>oTb", "<CMD>OverseerToggle bottom<cr>", desc = "Toggle bottom" },
    },
  },
}
