---@type LazyPluginSpec[]
return {
  {
    "Vigemus/iron.nvim",
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>r"] = { name = "+repl" },
        ["<C-c>r"] = { name = "+repl" },
      })
    end,
    opts = function()
      -- local views = require("iron.view")
      return {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = { command = { "fish" } },
            typescript = { command = { "./node_modules/.bin/ts-node" } },
            javascript = { command = { "node" } },
            nix = { command = { "nix", "repl" } },
            racket = { command = { "racket" } },
            purescript = { command = { "spago", "repl" } },
            elvish = { command = { "elvish" } },

            -- Use Haskell-Tools to start a REPL
            haskell = {
              command = function(meta)
                local file = vim.api.nvim_buf_get_name(meta.current_bufnr)
                return require("haskell-tools").repl.mk_repl_cmd(file)
              end,
            },
          },

          -- repl_open_cmd = views.bottom(40),
        },

        highlight = {
          italic = true,
        },

        ignore_blank_lines = true,
      }
    end,
    config = function(_, opts)
      local ironCore = require("iron.core")
      ironCore.setup(opts)
    end,
    lazy = true,
    -- stylua: ignore
    keys = {
      -- Emacs-style bindings
      { "<C-c>rf", [[<cmd>IronFocus<cr>]], desc = "Start or Focus REPL" },
      { "<C-c>rr", [[<cmd>IronRestart<cr>]], desc = "Restart REPL" },
      { "<C-c>rh", [[<cmd>IronHide<cr>]], desc = "Hide REPL" },
      { "<C-c>re", function() require("iron.core").send_line() end, desc = "Send line to REPL", mode = "n" },
      { "<C-c>re", function() require("iron.core").visual_send() end, desc = "Send line to REPL", mode = "v" },
      { "<C-c>r<cr>", function() require("iron.core").send(nil, string.char(13)) end, desc = "Send <CR> to REPL", mode = "n" },
      { "<C-c>r<space>", function() require("iron.core").send(nil, string.char(03)) end, desc = "Send Interrupt to REPL", mode = "n" },
      { "<C-c>rq", function() require("iron.core").close_repl() end, desc = "Close REPL", mode = "n" },
      { "<C-c>rl", function() require("iron.core").send(nil, string.char(12)) end, desc = "Clear REPL", mode = "n" },
      { "<C-c>rF", function() require("iron.core").send_file() end, desc = "Send current file to REPL", mode = "n" },

      { "<leader>rS", "<cmd>IronRepl<cr>", desc = "Start REPL" },
      { "<leader>rR", "<cmd>IronRestart<cr>", desc = "Restart REPL" },
      { "<leader>rF", "<cmd>IronFocus<cr>", desc = "Focus REPL" },
      { "<leader>rH", "<cmd>IronHide<cr>", desc = "Hide REPL" },
      { "<leader>rs", function() require("iron.core").send_line() end, desc = "Send line to REPL", mode = "n" },
      { "<leader>rs", function() require("iron.core").visual_send() end, desc = "Send line to REPL", mode = "v" },
      { "<leader>r<cr>", function() require("iron.core").send(nil, string.char(13)) end, desc = "Send <CR> to REPL", mode = "n" },
      { "<leader>r<space>", function() require("iron.core").send(nil, string.char(03)) end, desc = "Send Interrupt to REPL", mode = "n" },
      { "<leader>rq", function() require("iron.core").close_repl() end, desc = "Close REPL", mode = "n" },
      { "<leader>rl", function() require("iron.core").send(nil, string.char(12)) end, desc = "Clear REPL", mode = "n" },
      { "<leader>rf", function() require("iron.core").send_file() end, desc = "Send current file to REPL", mode = "n" },
    },
  },
}
