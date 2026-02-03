local M = {}

M.markdown = function()
  MiniDeps.add({ source = "meanderingprogrammer/render-markdown.nvim" })
  require("render-markdown").setup({
    render_modes = true,
    anti_conceal = {
      enabled = true,
    },
    completions = {
      blink = { enabled = true },
      lsp = { enabled = true },
    },
    heading = {
      border = true,
      border_virtual = true,
    },
    code = {
      conceal_delimiters = false,
      border = "thin",
      inline_pad = 2,
    },
    pipe_table = {
      preset = "round",
    },
    indent = {
      enabled = true,
      render_modes = { "n", "i", "c" },
    },
  })
end

return M
