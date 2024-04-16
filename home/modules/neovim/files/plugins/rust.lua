--- @type LazyPluginSpec[]

-- Configuration for Rust-Tools
-- TODO: move to rustaceans.nvim asap
return {
  {
    "mrcjkb/rustaceanvim",
    dependencies = { "neovim/nvim-lspconfig", "mfussenegger/nvim-dap" },
    ft = { "rust" },
    init = function()
      local nix = require("util.nix")
      local extension_path = nix.rustDebugger .. "/share/vscode/extensions/vadimcn.vscode-lldb"
      local liblldb_path = extension_path .. "/lldb/lib/liblldb.so"

      vim.g.rustaceanvim = {
        tools = {
          executor = require("rustaceanvim.executors").toggleterm,
        },
        dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(nix.rustWrapper, liblldb_path),
        },
        server = {
          on_attach = function(_, bufnr)
            local wk = require("which-key")
            wk.register({
              r = {
                name = "+rust",
                d = {
                  name = "+debuggables",
                  a = { "<cmd>RustLsp debuggables<CR>", "All Debuggables" },
                  d = { "<cmd>RustLsp debug<CR>", "From current position" },
                },
                r = {
                  name = "+runnables",
                  a = { "<cmd>RustLsp runnables<CR>", "All Runnables" },
                  r = { "<cmd>RustLsp run<CR>", "From current position" },
                },
                M = { "<cmd>RustLsp expandMacro<CR>", "Expand macro" },
                e = { "<cmd>RustLsp explainError<CR>", "Explain error" },
                D = { "<cmd>RustLsp renderDiagnostic<CR>", "Render Diagnostic" },
                c = { "<cmd>RustLsp openCargo<CR>", "Open Cargo" },
                k = { "<cmd>RustLsp openDocs<CR>", "Open docs.rs" },
                p = { "<cmd>RustLsp parentModule<CR>", "Parent Module" },
              },
            }, { buffer = bufnr, prefix = "<C-c>" })
          end,
        },
      }
    end,
    config = function() end,
  },
}
