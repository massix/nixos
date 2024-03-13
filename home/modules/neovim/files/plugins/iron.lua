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
          wk.register({
            r = {
              name = "+repl",
              f = { "<CMD>IronFocus<CR>", "Start or focus REPL" },
              r = { "<CMD>IronRestart<CR>", "Restart REPL" },
              h = { "<CMD>IronHide<CR>", "Hide REPL" },
              ["<CR>"] = {
                function() require("iron.core").send(nil, string.char(13)) end,
                "Send <CR> to REPL"
              },
              ["<space>"] = {
                function() require("iron.core").send(nil, string.char(03)) end,
                "Send Interrupt to REPL"
              },
              q = {
                function() require("iron.core").close_repl() end,
                "Close REPL"
              },
              l = {
                function() require("iron.core").send(nil, string.char(12)) end,
                "Clear REPL"
              },
              F = {
                function() require("iron.core").send_file() end,
                "Send current file to REPL"
              },
              e = {
                function() require("iron.core").send_line() end,
                "Send line to REPL"
              }
            },
          }, { buffer = args.buf, noremap = false, prefix = "<C-c>", mode = "n" })

          -- stylua: ignore
          wk.register({
            r = {
              name = "+repl",
              e = {
                function() require("iron.core").visual_send() end,
                "Send line to REPL"
              },
            },
          }, { buffer = args.buf, noremap = false, prefix = "<C-c>", mode = "v" })
        end,
      })
    end,
    lazy = true,
  },
}
