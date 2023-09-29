local Util = require('lazy.core.util')
local api = vim.api

local spec = {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "sindrets/diffview.nvim",
    "ibhagwan/fzf-lua"
  },
  config = true,
  keys = {
    { 
      "<leader>gg", 
      function() require('neogit').open() end, 
      desc = "Open Neogit" 
    },
    { 
      "<leader>gC", 
      function() require('neogit').open({ "commit" }) end, 
      desc = "Open Neogit commit" 
    },
  }
}

return spec

