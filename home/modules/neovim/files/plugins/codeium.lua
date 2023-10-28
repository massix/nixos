---@type LazyPluginSpec
return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  opts = {
    tools = { language_server = require("util.nix").codeium },
  },
  lazy = true,
  event = { "VeryLazy" },
  config = true,
}
