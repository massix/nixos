local nix = require("util.nix")

return {
  {
    dir = "~/Development/nvim-ghost.nvim",
    event = "VimEnter",
    enabled = true,
    init = function()
      vim.g.nvim_ghost_use_script = 0
      vim.g.nvim_ghost_binary_path = nix.ghostServer
    end,
  },
}
