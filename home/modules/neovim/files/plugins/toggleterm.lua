return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      float_opts = { border = "double" },
      winbar = { enabled = true },
      shade_terminals = false,
      open_mapping = false,
      insert_mappings = false,
    },
    config = true,
    lazy = false,
    cmd = { "ToggleTerm" },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<c-\\>"] = { name = "+terminal" },
      })

      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        group = vim.api.nvim_create_augroup("ToggleTermHandler", { clear = true }),
        callback = function()
          local opts = { buffer = 0 }

          -- Leave terminal mode
          vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)

          -- Move through windows
          vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)

          -- Resize
          vim.keymap.set("t", "<C-Up>", [[<C-\><C-n><C-Up>]], opts)
          vim.keymap.set("t", "<C-Down>", [[<C-\><C-n><C-Down>]], opts)
          vim.keymap.set("t", "<C-Left>", [[<C-\><C-n><C-Left>]], opts)
          vim.keymap.set("t", "<C-Right>", [[<C-\><C-n><C-Right>]], opts)

          -- Win command
          vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
        end,
      })
    end,

    -- stylua: ignore
    keys = {
      { "<c-\\><c-\\>", [[<cmd>execute v:count . "ToggleTerm direction=horizontal"<CR>]], desc = "Toggle default terminal", silent = true },
      { "<c-\\>t", [[<cmd>execute v:count . "ToggleTerm direction=horizontal"<CR>]], desc = "Toggle default terminal", silent = true },
      { "<c-\\>f", [[<cmd>execute v:count . "ToggleTerm direction=float"<CR>]], desc = "Toggle floating terminal", silent = true },
      { "<c-\\>a", "<cmd>ToggleTermToggleAll<CR>", desc = "Toggle all terminals", silent = true },
      { "<c-\\>s", "<cmd>TermSelect<CR>", desc = "Select terminal", silent = true },
      { "<c-\\>S", [[<cmd>execute "ToggleTermSendCurrentLine ". v:count<CR>]], desc = "Send current line to terminal" },
      { "<c-\\>S", [[<cmd>execute "ToggleTermSendVisualSelection " . v:count<CR>]], mode = { "v" }, desc = "Send visual selection to terminal" },
    },
  },
}
