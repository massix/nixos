---@type LazyPluginSpec[]
return {
  {
    "MrcJkb/haskell-tools.nvim",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-lua/plenary.nvim",
    },
    ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
    opts = {
      tools = {
        codeLens = { autoRefresh = true },
        hoogle = { mode = "auto" },
        hover = { enable = true },
        definition = { hoogle_signature_fallback = true },
        repl = { handler = "toggleterm" },
      },
      dap = {
        cmd = { "haskell-debug-adapter --hackage-version=0.0.33.0" },
        auto_discover = true,
      },
    },
    config = function(_, opts)
      vim.g.haskell_tools = opts

      -- Set bindings only when the plugin is loaded
      local group = vim.api.nvim_create_augroup("HaskellTools", { clear = true })
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = { "haskell", "lhaskell", "cabal", "cabalproject" },
        group = group,
        callback = function(args)
          local wk = require("which-key")
          local ht = require("haskell-tools")
          wk.add({
            {
              buffer = args.buf,
              { "<leader>ch", group = "haskell" },
              { "<leader>chc", vim.lsp.codelens.run, desc = "Run Codelens" },
              { "<leader>chs", ht.hoogle.hoogle_signature, desc = "Hoogle Signature" },
              { "<leader>chR", ht.repl.toggle, desc = "Toggle REPL" },
              {
                "<leader>chr",
                function()
                  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
                end,
                desc = "Toggle REPL for current buffer",
              },
              { "<leader>chq", ht.repl.quit, desc = "Quit REPL" },
              { "<leader>che", ht.lsp.buf_eval_all, desc = "Evaluate all" },
            },
          })
        end,
      })
    end,
  },
}
