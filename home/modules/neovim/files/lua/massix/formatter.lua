local M = {}

M.formatter = function()
  MiniDeps.add({ source = "stevearc/conform.nvim" })
  MiniDeps.add({ source = "mfussenegger/nvim-lint" })
  local autoformat = true

  require("conform").setup({
    formatters_by_ft = {
      bash = { "shellcheck" },
      fish = { "fish_indent" },
      gleam = { "gleam" },
      go = { "gofumpt" },
      hcl = { "packer_fmt" },
      java = { "google-java-format" },
      javascript = { "prettier" },
      lua = { "stylua" },
      nix = { "nixpkgs_fmt" },
      python = { "ruff_format" },
      rust = { "rustfmt" },
      typescript = { "prettier" },
      typst = { "typstyle" },
      yaml = { "yamlfmt" },
    },
    default_format_opts = { lsp_format = "fallback", timeout_ms = 2000 },
    format_on_save = function(_)
      if autoformat then
        return {}
      else
        return
      end
    end,
  })

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
    dotenv = { "dotenv_linter" },
    editorconfig = { "editorconfig-checker" },
    gitcommit = { "commitlint" },
    python = { "pylint" },
  }

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })

  require("which-key").add({
    { "<leader>cF", group = "format" },
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
        autoformat = not autoformat
        if autoformat then
          vim.notify("Autoformatting on")
        else
          vim.notify("Autoformatting off")
        end
      end,
      desc = "Toggle Autoformatting",
    },
  })
end

return M
