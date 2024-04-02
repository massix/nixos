---@type LazyPluginSpec
return {
  "Exafunction/codeium.vim",
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
      TelescopePrompt = false,
      vimwiki = false,
    }

    -- Register keymaps
    wk.register({
      -- stylua: ignore
      ["<C-c>c"] = {
        name = "+codeium",
        t =        { function() return vim.fn["codeium#Chat"]() end, "Open Chat", silent = true, expr = true },
        n =        { function() return vim.fn["codeium#CycleCompletions"](1) end, "Next Suggestion", silent = true, expr = true },
        p =        { function() return vim.fn["codeium#CycleCompletions"](-1) end, "Previous Suggestion", silent = true, expr = true },
        c =        { function() return vim.fn["codeium#Clear"]() end, "Clear Suggestion", silent = true, expr = true },
        C =        { function() return vim.fn["codeium#Complete"]() end, "Force Suggestion", silent = true, expr = true },
        ["<CR>"] = { function() return vim.fn["codeium#Accept"]() end, "Accept Suggestion", silent = true, expr = true },
      },
      mode = { "i", "n" },
    })
  end,
}
