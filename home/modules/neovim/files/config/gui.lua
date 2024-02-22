M = {}

M.default_scale = 1.0

M.change_scale_factor = function(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end

M.setup = function()
  vim.o.guifont = "Rec_Mono_Casual,Symbols_Nerd_Font_Mono:h10"
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_hide_mouse_when_typing = false
  vim.g.neovide_theme = "dark"
  vim.g.neovide_unlink_border_highlights = true
  vim.g.neovide_confirm_quit = false
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_scale_factor = M.default_scale

  -- Register keybinding to modify the scale
  require("which-key").register({
    ["<leader>+"] = {
      name = "+scale",
      ["+"] = { function() require("config.gui").change_scale_factor(1.25) end, "Increase scale" },
      ["-"] = { function() require("config.gui").change_scale_factor(1/1.25) end, "Decrease scale" },
    },
  })

  -- Also create some more immediate bindings
  vim.keymap.set("n", "<C-=>", function() require("config.gui").change_scale_factor(1.25) end, { desc = "Increase scale" })
  vim.keymap.set("n", "<C-->", function() require("config.gui").change_scale_factor(1/1.25) end, { desc = "Decrease scale" })
end

return M
