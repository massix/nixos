---@type LazyPluginSpec[]
return {
  {
    "MrcJkb/haskell-tools.nvim",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-lua/plenary.nvim",
    },
    lazy = true,
    ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
    version = "^3",
    init = function()
      vim.g.haskell_tools = {
        tools = {
          codeLens = { autoRefresh = true },
          hoogle = { mode = "telescope-local" },
          hover = { enable = true },
          definition = { hoogle_signature_fallback = true },
          repl = { handler = "toggleterm" },
        },
        dap = {
          cmd = { "haskell-debug-adapter", "--hackage-version=0.0.33.0" },
          auto_discover = true,
        },
      }
    end,
    config = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>cH"] = { name = "+haskell" },
      })

      require("telescope").load_extension("ht")
      require("telescope").load_extension("hoogle")
    end,
    keys = {
      {
        "<leader>cHc",
        function()
          vim.lsp.codelens.run()
        end,
        desc = "Refresh Codelens",
      },
      {
        "<leader>cHs",
        function()
          require("haskell-tools").hoogle.hoogle_signature()
        end,
        desc = "Hoogle Signature",
      },
      {
        "<leader>cHR",
        function()
          require("haskell-tools").repl.toggle()
        end,
        desc = "Toggle REPL for current package",
      },
      {
        "<leader>cHr",
        function()
          require("haskell-tools").repl.toggle(vim.api.nvim_buf_get_name(0))
        end,
        desc = "Toggle REPL for current buffer",
      },
      {
        "<leader>cHq",
        function()
          require("haskell-tools").repl.quit()
        end,
        desc = "Quit REPL",
      },
      {
        "<leader>cHe",
        function()
          require("haskell-tools").lsp.buf_eval_all()
        end,
        desc = "Evaluate snippet",
      },
    },
  },
}
