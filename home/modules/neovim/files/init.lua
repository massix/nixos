local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Install Lazy
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local opts = {}

-- Basic options
require("config.options")

require("lazy").setup({
  spec = { import = "plugins" },

  -- All plugins are lazy by default
  defaults = {
    lazy = true,
    version = false,
  },

  -- Install a colorscheme
  install = { colorscheme = { "tokyonight", "habamax" } },

  -- Enable checker for updating plugins
  checker = { enabled = true },

  -- Disable some problematic native plugins of nvim
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}, opts)

-- Keymaps
require("config.keymaps")

-- Theme has to be the last thing
-- require("tokyonight").load()
vim.cmd([[colorscheme catppuccin]])
