local M = {}

M.configure_options = function()
  local opt = vim.opt

  opt.autowrite = true -- Enable auto write
  opt.autoread = true -- Enable auto read
  opt.completeopt = "menu,menuone,noselect"
  opt.conceallevel = 3 -- Hide * markup for bold and italic
  opt.concealcursor = "vn" -- Hide stuff when not editing
  opt.confirm = true -- Confirm to save changes before exiting modified buffer
  opt.cursorline = true -- Enable highlighting of the current line
  opt.expandtab = true -- Use spaces instead of tabs
  opt.exrc = true -- Enable exrc files
  opt.foldenable = true
  opt.foldlevel = 99
  opt.foldlevelstart = 99
  opt.foldcolumn = "0"
  opt.foldclose = ""
  opt.foldtext = ""
  opt.formatoptions = "jcroqlnt" -- tcqj
  opt.grepformat = "%f:%l:%c:%m"
  opt.grepprg = "rg --vimgrep"
  opt.guifont = "IBM Plex Mono:h12"
  opt.ignorecase = true -- Ignore case
  opt.inccommand = "nosplit" -- preview incremental substitute
  opt.laststatus = 0
  opt.list = true -- Show some invisible characters
  opt.modeline = true
  opt.mouse = "a" -- Enable mouse mode
  opt.number = true -- Print line number
  opt.pumblend = 10 -- Popup blend
  opt.pumheight = 10 -- Maximum number of entries in a popup
  opt.relativenumber = true -- Relative line numbers
  opt.scrolloff = 4 -- Lines of context
  opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
  opt.shiftround = true -- Round indent
  opt.shiftwidth = 2 -- Size of an indent
  opt.shortmess:append({ W = true, I = true, c = true, C = true })
  opt.showmode = false -- Dont show mode since we have a statusline
  opt.sidescrolloff = 8 -- Columns of context
  opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
  opt.smartcase = true -- Don't ignore case with capitals
  opt.smartindent = true -- Insert indents automatically
  opt.spell = false -- Disable spelling
  opt.spelllang = { "en", "fr", "it" } -- Enable 3 languages
  opt.splitbelow = true -- Put new windows below current
  opt.splitkeep = "screen"
  opt.splitright = true -- Put new windows right of current
  opt.swapfile = false -- Do not create swapfiles
  opt.tabstop = 2 -- Number of spaces tabs count for
  opt.termguicolors = true -- True color support
  opt.timeoutlen = 300
  opt.undofile = true
  opt.undolevels = 10000
  opt.updatetime = 200 -- Save swap file and trigger CursorHold
  opt.wildmode = "longest:full,full" -- Command-line completion mode
  opt.winblend = 25
  opt.winborder = "rounded" -- Rounded borders
  opt.winminwidth = 5 -- Minimum window width
  opt.wrap = false -- Disable line wrap
end

M.configure_autocmds = function()
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightOnSearch", { clear = true }),
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
    end,
  })
end

return M
