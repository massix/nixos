--- @type LazyPluginSpec[]
return {
  {
    "rest-nvim/rest.nvim",
    ft = { "http" },
    opts = {},
    config = function(_, opts)
      -- Register the keymaps only when rest is loaded
      require("rest-nvim").setup(opts)

      local group = vim.api.nvim_create_augroup("RestNvim", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "http",
        group = group,
        callback = function(args)
          require("which-key").register({
            r = {
              name = "+rest",
              ["<CR>"] = { "<Plug>RestNvim<CR>", "Run request" },
              p = { "<Plug>RestNvimPreview<CR>", "Preview request" },
              R = { "<Plug>RestNvimLast<CR>", "Relaunch last request" },
            },
          }, { buffer = args.buf, noremap = false, prefix = "<C-c>" })
        end,
      })
    end,
  },
}
