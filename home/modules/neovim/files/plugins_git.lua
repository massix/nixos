local api = vim.api

local spec = {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "sindrets/diffview.nvim",
      "ibhagwan/fzf-lua"
    },
    config = true,

    -- Reload Nvimtree automatically
    init = function()
      local group = api.nvim_create_augroup('NeogitEvents', { clear = true })

      local create_autocmd = function(pattern, callback)
        api.nvim_create_autocmd('User', {
          pattern = pattern,
          group = group,
          callback = callback
        })
      end

      create_autocmd('NeogitPushComplete', function()
        require('nvim-tree.api').git.reload()
        require('neogit').close()
      end)

      create_autocmd('NeogitPullComplete', function()
        require('nvim-tree.api').git.reload()
      end)

      create_autocmd('NeogitFetchComplete', function()
        require('nvim-tree.api').git.reload()
      end)

      create_autocmd('NeogitStatusRefreshed', function()
        require('nvim-tree.api').git.reload()
      end)

    end,
    keys = {
      {
        "<leader>gg",
        function() require('neogit').open() end,
        desc = "Open Neogit"
      },
      {
        "<leader>gC",
        function() require('neogit').open({ "commit" }) end,
        desc = "Open Neogit commit"
      },
    }
  },

  -- Git blame info
  {
    'f-person/git-blame.nvim',
    version = false,
    config = true,
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>gB", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git blame" }
    },
  },

  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    version = false,
    config = true,
    event = { "BufReadPre", "BufNewFile" }
  }

}

return spec

