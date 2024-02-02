--- @type LazyPluginSpec[]
return {
  {
    "rest-nvim/rest.nvim",
    ft = { "http" },
    opts = {},
    config = function(_, opts)
      -- Register the keymaps only when rest is loaded
      require("rest-nvim").setup(opts)

      -- require("which-key").register({
      --   ["<leader>R"] = { name = "+rest" }
      -- })

      local group = vim.api.nvim_create_augroup("RestNVim", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "http",
        group = group,
        callback = function(args)
          vim.api.nvim_buf_set_keymap(args.buf, "n", "<leader>R", "", { desc = "+rest" })
          vim.api.nvim_buf_set_keymap(args.buf, "n", "<leader>Rr", "<Plug>RestNvim<CR>", { desc = "Run request" })
          vim.api.nvim_buf_set_keymap(args.buf, "n", "<leader>Rp", "<Plug>RestNvimPreview<CR>", { desc = "Preview request" })
          vim.api.nvim_buf_set_keymap(args.buf, "n", "<leader>RR", "<Plug>RestNvimLast<CR>", { desc = "Rerun last request" })
        end,
      })
    end,
  }
}

