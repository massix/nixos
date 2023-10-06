-- Debug adapters for NeoVim
local nix = require("util.nix")

--- @type LazyPluginSpec[]
return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<leader>d"] = { name = "+debug" },
        ["<leader>da"] = { name = "+adapters" },
      })
    end,

    dependencies = {

      -- fancy UI for the debugger
      {
        "rcarriga/nvim-dap-ui",
      -- stylua: ignore
      keys = {
        ---@diagnostic disable-next-line: missing-fields
        { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },

        ---@diagnostic disable-next-line: missing-fields
        { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
      },
        opts = {},
        config = function(_, opts)
          -- setup dap config by VsCode launch.json file
          require("dap.ext.vscode").load_launchjs(nil, { ["pwa-node"] = { "javascript", "typescript" } })
          local dap = require("dap")
          local dapui = require("dapui")
          local nvimtree = require("nvim-tree.api").tree
          dapui.setup(opts)

          dap.listeners.after.event_initialized["dapui_config"] = function()
            nvimtree.close()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
            nvimtree.open()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
            nvimtree.open()
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
        ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
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
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
      { "<leader>dJ", function() require("dap.ext.vscode").load_launchjs(nil, { [ "pwa-node" ] = {"javascript", "typescript"}}) end, desc = "Load Launch JSON" },
    },

    config = function()
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(require("util.defaults").icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end
    end,
  },
}
