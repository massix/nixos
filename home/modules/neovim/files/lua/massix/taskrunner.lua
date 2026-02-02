local M = {}

M.taskrunner = function()
  MiniDeps.add({ source = "stevearc/overseer.nvim" })
  require("overseer").setup({ dap = true })
  require("which-key").add({
    { "<C-c>o", group = "overseer" },
    { "<C-c>or", "<CMD>OverseerRun<cr>", desc = "Overseer Run" },
    { "<C-c>ot", "<CMD>OverseerToggle left<cr>", desc = "Overseer Toggle" },
    { "<C-c>oq", "<CMD>OverseerQuickAction<cr>", desc = "Overseer Quick Action" },
    { "<C-c>ob", "<CMD>OverseerBuild<cr>", desc = "Overseer Build" },
    { "<C-c>os", "<CMD>OverseerShell<cr>", desc = "Overseer Shell" },

    { "<C-c>oT", group = "toggle" },
    { "<C-c>oTl", "<CMD>OverseerToggle left<cr>", desc = "Toggle left" },
    { "<C-c>oTr", "<CMD>OverseerToggle right<cr>", desc = "Toggle right" },
    { "<C-c>oTb", "<CMD>OverseerToggle bottom<cr>", desc = "Toggle bottom" },
  })
end

return M
