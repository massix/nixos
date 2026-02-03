local M = {}

M.repl = function()
  MiniDeps.add({ source = "vigemus/iron.nvim" })

  local supported_filetypes = {
    "sh",
    "typescript",
    "javascript",
    "nix",
    "racket",
    "purescript",
    "elvish",
    "haskell",
    "lua",
  }

  require("iron.core").setup({
    config = {
      scratch_repl = false,
      close_window_on_exit = false,
      buflisted = true,
      repl_open_cmd = require("iron.view").split.belowright(40),
      repl_definition = {
        sh = { command = { "fish" } },
        typescript = { command = { "./node_modules/.bin/ts-node" } },
        javascript = { command = { "node" } },
        nix = { command = { "nix", "repl", "--allow-dirty", "--impure" } },
        elvish = { command = { "elvish" } },
      },
    },
    highlight = {
      italic = true,
    },

    ignore_blank_lines = true,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("IronRepl", { clear = true }),
    pattern = supported_filetypes,
    callback = function(evt)
      require("which-key").add({
        {
          buffer = evt.buf,
          noremap = false,
          mode = { "n" },
          { "<C-c>r", group = "repl" },
          { "<C-c>rf", "<CMD>IronFocus<CR>", desc = "Focus REPL" },
          { "<C-c>rh", "<CMD>IronHide<CR>", desc = "Hide REPL" },
          {
            "<C-c>r<CR>",
            function()
              require("iron.core").send(nil, string.char(13))
            end,
            desc = "Send <CR> to REPL",
          },
          {
            "<C-c>r<space>",
            function()
              require("iron.core").send(nil, string.char(03))
            end,
            desc = "Send Interrupt to REPL",
          },
          {
            "<C-c>rq",
            function()
              require("iron.core").close_repl()
            end,
            desc = "Close REPL",
          },
          {
            "<C-c>rl",
            function()
              require("iron.core").send(nil, string.char(12))
            end,
            desc = "Clear REPL",
          },
          {
            "<C-c>rF",
            function()
              require("iron.core").send_file()
            end,
            desc = "Send current file to REPL",
          },
          {
            "<C-c>re",
            function()
              require("iron.core").send_line()
            end,
            desc = "Send line to REPL",
          },
        },
        {
          mode = "v",
          buffer = evt.buf,
          { "<C-c>r", group = "repl" },
          {
            "<C-c>re",
            function()
              require("iron.core").visual_send()
            end,
            desc = "Send line to REPL",
          },
        },
      })
    end,
  })
end

return M
