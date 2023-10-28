--- @type LazyPluginSpec[]
return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      { "andy-bell101/neotest-java" },
      { "rouge8/neotest-rust", lazy = true, config = false },
      { "mrcjkb/neotest-haskell" },
    },
    opts = function()
      return {
        adapters = {
          require("neotest-rust"),
          require("neotest-haskell"),
        },
        output_panel = {
          open = "aboveleft vsplit | resize 15",
        },
        summary = {
          open = "aboveleft vsplit | vertical resize 50",
        },
      }
    end,
    config = true,
    -- stylua: ignore
    keys = {
      ---@diagnostic disable-next-line: missing-fields
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
      ---@diagnostic disable-next-line: missing-fields
      { "<leader>tT", function() require("neotest").run.run(vim.loop.cwd()) end, desc = "Run All Test Files" },
      ---@diagnostic disable-next-line: missing-fields
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest" },
      ---@diagnostic disable-next-line: missing-fields
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      ---@diagnostic disable-next-line: missing-fields
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      ---@diagnostic disable-next-line: missing-fields
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      ---@diagnostic disable-next-line: missing-fields
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
      ---@diagnostic disable-next-line: missing-fields
      { "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, desc = "Debug Nearest" },
    },
  },
}
