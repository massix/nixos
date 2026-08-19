local M = {}

M.lspconfig = function()
  local flake_path = vim.fn.expand("~/.config/nixos")

  MiniDeps.add({
    source = "neovim/nvim-lspconfig",
    depends = {
      "folke/neoconf.nvim",
      "b0o/schemastore.nvim",
      "mosheavni/yaml-companion.nvim",
    },
  })

  require("neoconf").setup()

  vim.filetype.add({
    filename = {
      [".gitlab-ci.yml"] = "yaml.gitlab",
      [".gitlab-ci.yaml"] = "yaml.gitlab",
    },
  })

  vim.lsp.enable("lua_ls")

  vim.lsp.enable("nixd")
  vim.lsp.config("nixd", {
    settings = {
      nixd = {
        nixpkgs = { expr = "import <nixpkgs> {}" },
        options = {
          nixos = {
            expr = '(builtins.getFlake "' .. flake_path .. '").nixosConfigurations.elendil.options',
          },
          ["home-manager"] = {
            expr = '(builtins.getFlake "' .. flake_path .. '").homeConfigurations."massi@elendil".options',
          },
          ["nix-darwin"] = {
            expr = '(builtins.getFlake "' .. flake_path .. '").darwinConfigurations.hackintosh.options',
          },
        },
      },
    },
  })

  vim.lsp.enable("helm_ls")

  vim.lsp.enable("jsonls")
  vim.lsp.config("jsonls", {
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

  vim.lsp.enable("yamlls")
  vim.lsp.config(
    "yamlls",
    require("yaml-companion").setup({
      schemas = {
        {
          name = "Flux",
          uri = "https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/refs/heads/main/all.json",
        },
      },
      modeline = {
        auto_add = {
          on_attach = false,
          on_save = false,
        },
        overwrite_existing = true,
        validate_urls = true,
        notify = true,
      },
      datree = {
        cache_ttl = 86400,
      },
      cluster_crds = {
        fallback = true,
        cache_ttl = 86400,
      },
      lspconfig = {
        flags = {
          debounce_text_changes = 150,
        },
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            validate = true,
            format = { enable = false },
            hover = true,
            schemas = require("schemastore").yaml.schemas(),
            schemaStore = {
              enable = false,
              url = "",
            },
            schemaDownload = { enable = false },
          },
        },
      },
    })
  )

  vim.lsp.enable("terraformls")
  vim.lsp.config("terraformls", {
    init_options = {
      terraform = { timeout = "30s" },
    },
    validation = {
      enableEnhancedValidation = true,
    },
    experimentalFeatures = {
      prefillRequiredFields = true,
    },
  })

  vim.lsp.enable("dockerls")

  vim.lsp.enable("bashls")

  vim.lsp.enable("ansiblels")
  vim.lsp.config("ansiblels", {
    settings = {
      ansible = {
        ansible = {
          useFullyQualifiedCollectionNames = true,
        },
        -- We are already using nvim-lint for the linting
        ansibleLint = {
          enabled = false,
        },
        executionEnvironment = {
          enabled = false,
        },
      },
    },
  })

  vim.lsp.enable("nginx_language_server")
  vim.lsp.enable("fish_lsp")
  vim.lsp.enable("nushell")
  vim.lsp.enable("gitlab_ci_ls")
  vim.lsp.enable("pyright")
  vim.lsp.enable("gleam")

  vim.lsp.enable("gopls")
  vim.lsp.config("gopls", {
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

  -- Enable InlayHints automatically
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LspInlayHints", { clear = true }),
    pattern = "*",
    callback = function(params)
      if not (params.data and params.data.client_id) then
        return
      end

      local client = vim.lsp.get_client_by_id(params.data.client_id)
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

  -- Add a keybinding to switch YAML schema when editing YAML files
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("YAMLEditing", { clear = true }),
    pattern = { "yaml", "yaml.*" },
    callback = function(evt)
      require("which-key").add({
        { "<leader>cy", group = "yaml" },
        {
          "<leader>cys",
          function()
            require("yaml-companion").open_ui_select()
          end,
          desc = "Select YAML Schema",
          buffer = evt.buf,
        },
        {
          "<leader>cyd",
          function()
            require("yaml-companion").open_datree_crd_select()
          end,
          desc = "Select YAML Schema from Datree CRD",
          buffer = evt.buf,
        },
        {
          "<leader>cyc",
          function()
            require("yaml-companion").open_cluster_crd_select()
          end,
          desc = "Select YAML Schema from Cluster CRD",
          buffer = evt.buf,
        },
        {
          "<leader>cym",
          function()
            require("yaml-companion").add_crd_modelines(evt.buf, {})
          end,
          desc = "Add CRD Modeline",
          buffer = evt.buf,
        },
      })
    end,
  })
end

return M
