local M = {}

M.opencode = function()
  MiniDeps.add({ source = "nickjvandyke/opencode.nvim" })

  vim.g.opencode_opts = {
    events = {
      reload = true,
    },
  }

  require("which-key").add({
    {
      "<C-a>",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      desc = "Ask opencode…",
      mode = { "n", "x" },
    },
    {
      "<C-x>",
      function()
        require("opencode").select()
      end,
      desc = "Execute opencode action…",
      mode = { "n", "x" },
    },
    {
      "<C-.>",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle opencode",
      mode = { "n", "t" },
    },
    {
      "go",
      function()
        return require("opencode").operator("@this ")
      end,
      desc = "Add range to opencode",
      mode = "n",
      expr = true,
    },
    {
      "goo",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      desc = "Add line to opencode",
      mode = "n",
      expr = true,
    },
    {
      "<S-C-u>",
      function()
        require("opencode").command("session.half.page.up")
      end,
      desc = "Scroll opencode up",
      mode = "n",
    },
    {
      "<S-C-d>",
      function()
        require("opencode").command("session.half.page.down")
      end,
      desc = "Scroll opencode down",
      mode = "n",
    },
    { "+", "<C-a>", desc = "Increment under cursor", noremap = true },
    { "-", "<C-x>", desc = "Decrement under cursor", noremap = true },
  })
end

return M
