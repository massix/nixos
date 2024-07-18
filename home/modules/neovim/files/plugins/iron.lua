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

---@type LazyPluginSpec[]
return {
  {
    "Vigemus/iron.nvim",
    ft = supported_filetypes,
    opts = function()
      return {
        config = {
          scratch_repl = false,
          repl_definition = {
            sh = { command = { "fish" } },
            typescript = { command = { "./node_modules/.bin/ts-node" } },
            javascript = { command = { "node" } },
            nix = { command = { "nix", "repl", "--allow-dirty", "--impure" } },
            racket = { command = { "racket" } },
            purescript = { command = { "spago", "repl" } },
            elvish = { command = { "elvish" } },
            haskell = {
              command = function(meta)
                local file = vim.api.nvim_buf_get_name(meta.current_bufnr)
                return require("haskell-tools").repl.mk_repl_cmd(file)
              end,
            },
          },
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

      local group = vim.api.nvim_create_augroup("IronRepl", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = supported_filetypes,
        group = group,
        callback = function(args)
          local wk = require("which-key")

          -- stylua: ignore
          wk.add({
            { buffer = args.buf, noremap = false, mode = { "n" },
              { "<C-c>r", group = "repl" },
              { "<C-c>rf", "<CMD>IronReplFocus<CR>", desc = "Focus REPL" },
              { "<C-c>rh", "<CMD>IronReplHide<CR>", desc = "Hide REPL" },
              { "<C-c>r<CR>", function() require("iron.core").send(nil, string.char(13)) end, desc = "Send <CR> to REPL" },
              { "<C-c>r<space>", function() require("iron.core").send(nil, string.char(03)) end, desc = "Send Interrupt to REPL" },
              { "<C-c>rq", function() require("iron.core").close_repl() end, desc = "Close REPL" },
              { "<C-c>rl", function() require("iron.core").send(nil, string.char(12)) end, desc = "Clear REPL" },
              { "<C-c>rf", function() require("iron.core").send_file() end, desc = "Send current file to REPL" },
              { "<C-c>re", function() require("iron.core").send_line() end, desc = "Send line to REPL" },
            },
            { mode = "v", buffer = args.buf,
              { "<C-c>r", group = "repl" },
              { "<C-c>re", function() require("iron.core").visual_send() end, desc = "Send line to REPL" },
            }
          })
        end,
      })
    end,
    lazy = true,
  },
}
