---@type LazyPluginSpec[]
return {
  {
    "Exafunction/codeium.vim",
    enabled = function()
      -- Only enable Codeium in Elendil
      return vim.fn.hostname() == "elendil" or vim.fn.hostname() == "M-G6R1WM94QJ"
    end,
    event = { "VeryLazy" },
    init = function()
      local wk = require("which-key")

      -- Do not use default bindings
      vim.g.codeium_disable_bindings = 1

      -- Inject path to language server
      vim.g.codeium_bin = require("util.nix").codeium

      -- Enable completion globally
      vim.g.codeium_enabled = true

      vim.g.codeium_filetypes = {
        -- Disable completion for org, markdown and special files
        org = false,
        orgagenda = false,
        md = false,
        toggleterm = false,
        vimwiki = false,
      }

    -- Register keymaps
    -- stylua: ignore
    wk.add({
      {
        mode = { "i", "n" },
        { "<C-c>C", group = "codeium" },
        { "<C-c>Ct", function() return vim.fn["codeium#Chat"]() end, desc = "Open Chat", silent = true, expr = true },
        { "<C-c>Cn", function() return vim.fn["codeium#CycleCompletions"](1) end, desc = "Next Suggestion", silent = true, expr = true },
        { "<C-c>Cp", function() return vim.fn["codeium#CycleCompletions"](-1) end, desc = "Previous Suggestion", silent = true, expr = true },
        { "<C-c>Cc", function() return vim.fn["codeium#Clear"]() end, desc = "Clear Suggestion", silent = true, expr = true },
        { "<C-c>CC", function() return vim.fn["codeium#Complete"]() end, desc = "Force Suggestion", silent = true, expr = true },
        { "<C-c>C<CR>", function() return vim.fn["codeium#Accept"]() end, desc = "Accept Suggestion", silent = true, expr = true },
      },
    })
    end,
  },
  {
    "https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git",
    enabled = function()
      return vim.fn.hostname() == "aiwendil"
    end,
    event = { "BufEnter" },
    opts = {
      gitlab_url = "https://git.questel.com",
      statusline = {
        enabled = true,
      },
      code_suggestions = {
        auto_filetypes = {
          "go",
          "markdown",
          "terraform",
          "sh",
        },
        enabled = true,
      },
      language_server = {
        workspace_settings = {
          telemetry = {
            enabled = false,
          },
        },
      },
    },
  },
}
