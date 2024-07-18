---@type LazyPluginSpec[]
return {
  -- Better escape
  {
    "max397574/better-escape.nvim",
    event = "BufEnter",
    opts = {
      mapping = { "jk", "jj" },
      clear_empty_lines = true,
      keys = function()
        return vim.api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
      end,
    },
    config = function(_, opts)
      require("better_escape").setup(opts)
    end,
  },

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    version = "*",
    opts = {
      preset = "helix",
    },
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      local wk = require("which-key")
      wk.add({
        -- Lazy Handling
        { "<leader>l", group = "lazy" },
        { "<leader>ll", "<cmd>Lazy<cr>", desc = "UI" },
        { "<leader>lh", "<cmd>Lazy health<cr>", desc = "HealthCheck" },
        { "<leader>s", group = "search" },
        { "<leader>g", group = "git" },
        { "<leader>f", group = "file" },
        { "<leader>b", group = "buffer" },
        { "<leader>u", group = "misc" },
        { "<leader>x", group = "list" },
        { "<leader>q", group = "quit" },
        { "<leader>w", group = "window" },
        { "<leader><tab>", group = "tab" },
        { "<leader>n", group = "nix" },
      })
    end,
  },

  -- Flash.nvim
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = false,
        },
      },
    },
  -- stylua: ignore
    keys = {
      { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- Better w, e, b and friends
  {
    "chrisgrieser/nvim-spider",
    event = { "BufEnter" },
    config = function()
      require("spider").setup({
        skipInsignificantPunctuation = true,
        subwordMovement = true,
        customPatterns = {},
      })

      local map_spider = function(key)
        vim.keymap.set({ "x", "n", "o" }, key, [[<cmd>lua require("spider").motion("]] .. key .. [[")<cr>]])
      end

      map_spider("w")
      map_spider("e")
      map_spider("b")
      map_spider("ge")
    end,
  },
}
