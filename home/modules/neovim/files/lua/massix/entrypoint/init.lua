local M = {}

M.configure = function()
  local massix = require("massix")

  -- First setups
  massix.configure_options()
  massix.configure_keybindings(" ", ",")
  massix.configure_autocmds()

  -- These plugins are needed at startup
  MiniDeps.now(function()
    -- Make sure this is always the first one we load
    massix.which_key()

    require("mini.notify").setup()

    -- stylua: ignore
    require("which-key").add({
      { "<leader>n", group = "notifications" },
      { "<leader>nh", function() MiniNotify.show_history() end, desc = "History", },
      { "<leader>nc", function() MiniNotify.clear() end, desc = "Clear", },
    })

    require("mini.icons").setup()
    require("mini.cmdline").setup({
      autocomplete = {
        map_arrows = false,
        delay = 500,
      },
      autopeek = { n_context = 4 },
    })

    massix.direnv()
    massix.starter()
    massix.treesitter()
    massix.colorscheme()
    massix.slimline()
    massix.matchparen()
    massix.snacks_collection()
    massix.shortcuts()
  end)

  -- These plugins can be loaded after the startup
  MiniDeps.later(function()
    require("mini.tabline").setup()
    require("mini.move").setup()
    require("mini.align").setup()

    massix.blink()
    massix.lspconfig()
    massix.lspsaga()
    massix.grugfar()
    massix.git()
    massix.aerial()
    massix.markdown()
    massix.formatter()
    massix.trailspace()
    massix.files()
    massix.surround()
    massix.taskrunner()
    massix.notetaking()
    massix.debugger()
    massix.repl()
    massix.ansible()
    massix.todo_comments()
    massix.quicker()
    massix.claude()
    massix.opencode()
  end)
end

return M
