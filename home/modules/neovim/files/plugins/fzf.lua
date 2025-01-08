--- @type LazyPluginSpec[]
return {
  {
    "ibhagwan/fzf-lua",
    event = { "VimEnter" },
    opts = {
      "default-title",
    },
    config = function(_, opts)
      local fzf = require("fzf-lua")
      fzf.setup(opts)
      fzf.register_ui_select()
    end,

    keys = {
      { "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "[FZF] Live Grep" },
      { "<leader>.", "<cmd>FzfLua files<cr>", desc = "[FZF] Files" },
      { "<leader>,", "<cmd>FzfLua buffers<cr>", desc = "[FZF] Buffers" },
      { "<leader>m", "<cmd>FzfLua marks<cr>", desc = "[FZF] Marks" },
      { "<leader>r", "<cmd>FzfLua resume<cr>", desc = "[FZF] Resume" },
    },
  },
}
