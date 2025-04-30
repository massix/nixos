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
              .-*#####*+-.              .-+######+-
            :###############*:     .:*###############.
          .=#########**+==+*#*=..+###**++=+**#########:
          .######*:.         :+#+:...         .-#######:
          -#####+.        .-#+.   ..*#:         .*#####=
          -####*        .=#:          -*=.        +####=
          .####:      .++.              .*=.      :####.
          .*###     .+*.                  .#+     .###=
            .###.   :#:                      -#:   :##%.
            =##= .*+.                        .#+. =##:
              =## =-.                          .+#:.#:
              -#*..          Questel            +#=.
              ..:#=.  IP Business Intelligence  ..*#+
              +#:.#+.                          .#-.##=.
            +##= .+*:                        :#-. -#-.
            .###.   :#=.                    .=#.   :-...
          .####.     -#:                 .-#-     .:.-+.
          :####:    .. =#=              -#:.     .+.:#%:
          -#####   .%    :%=.         *#:       -#.:##%=
          -#####*. +#      :##-.  .:#*.       .#+.-###%=
          .%#####%*#%        ..-*%#=..      .*%:.######.
            -######%#########%#%#:.-#%%%#:.-#%=.*%####%:
            .#%%%%%%%%%%%%%#=.      .- .*%#-.=%#%%%%*.
                :=##%%%%-.          .:+%%#= -*###*=:
                    =%%%%##=---=+##%%%#=.
                    .#%%%%%%%%%%%%#-
                        .-+###*=.
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
        api.button("SPC .", " " .. " Find file"),
        api.button("SPC /", " " .. " Live Grep"),
        api.button("SPC ,", " " .. " Find Buffer"),
        api.button("SPC ;", "󰊢 " .. " Find Files (Git)"),
        api.button("SPC g G", "󰊢 " .. " Neogit"),
        api.button("SPC l l", "󰒲 " .. " Lazy UI"),
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
