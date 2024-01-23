return {
  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      -- stylua: ignore
      -- luacheck: ignore
      local logo = [[
                                  _
        88888b   d888b  888b  88 8P 888888    88888b    888     888b  88 88  d888b 88
        88   88 88   88 88`8b 88      88      88   88  88 88    88`8b 88 88 88   ` 88
        88   88 88   88 88 88 88      88      88888P  88   88   88 88 88 88 88     88
        88   88 88   88 88 `8b88      88      88     d8888888b  88 `8b88 88 88   , ""
        88888P   `888P  88  `888      88      88     88     `8b 88  `888 88  `888P 88

                                  nnnmmm
                  \||\       ;;;;%%%@@@@@@       \ //,        You're on Neovim now!
                    V|/     %;;%%%%%@@@@@@@@@@  ===Y//
                    68=== ;;;;%%%%%%@@@@@@@@@@@@    @Y
                    ;Y   ;;%;%%%%%%@@@@@@@@@@@@@@    Y
                    ;Y  ;;;+;%%%%%%@@@@@@@@@@@@@@@    Y
                    ;Y__;;;+;%%%%%%@@@@@@@@@@@@@@i;;__Y
                  iiY"";;   "uu%@@@@@@@@@@uu"   @"";;;>
                          Y     "UUUUUUUUU"     @@
                          `;       ___ _       @
                            `;.  ,====\\=.  .;'
  You're on Nixos now!        ``""""`==\\=='
                                    `;=====
                                      ===            [massi_x86]
]]

      dashboard.section.header.val = vim.split(logo, "\n")
      -- stylua: ignore
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", "<CMD> Telescope find_files<CR>"),
        dashboard.button("L", "󰒲 " .. " Lazy", "<CMD> Lazy<CR>"),
        dashboard.button("g", " " .. " Find text", "<CMD> Telescope live_grep<CR>"),
        dashboard.button("h", " " .. " Load project", "<CMD> Telescope projects<CR>"),
        dashboard.button("n", " " .. " Load Nix Environment", "<CMD> NixDevelop<CR>"),
        dashboard.button("e", " " .. " Org Folder", "<CMD> cd ~/org <BAR> e .<CR>"),
        dashboard.button("E", " " .. " Org Index", "<CMD> cd ~/org <BAR> e ./index.org<CR>"),
        dashboard.button("m", " " .. " Agenda", [[<CMD> lua require("orgmode.api.agenda").agenda({ span = 5 })<CR>]]),
        dashboard.button("w", " " .. " Work agenda", [[<CMD> lua require("orgmode.api.agenda").agenda({ span = 5, filters = "+work" })<CR>]]),
        dashboard.button("W", " " .. " Personal agenda", [[<CMD> lua require("orgmode.api.agenda").agenda({ span = 5, filters = "+personal" })<CR>]]),
        dashboard.button("l", "✓ " .. " Todos", [[<CMD> lua require("orgmode.api.agenda").todos()<CR>]]),
        dashboard.button("t", " " .. " Work todos", [[<CMD> lua require("orgmode.api.agenda").todos( { filters = "+work" })<CR>]]),
        dashboard.button("T", " " .. " Personal todos", [[<CMD> lua require("orgmode.api.agenda").todos( { filters = "+personal" })<CR>]]),
        dashboard.button("q", " " .. " Quit", "<CMD> qa<CR>"),
      }

      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end

      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      return dashboard
    end,

    config = function(_, dashboard)
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local nix = require("util.nix")

          dashboard.section.footer.val = "NeoVim started in " .. ms .. "ms from " .. nix.nvimHome
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
    keys = {
      { "<leader>A", "<cmd> Alpha<CR>", desc = "Alpha Dashboard" },
    },
  },
}
