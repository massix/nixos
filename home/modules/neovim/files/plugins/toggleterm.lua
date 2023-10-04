return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      float_opts = { border = "curved" },
      winbar = { enabled = true },
    },
    init = function()
      local wk = require("which-key")
      wk.register({
        ["<C-\\>"] = { name = "+terminal" },
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
    keys = {
      {
        "<C-\\>t",
        "<cmd>ToggleTerm direction=horizontal name=Terminal<CR>",
        desc = "Toggle default terminal",
      },
      {
        "<C-\\><C-\\>",
        function()
          vim.cmd([[:ToggleTerm direction=horizontal name=Terminal]])
        end,
        desc = "Toggle default terminal",
      },
      { "<C-\\>f", "<cmd>ToggleTerm direction=float name=Terminal<CR>", desc = "Toggle floating terminal" },
      { "<C-\\>a", "<cmd>ToggleTermToggleAll<CR>", desc = "Toggle all terminals" },
      { "<C-\\>s", "<cmd>TermSelect<CR>", desc = "Select terminal" },
    },
  },
}
