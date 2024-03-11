---@type LazyPluginSpec[]
return {
  -- Better escape
  {
    "max397574/better-escape.nvim",
    event = "BufEnter",
    opts = {
      mapping = { "jk", "jj", "kj" },
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
    opts = {
      key_labels = {
        ["<space>"] = "SPC",
        ["<cr>"] = "RET",
        ["<tab>"] = "TAB",
      },
    },
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      local wk = require("which-key")
      wk.register({
        -- Lazy Handling
        ["<leader>l"] = { name = "+lazy" },
        ["<leader>ll"] = { "<cmd>Lazy<cr>", "UI" },
        ["<leader>lh"] = { "<cmd>Lazy health<cr>", "HealthCheck" },

        ["<leader>s"] = { name = "+search" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>f"] = { name = "+file" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>u"] = { name = "+misc" },
        ["<leader>x"] = { name = "+list" },
        ["<leader>q"] = { name = "+quit" },
        ["<leader>w"] = { name = "+window" },
        ["<leader><tab>"] = { name = "+tab" },
        ["<leader>n"] = { name = "+nix" },
      })
    end,
  },

  -- Command Palette
  {
    "mrjones2014/legendary.nvim",
    priority = 10000,
    lazy = false,
    enabled = true,
    opts = {
      extensions = {
        lazy_nvim = true,
        which_key = {
          auto_register = true,
          do_binding = false,
          use_groups = true,
        },
      },
    },
    keys = {
      { "<leader><space>", "<cmd>Legendary<cr>", desc = "Legendary" },
    },
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

  -- Better e, w and friends
  {
    "backdround/neowords.nvim",
    event = "VeryLazy",
    config = function()
      local neowords = require("neowords")
      local p = neowords.pattern_presets
      local subword_hops = neowords.get_word_hops(
        p.snake_case,
        p.camel_case,
        p.upper_case,
        p.number,
        p.hex_color,
        "\\v:+",
        "\\v;",
        "\\v\\.+",
        "\\v,+",
        "\\v\\(+",
        "\\v\\)+",
        "\\v\\{+",
        "\\v\\}+",
        "\\v$+",
        "\\v\\=+"
      )

      vim.keymap.set({ "n", "x", "o" }, "w", subword_hops.forward_start)
      vim.keymap.set({ "n", "x", "o" }, "e", subword_hops.forward_end)
      vim.keymap.set({ "n", "x", "o" }, "b", subword_hops.backward_start)
      vim.keymap.set({ "n", "x", "o" }, "ge", subword_hops.backward_end)
    end,
  },
}
