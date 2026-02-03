local M = {}

M.ansible = function()
  MiniDeps.add({ source = "mfussenegger/nvim-ansible" })

  vim.filetype.add({
    pattern = {
      [".*playbook.*%.ya?ml"] = "yaml.ansible",
      [".*roles/.*/defaults/.*%.ya?ml"] = "yaml.ansible",
      [".*roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
    },
  })

  vim.api.nvim_create_autocmd("Filetype", {
    pattern = "yaml.ansible",
    group = vim.api.nvim_create_augroup("AnsibleAutoCmds", { clear = true }),
    callback = function(evt)
      -- stylua: ignore
      require("which-key").add({
        buffer = evt.buf,
        mode = { "i", "n", "v" },
        { "<C-c>a", group = "ansible" },
        { "<C-c>ar", function() require("ansible").run() end, desc = "Run playbook", silent = true },
      })
    end,
  })
end

return M
