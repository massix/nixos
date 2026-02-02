local M = {}

M.lspsaga = function()
  MiniDeps.add({ source = "nvimdev/lspsaga.nvim" })

  require("lspsaga").setup({
    hover = {
      open_cmd = "!xdg-open",
    },
    code_action = {
      show_server_name = true,
      extend_gitsigns = false,
    },
    lightbulb = {
      virtual_text = false,
      sign = true,
    },
    outline = {
      win_position = "left",
      close_after_jump = true,
      auto_preview = true,
    },
    implement = {
      enable = true,
      sign = true,
    },
    finder = {
      default = "ref+def+impl",
    },
    breadcrumb = {
      enable = true,
      hide_keyword = true,
    },
    ui = {
      code_action = " ",
      border = "single",
    },
  })

  local wk = require("which-key")
  local sc = function(cmd)
    return "<cmd>Lspsaga " .. cmd .. "<cr>"
  end
  wk.add({
    -- Leader prefixed
    { "<leader>cg", group = "goto" },
    { "<leader>cp", group = "peek" },
    { "<leader>cpD", sc("peek_definition"), desc = "Peek definition" },
    { "<leader>cgD", sc("goto_definition"), desc = "Goto definition" },
    { "<leader>cpd", sc("peek_type_definition"), desc = "Peek type definition" },
    { "<leader>cgd", sc("goto_type_definition"), desc = "Goto type definition" },

    { "<leader>cf", sc("finder"), desc = "See references/implementations" },
    { "<leader>ch", sc("hover_doc"), desc = "Hover" },
    { "<leader>ca", sc("code_action"), desc = "Code action" },
    { "<leader>cr", sc("rename"), desc = "LSP Rename" },

    -- goto things
    { "gpD", sc("peek_definition"), desc = "Peek definition" },
    { "gD", sc("goto_definition"), desc = "Goto definition" },
    { "gpd", sc("peek_type_definition"), desc = "Peek type definition" },
    { "gd", sc("goto_type_definition"), desc = "Goto type definition" },

    -- Misc
    { "K", sc("hover_doc"), desc = "Hover" },

    -- Diagnostics
    { "<leader>cd", group = "diagnostic" },
    { "<leader>cdp", sc("diagnostic_jump_prev"), desc = "Previous diagnostic" },
    { "<leader>cdn", sc("diagnostic_jump_next"), desc = "Next diagnostic" },
    { "<leader>cdw", sc("show_workspace_diagnostics"), desc = "Workspace diagnostics" },
    { "<leader>cdb", sc("show_buf_diagnostics"), desc = "Buffer diagnostics" },
    { "<leader>cdl", sc("show_line_diagnostics"), desc = "Line diagnostics" },
    { "<leader>cdc", sc("show_cursor_diagnostics"), desc = "Line diagnostics" },
  })
end

return M
