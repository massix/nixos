return {
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    event = { "BufEnter" },
    enabled = false,
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>H"] = { name = "+hardtime" },
      })
    end,
    opts = {
      disabled_filetypes = {
        "NeogitStatus",
        "NeogitCommitView",
        "NeogitLogView",
        "NeogitDiffView",
        "NvimTree",
        "lazy",
        "qf",
        "netrw",
        "help",

        -- Saga
        "sagafinder",

        -- DAP-UI Buffers
        "dapui_scopes",
        "dapui_breakpoints",
        "dapui_stacks",
        "dapui_watches",
        "dapui_debugpoints",
        "dapui_console",
        "dap_repl",
      },
    },
    keys = {
      { "<leader>He", "<cmd>Hardtime enable<cr>", desc = "Enable hardtime" },
      { "<leader>Hd", "<cmd>Hardtime disable<cr>", desc = "Disable hardtime" },
      { "<leader>Hr", "<cmd>Hardtime report<cr>", desc = "Show report" },
    },
  },
}
