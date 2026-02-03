local M = {}

M.quicker = function()
  MiniDeps.add({ source = "stevearc/quicker.nvim" })
  require("quicker").setup({
    keys = {
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      },
    },
  })

  require("which-key").add({
    {
      "<leader>Q",
      function()
        require("quicker").toggle()
      end,
      desc = "Toggle Quickfix",
    },
    {
      "<leader>L",
      function()
        require("quicker").toggle({ loclist = true })
      end,
      desc = "Toggle Loclist",
    },
  })
end

return M
