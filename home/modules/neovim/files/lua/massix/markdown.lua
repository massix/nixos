local M = {}

M.markdown = function()
  MiniDeps.add({ source = "meanderingprogrammer/render-markdown.nvim" })
  require("render-markdown").setup({
    file_types = { "markdown", "opencode_output" },
    render_modes = true,
    anti_conceal = {
      enabled = false,
    },
    completions = {
      blink = { enabled = true },
      lsp = { enabled = true },
    },
    heading = {
      width = "full",
    },
    code = {
      border = "thin",
      inline_pad = 2,
      width = "full",
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
