-- Configuration for Rust-Tools
--- @type LazyPluginSpec[]
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    dependencies = { "neovim/nvim-lspconfig", "mfussenegger/nvim-dap" },
    ft = { "rust" },
    init = function()
      local nix = require("util.nix")
      local extension_path = nix.rustDebugger .. "/share/vscode/extensions/vadimcn.vscode-lldb"
      local liblldb_path = extension_path .. "/lldb/lib/liblldb.so"

      vim.g.rustaceanvim = {
        tools = {
          executor = require("rustaceanvim.executors").neotest,
        },
        dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(nix.rustWrapper, liblldb_path),
        },
        server = {
          on_attach = function(_, bufnr)
            local wk = require("which-key")
            wk.add({
              {
                buffer = bufnr,
                { "<C-c>r", group = "rust" },
                { "<C-c>rM", "<CMD>RustLsp expandMacro<CR>", desc = "Expand macro" },
                { "<C-c>re", "<CMD>RustLsp explainError<CR>", desc = "Explain error" },
                { "<C-c>rD", "<CMD>RustLsp renderDiagnostic<CR>", desc = "Render diagnostic" },
                { "<C-c>rc", "<CMD>RustLsp openCargo<CR>", desc = "Open Cargo" },
                { "<C-c>rk", "<cmd>RustLsp openDocs<CR>", desc = "Open docs.rs" },
                { "<C-c>rp", "<cmd>RustLsp parentModule<CR>", desc = "Parent Module" },

                { "<C-c>rd", group = "debuggables" },
                { "<C-c>rda", "<CMD>RustLsp debuggables<CR>", desc = "All debuggables" },
                { "<C-c>rdd", "<CMD>RustLsp debug<CR>", desc = "From current position" },

                { "<C-c>rr", group = "runnables" },
                { "<C-c>rra", "<CMD>RustLsp runnables<CR>", desc = "All runnables" },
                { "<C-c>rrr", "<CMD>RustLsp run<CR>", desc = "From current position" },
              },
            })

            vim.lsp.codelens.refresh()
          end,
        },
      }
    end,
    config = function() end,
  },
}
