return {
  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.theta")
      local api = require("alpha.themes.dashboard")

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

      dashboard.header.val = vim.split(logo, "\n")
      dashboard.header.opts = {
        position = "center",
        hl = "Exception",
      }

      -- stylua: ignore
      dashboard.buttons.val = {
        { type = "text", val = "Quick actions", opts = { hl = "SpecialComment", position = "center" } },
        { type = "padding", val = 1 },
        api.button("SPC f f", " " .. " Find file"),
        api.button("SPC s g", " " .. " Live Grep"),
        api.button("SPC s p", " " .. " Open project"),
        api.button("SPC s h", " " .. " Search Help"),
        api.button("SPC s O", " " .. " Search Org Header"),
        api.button("SPC o a", " " .. " Org Agenda"),
        api.button("SPC s j", "󱕸 " .. " Jumplist"),
        api.button("SPC s M", "󰆍 " .. " Search man pages"),
        api.button("SPC SPC", " " .. " Legendary"),
        api.button("SPC g g", "󰊢 " .. " Neogit"),
        api.button("SPC S o", "󰊠 " .. " Spectre"),
        api.button("SPC p p", "󱎫 " .. " Pomodoro"),
        api.button("SPC l l", "󰒲 " .. " Lazy UI"),
        api.button("SPC n d", " " .. " Nix Development"),
        { type = "padding", val = 1 },
        api.button("SPC q q", " " .. " Quit"),
      }

      for _, value in ipairs(dashboard.buttons.val) do
        if value.type == "button" then
          value.opts.hl_shortcut = "Structure"
        end
      end

      local section_mru = {
        type = "group",
        val = {
          {
            type = "text",
            val = "Recent files",
            opts = {
              hl = "SpecialComment",
              shrink_margin = false,
              position = "center",
            },
          },
          { type = "padding", val = 1 },
          {
            type = "group",
            val = function()
              return { dashboard.mru(0, vim.fn.getcwd()) }
            end,
            opts = { shrink_margin = false },
          },
        },
      }

      dashboard.footer = {
        type = "text",
        val = "",
        opts = {
          position = "center",
          hl = "AlphaFooter",
        },
      }

      local fortune = {
        val = require("alpha.fortune")(),
        type = "text",
        opts = {
          position = "center",
          hl = "Exception",
        },
      }

      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.header,
        { type = "padding", val = 2 },
        section_mru,
        { type = "padding", val = 2 },
        dashboard.buttons,
        { type = "padding", val = 2 },
        fortune,
        { type = "padding", val = 2 },
        dashboard.footer,
      }
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

      require("alpha").setup(dashboard.config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local nix = require("util.nix")

          dashboard.footer.val = "NeoVim started in " .. ms .. "ms from " .. nix.nvimHome
          pcall(vim.cmd.AlphaRedraw)
        end,
      })

      vim.api.nvim_create_autocmd("DirChanged", {
        pattern = "*",
        callback = function()
          require("alpha").redraw()
          vim.cmd.AlphaRedraw()
        end,
      })
    end,
    keys = {
      { "<leader>A", "<cmd>Alpha<CR>", desc = "Alpha Dashboard" },
    },
  },
}
