return {
  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = [[
        .        :    :::.     .::::::.  .::::::. :::  .,::      .:.::::.     .:.
        ;;,.    ;;;   ;;`;;   ;;;`    ` ;;;`    ` ;;;  `;;;,  .,;;`;.  ,;'  ,;'
        [[[[, ,[[[[, ,[[ '[[, '[==/[[[[,'[==/[[[[,[[[    '[[,,[['   [nn[, ,[[.od8b
        $$$$$$$$"$$$c$$$cc$$$c  '''    $  '''    $$$$     Y$$$P    $"   $c$$$"  "$$
        888 Y88" 888o888   888,88b    dP 88b    dP888   oP"``"Yo,  Yb,_,8P Y8b,,d8P
        MMM  M'  "MMMYMM   ""`  "YMmMY"   "YMmMY" MMM,m"       "Mm, "YMP"   "YMP"
      ]]

      dashboard.section.header.val = vim.split(logo, "\n")
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", ":Telescope find_files<CR>"),
        dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
        dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert<CR>"),
        dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", " " .. " Find text", ":Telescope live_grep<CR>"),
        dashboard.button(
          "e",
          " " .. " Edit Nixos Configuration",
          ":cd ~/.config/nixos<cr> <BAR> e ~/.config/nixos/flake.nix<CR>"
        ),
        dashboard.button("d", " " .. " Load Nix Environment", ":NixDevelop<CR>"),
        dashboard.button("q", " " .. " Quit", ":qa<CR>"),
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
  },
}
