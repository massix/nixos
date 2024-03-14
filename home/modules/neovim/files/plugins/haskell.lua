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
        hoogle = { mode = "telescope-local" },
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

      require("telescope").load_extension("ht")
      require("telescope").load_extension("hoogle")

      -- Set bindings only when the plugin is loaded
      local group = vim.api.nvim_create_augroup("HaskellTools", { clear = true })
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = { "haskell", "lhaskell", "cabal", "cabalproject" },
        group = group,
        callback = function(args)
          local wk = require("which-key")
          local ht = require("haskell-tools")
          -- stylua: ignore
          wk.register({
            h = {
              name = "+haskell",
              c = { vim.lsp.codelens.run, "Refresh Codelens", },
              s = { ht.hoogle.hoogle_signature, "Hoogle Signature", },
              R = { ht.repl.toggle, "Toggle REPL for current package", },
              r = { function() ht.repl.toggle(vim.api.nvim_buf_get_name(0)) end, "Toggle REPL for current buffer", },
              q = { ht.repl.quit, "Quit REPL", },
              e = { ht.lsp.buf_eval_all, "Evaluate all", },
            },
          }, { prefix = "<leader>c", buffer = args.buf })
        end,
      })
    end,
  },
}
