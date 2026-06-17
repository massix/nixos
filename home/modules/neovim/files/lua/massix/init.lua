local M = {}

M.configure_options = require("massix.options").configure_options
M.configure_autocmds = require("massix.options").configure_autocmds
M.configure_keybindings = require("massix.bindings").configure_keybindings

M.blink = require("massix.blink").blink
M.which_key = require("massix.whichkey").which_key
M.lspsaga = require("massix.lspsaga").lspsaga
M.treesitter = require("massix.treesitter").treesitter
M.lspconfig = require("massix.lspconfig").lspconfig
M.slimline = require("massix.statusline").slimline
M.formatter = require("massix.formatter").formatter
M.markdown = require("massix.markdown").markdown
M.git = require("massix.git").git
M.snacks_collection = require("massix.snacks_collection").snacks_collection
M.taskrunner = require("massix.taskrunner").taskrunner
M.notetaking = require("massix.notetaking").notetaking
M.shortcuts = require("massix.shortcuts").shortcuts
M.debugger = require("massix.debugger").debugger
M.repl = require("massix.repl").repl
M.ansible = require("massix.ansible").ansible
M.quicker = require("massix.quicker").quicker

M.direnv = function()
  MiniDeps.add({ source = "direnv/direnv.vim" })
  vim.g.direnv_silent_load = true
end

M.starter = function()
  local starter = require("mini.starter")
  starter.setup({
    evaluate_single = true,
    items = {
      starter.sections.builtin_actions(),
      starter.sections.recent_files(20, true),
    },
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.indexing("all", { "Builtin actions" }),
      starter.gen_hook.aligning("center", "center"),
    },
  })
end

M.files = function()
  local show_dotfiles = false
  local filter_show = function(_)
    return true
  end

  local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, ".")
  end

  local toggle_dotfiles = function()
    show_dotfiles = not show_dotfiles
    local new_filter = show_dotfiles and filter_show or filter_hide
    MiniFiles.refresh({ content = { filter = new_filter } })
  end

  require("mini.files").setup({
    content = { filter = filter_hide },
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(evt)
      require("which-key").add({
        { "g.", toggle_dotfiles, buffer = evt.data.buf, desc = "Toggle hidden files" },
      })
    end,
  })

  require("which-key").add({
    {
      "<leader>fm",
      function()
        MiniFiles.open()
      end,
      desc = "Open Mini.Files",
    },
    {
      "<leader>e",
      function()
        MiniFiles.open()
      end,
      desc = "Open Mini.Files",
    },
  })
end

M.trailspace = function()
  require("mini.trailspace").setup({ only_in_normal_buffers = true })
  local remove_trailspaces = true

  require("which-key").add({
    {
      "<leader>W",
      function()
        remove_trailspaces = not remove_trailspaces
        if remove_trailspaces then
          vim.notify("Trimming whitespaces", vim.log.levels.INFO)
        else
          vim.notify("Leaving whitespaces", vim.log.levels.INFO)
        end
      end,
      desc = "Toggle trailspaces",
    },
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("TrimWhitespace", { clear = true }),
    pattern = "*",
    callback = function()
      local ignored_filetypes = {}
      if remove_trailspaces and vim.bo.buftype == "" and not vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
        MiniTrailspace.trim()
        MiniTrailspace.trim_last_lines()
      end
    end,
  })
end

M.colorscheme = function()
  MiniDeps.add({ source = "folke/tokyonight.nvim" })
  require("tokyonight").setup({
    style = "moon",
    transparent = false,
    terminal_colors = true,
    styles = {
      keywords = { italic = false },
    },
    dim_inactive = true,
  })

  vim.cmd([[colo tokyonight]])
end

M.matchparen = function()
  MiniDeps.add({ source = "monkoose/matchparen.nvim" })
  vim.g.loaded_matchparen = 1
  require("matchparen").setup()
end

M.surround = function()
  require("mini.surround").setup({
    mappings = {
      add = "gsa", -- Add surrounding in Normal and Visual modes
      delete = "gsd", -- Delete surrounding
      find = "gsf", -- Find surrounding (to the right)
      find_left = "gsF", -- Find surrounding (to the left)
      highlight = "gsh", -- Highlight surrounding
      replace = "gsr", -- Replace surrounding
      update_n_lines = "gsn", -- Update `n_lines`
    },
  })
end

M.aerial = function()
  MiniDeps.add({
    source = "stevearc/aerial.nvim",
  })

  require("aerial").setup({
    backends = { "lsp", "treesitter", "markdown", "man" },
    layout = {
      default_direction = "prefer_left",
      placement = "edge",
    },

    highlight_on_hover = true,
    show_guides = true,
  })

  require("which-key").add({
    { "<leader>co", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
    { "<leader>cn", "<cmd>AerialNavToggle<cr>", desc = "Toggle Floating Aerial" },
  })
end

M.grugfar = function()
  MiniDeps.add({ source = "magicduck/grug-far.nvim" })
  require("grug-far").setup({
    keymaps = {
      replace = { n = "<localleader>r" },
      qflist = { n = "<localleader>q" },
      syncLocations = { n = "<localleader>s" },
      syncLine = { n = "<localleader>l" },
      close = { n = "<localleader>c" },
      historyOpen = { n = "<localleader>t" },
      historyAdd = { n = "<localleader>a" },
      refresh = { n = "<localleader>f" },
      openLocation = { n = "<localleader>o" },
      openNextLocation = { n = "<down>" },
      openPrevLocation = { n = "<up>" },
      gotoLocation = { n = "<enter>" },
      pickHistoryEntry = { n = "<enter>" },
      abort = { n = "<localleader>b" },
      help = { n = "g?" },
      toggleShowCommand = { n = "<localleader>w" },
      swapEngine = { n = "<localleader>e" },
      previewLocation = { n = "<localleader>i" },
      swapReplacementInterpreter = { n = "<localleader>x" },
      applyNext = { n = "<localleader>j" },
      applyPrev = { n = "<localleader>k" },
      syncNext = { n = "<localleader>n" },
      syncPrev = { n = "<localleader>p" },
      syncFile = { n = "<localleader>v" },
      nextInput = { n = "<tab>" },
      prevInput = { n = "<s-tab>" },
    },
  })
end

M.todo_comments = function()
  MiniDeps.add({ source = "folke/todo-comments.nvim", depends = { "nvim-lua/plenary.nvim" } })
  require("todo-comments").setup()
end

return M
