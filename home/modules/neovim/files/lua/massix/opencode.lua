local M = {}

M.opencode = function()
  if vim.fn.executable("opencode") ~= 1 then
    return
  end

  MiniDeps.add({
    source = "sudo-tee/opencode.nvim",
    depends = {
      "meanderingprogrammer/render-markdown.nvim",
      "saghen/blink.cmp",
      "folke/snacks.nvim",
    },
  })

  require("opencode").setup({
    preferred_picker = "snacks",
    preferred_completion = "blink",
    ui = {
      input = {
        text = {
          wrap = true,
        },
      },
    },
  })

  require("which-key").add({
    { "<leader>o", group = "AI/OpenCode" },
    { "<leader>og", "<cmd>Opencode<cr>", desc = "Toggle OpenCode" },
    { "<leader>oi", "<cmd>Opencode open input<cr>", desc = "Open input" },
    { "<leader>os", "<cmd>Opencode session select<cr>", desc = "Select session" },
    { "<leader>op", "<cmd>Opencode models<cr>", desc = "Configure provider/model" },
  })
end

return M
