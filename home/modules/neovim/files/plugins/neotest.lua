--- @type LazyPluginSpec[]
return {
  {
    "nvim-neotest/neotest",
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<C-c>n"] = { name = "+test" },
      })
    end,
    dependencies = {
      { "andy-bell101/neotest-java" },
      { "rouge8/neotest-rust" },
      { "mrcjkb/neotest-haskell" },
      { "Issafalcon/neotest-dotnet" },
    },
    opts = function()
      return {
        adapters = {
          require("neotest-rust"),
          require("neotest-haskell"),
          require("neotest-dotnet")({
            custom_attributes = {
              xunit = { "SkippableEnvironmentFact" },
            },
            discovery_root = "solution",
          }),
        },
        output_panel = {
          open = "botright split | resize 15",
        },
        summary = {
          open = "aboveleft vsplit | vertical resize 50",
        },
        discovery = {
          concurrent = 2,
        },
      }
    end,
    config = true,
    -- stylua: ignore
    keys = {
      ---@diagnostic disable-next-line: missing-fields
      { "<C-c>nt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
      ---@diagnostic disable-next-line: missing-fields
      { "<C-c>nT", function() require("neotest").run.run(vim.loop.cwd()) end, desc = "Run All Test Files" },
      ---@diagnostic disable-next-line: missing-fields
      { "<C-c>nr", function() require("neotest").run.run() end, desc = "Run Nearest" },
      ---@diagnostic disable-next-line: missing-fields
      { "<C-c>ns", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      ---@diagnostic disable-next-line: missing-fields
      { "<C-c>no", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      ---@diagnostic disable-next-line: missing-fields
      { "<C-c>nO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      ---@diagnostic disable-next-line: missing-fields
      { "<C-c>nS", function() require("neotest").run.stop() end, desc = "Stop" },
      ---@diagnostic disable-next-line: missing-fields
      { "<C-c>nd", function() require("neotest").run.run({strategy = "dap"}) end, desc = "Debug Nearest" },
    },
  },
}
