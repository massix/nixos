---@type LazyPluginSpec[]
return {

  -- ui components
  { "MunifTanjim/nui.nvim", lazy = true },

  -- Reactive HLGroups
  {
    "rasulomaroff/reactive.nvim",
    event = "VimEnter",
    opts = {
      load = {
        "catppuccin-mocha-cursor",
        "catppuccin-mocha-cursorline",
      },
    },
    config = function(_, opts)
      require("reactive").setup(opts)
      vim.opt.cursorline = true
      vim.wo.cursorline = true
    end,
  },
}
