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
          vim.wo.spell = false -- Disable spelling for helm files
          vim.loop.new_timer():start(
            500,
            0,
            vim.schedule_wrap(function()
              ---@type lsp.Client[]
              local clients = vim.lsp.get_active_clients({ bufnr = args.buf })
              for _, client in ipairs(clients) do
                if client.name == "yamlls" then
                  if vim.lsp.buf_is_attached(args.buf, client.id) then
                    vim.lsp.buf_detach_client(args.buf, client.id)

                    local lsp_namespace = vim.lsp.diagnostic.get_namespace(client.id)
                    vim.diagnostic.reset(lsp_namespace, args.buf)
                    vim.diagnostic.disable(args.buf, lsp_namespace)
                  end
                end
              end

              -- Reset all diagnostics
              vim.diagnostic.reset(nil, args.buf)
            end)
          )
        end,
      })
    end,
  },
}
