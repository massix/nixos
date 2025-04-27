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

  ui = {
    border = "rounded",
  },

  -- Install a colorscheme
  install = { colorscheme = { "catppuccin", "habamax" } },

  -- Enable checker for updating plugins
  checker = {
    enabled = true,
    notify = false,
  },

  -- Disable some problematic native plugins of nvim
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
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

-- vim.cmd.language("en_US.utf8")
vim.cmd.colorscheme("catppuccin")

if vim.g.neovide then
  require("config.gui").setup()
end

-- Autoreload buffer
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "c" then
      vim.cmd.checktime()
    end
  end,
})

-- Use 'q' to exit some common buffers
vim.api.nvim_create_autocmd("Filetype", {
  group = vim.api.nvim_create_augroup("QLeave", { clear = true }),
  pattern = {
    "neotest-summary",
    "neotest-output",
    "neotest-output-panel",
    "neotest-attach",
    "dapui_console",
    "dapui_watches",
    "qf",
    "help",
    "man",
    "git",
    "gitsigns.blame",
    "org-roam-node-buffer",
  },
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf })
  end,
})

-- Set filetype to typst for typ files
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.typ",
  group = vim.api.nvim_create_augroup("Typst", { clear = true }),
  callback = function()
    vim.bo.filetype = "typst"
  end,
})

-- Syntax in markdown file is sometimes reset
local markdown_syntax = vim.api.nvim_create_augroup("MarkdownSyntax", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = markdown_syntax,
  pattern = "markdown",
  callback = function()
    vim.bo.syntax = "on"
  end,
})

-- Activate spelling in org, norg and markdown files
local text_spelling = vim.api.nvim_create_augroup("TextSpelling", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = text_spelling,
  pattern = { "org", "norg", "markdown" },
  callback = function()
    vim.opt_local.spell = true
  end,
})
