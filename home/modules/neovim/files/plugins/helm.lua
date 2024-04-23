---@type LazyPluginSpec[]
return {
  {
    "towolf/vim-helm",
    event = "VeryLazy",
    opts = {},
    config = function()
      -- If there are both yamlls and helm_ls, then detach yamlls
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "helm",
        group = vim.api.nvim_create_augroup("Helm", { clear = true }),
        callback = function(args)
          local clients = vim.lsp.get_active_clients({ bufnr = args.buf })
          for _, client in ipairs(clients) do
            if client.name == "yamlls" and vim.lsp.buf_is_attached(args.buf, client.id) then
              vim.lsp.buf_detach_client(args.buf, client.id)
              break
            end
          end
        end,
      })
    end,
  },
}
