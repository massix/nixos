--- @type LazyPluginSpec[]

-- Configuration for Rust-Tools
return {
  {
    "simrat39/rust-tools.nvim",
    dependencies = { "neovim/nvim-lspconfig", "mfussenegger/nvim-dap" },
    ft = { "rust" },
    opts = function()
      local nix = require("util.nix")
      local extension_path = nix.rustDebugger .. "/share/vscode/extensions/vadimcn.vscode-lldb"

      local liblldb_path = extension_path .. "/lldb/lib/liblldb.so"

      return {
        tools = {
          executor = require("rust-tools.executors.toggleterm"),
        },
        dap = {
          adapter = require("rust-tools.dap").get_codelldb_adapter(nix.rustWrapper, liblldb_path),
        },
      }
    end,
    config = function(_, opts)
      local rt = require("rust-tools")
      rt.setup({ tools = opts.tools, dap = opts.dap })

      local wk = require("which-key")
      wk.register({
        ["<leader>cR"] = {
          name = "+rust",
          h = { "<cmd>RustSetInlayHints<CR>", "Enable inlay hints" },
          H = { "<cmd>RustUnsetInlayHints<CR>", "Disable inlay hints" },
          r = { "<cmd>RustRunnables<CR>", "Runnables" },
          d = { "<cmd>RustDebuggables<CR>", "Debuggables" },
          M = { "<cmd>RustExpandMacro<CR>", "Expand macro" },
          k = { "<cmd>RustHoverRange<CR>", "Hover Range" },
          c = { "<cmd>RustOpenCargo<CR>", "Open Cargo" },
          p = { "<cmd>RustParentModule<CR>", "Parent Module" },
          R = { "<cmd>CargoReload<CR>", "Cargo Reload" },
        },
      })
    end,
  },
}
