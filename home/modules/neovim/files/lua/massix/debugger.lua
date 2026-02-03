local M = {}

M.debugger = function()
  for _, source in ipairs({
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    "mxsdev/nvim-dap-vscode-js",
    "leoluz/nvim-dap-go",
  }) do
    MiniDeps.add({ source = source })
  end

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
    ["delve"] = { "go" },
  }

  require("dapui").setup({
    layouts = {
      {
        elements = {
          "repl",
          "console",
        },
        size = 20,
        position = "bottom",
      },
      {
        elements = {
          { id = "scopes", size = 0.25 },
          { id = "breakpoints", size = 0.25 },
          { id = "stacks", size = 0.25 },
          { id = "watches", size = 0.25 },
        },
        size = 50,
        position = "right",
      },
    },
  })

  require("nvim-dap-virtual-text").setup({})
  require("dap-vscode-js").setup({})
  require("dap-go").setup({})
  require("dap.ext.vscode").json_decode = require("overseer.json").decode

  local dap = require("dap")

  for _, language in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
    dap.configurations[language] = {
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

  dap.adapters.delve = {
    type = "server",
    port = "${port}",
    executable = {
      command = "dlv",
      args = { "dap", "-l", "127.0.0.1:${port}" },
    },
  }

  -- Neotest needs this
  dap.adapters.go = dap.adapters.delve
  require("dap.ext.vscode").load_launchjs(nil, json_transforms)

  -- stylua: ignore
  require("which-key").add({
    { "<C-c>d", group = "debug" },
    { "<C-c>du", function() require("dapui").toggle({}) end, desc = "Toggle UI" },
    { "<C-c>de", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "v" } },
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

    { "<C-c>da", group = "adapters" },
  })
end

return M
