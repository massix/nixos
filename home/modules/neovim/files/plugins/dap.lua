-- Debug adapters for NeoVim
local nix = require("util.nix")
local json_transforms = {
  ["pwa-node"] = { "javascript", "typescript" },
  ["pwa-chrome"] = { "javascript", "typescript" },
  ["pwa-msedge"] = { "javascript", "typescript" },
  ["node-terminal"] = { "javascript", "typescript" },
  ["pwa-extensionHost"] = { "javascript", "typescript" },
  ["node"] = { "javascript", "typescript" },
  ["chrome"] = { "javascript", "typescript" },
  ["coreclr"] = { "cs" },
  ["ghc"] = { "haskell" },
  ["codelldb"] = { "rust", "c", "cpp" },
}

--- @type LazyPluginSpec[]
return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<C-c>d"] = { name = "+debug" },
        ["<C-c>da"] = { name = "+adapters" },
      })
    end,

    dependencies = {
      -- fancy UI for the debugger
      {
        "rcarriga/nvim-dap-ui",
      -- stylua: ignore
        keys = {
          ---@diagnostic disable-next-line: missing-fields
          { "<C-c>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },

          ---@diagnostic disable-next-line: missing-fields
          { "<C-c>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
        },
        opts = {},
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)

          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end
        end,
      },

      -- virtual text for the debugger
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },

      -- Configuration for Javascript
      {
        "mxsdev/nvim-dap-vscode-js",
        ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "purescript" },
        lazy = true,
        opts = {
          node_path = nix.nodePath,
          debugger_path = nix.vsCodeJsDebug,
          debugger_cmd = { nix.nodePath, nix.vsCodeJsDebug .. "/src/vsDebugServer.js" },
          adapters = {
            "pwa-node",
            "pwa-chrome",
            "pwa-msedge",
            "node-terminal",
            "pwa-extensionHost",
            "node",
            "chrome",
          },
        },
        config = function(_, opts)
          require("dap-vscode-js").setup(opts)

          for _, language in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
            require("dap").configurations[language] = {
              {
                type = "pwa-node",
                request = "launch",
                name = "Launch current file in new node process (" .. language .. ")",
                cwd = "${workspaceFolder}",
                args = { "${file}" },
                sourceMaps = true,
                protocol = "inspector",
              },
              {
                type = "pwa-node",
                request = "attach",
                name = "Attach",
                processId = require("dap.utils").pick_process,
                cwd = "${workspaceFolder}",
              },

              -- Jest configuration
              {
                type = "pwa-node",
                request = "launch",
                name = "Debug Jest Tests",
                -- trace = true, -- include debugger info
                runtimeExecutable = "node",
                runtimeArgs = {
                  "./node_modules/jest/bin/jest.js",
                  "--runInBand",
                },
                rootPath = "${workspaceFolder}",
                cwd = "${workspaceFolder}",
                console = "integratedTerminal",
                internalConsoleOptions = "neverOpen",
              },
            }
          end
        end,
      },
    },

    --- @type any[]
    -- stylua: ignore
    keys = {
      { "<C-c>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<C-c>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<C-c>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<C-c>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<C-c>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
      { "<C-c>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<C-c>dj", function() require("dap").down() end, desc = "Down" },
      { "<C-c>dk", function() require("dap").up() end, desc = "Up" },
      { "<C-c>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<C-c>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<C-c>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<C-c>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<C-c>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<C-c>ds", function() require("dap").session() end, desc = "Session" },
      { "<C-c>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<C-c>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
      { "<C-c>dJ", function() require("dap.ext.vscode").load_launchjs(nil, json_transforms) end, desc = "Load Launch JSON" },
    },

    opts = {},
    config = function()
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      local extension_path = nix.rustDebugger .. "/share/vscode/extensions/vadimcn.vscode-lldb"

      local liblldb_path = extension_path .. "/lldb/lib/liblldb.so"
      local dap = require("dap")

      require("dap.ext.vscode").json_decode = require("overseer.json").decode
      require("overseer").patch_dap(true)

      for name, sign in pairs(require("util.defaults").icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      dap.adapters.codelldb = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = nix.rustWrapper,
          args = { "--port", "${port}", "--liblldb", liblldb_path },
        },
      }

      dap.adapters.ghc = {
        type = "executable",
        command = "haskell-debug-adapter",
        args = { "--hackage-version=0.0.33.0" },
      }

      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      dap.adapters.netcoredbg = dap.adapters.coreclr

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }

      -- setup dap config by VsCode launch.json file
      require("dap.ext.vscode").load_launchjs(nil, json_transforms)
    end,
  },
}
