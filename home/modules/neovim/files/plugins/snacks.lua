--- @return LazyPluginSpec[]
local ignored_filetypes = {
  "help",
  "alpha",
  "dashboard",
  "Trouble",
  "lazy",
  "notify",
  "toggleterm",
  "lazyterm",
  "org",
}

local filter_filetypes = function(buf)
  local is_ignored = vim.tbl_contains(ignored_filetypes, vim.bo[buf].filetype)
  return vim.g.snacks_indent ~= false
    and vim.b[buf].snacks_indent ~= false
    and vim.bo[buf].buftype == ""
    and not is_ignored
end

local is_dim_enabled = false

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function(_, opts)
      require("snacks").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })

      Snacks.input.enable()
      Snacks.dim.enable()
      is_dim_enabled = true
    end,

    ---@type snacks.Config
    opts = {
      animate = { enabled = true },
      scope = {
        enabled = true,
        siblings = true,
      },
      indent = {
        enabled = true,
        only_scope = true,
        only_current = true,
        chunk = {
          enabled = true,
          only_current = true,
        },
        filter = filter_filetypes,
      },
      git = { enabled = false },
      input = { enabled = true },
      notifier = {
        enabled = true,
        style = "compact",
      },
      rename = { enabled = true },
      scroll = { enabled = false },
      words = {
        enabled = true,
        notify_jump = true,
      },
      statuscolumn = {
        enabled = true,
        left = { "git", "mark", "sign" },
        right = { "fold", "mark" },
        folds = {
          open = true,
          git_hl = true,
        },
        git = {
          patterns = { "GitSigns", "MiniDiffSign" },
        },
        refresh = 50,
      },

      dashboard = { enabled = false },
      bufdelete = { enabled = true },
      dim = {
        enabled = true,
        filter = filter_filetypes,
      },
    },

    keys = {
      {
        "<leader>uH",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Snacks History",
      },
      {
        "g[",
        function()
          Snacks.words.jump(-1, false)
        end,
        desc = "LSP Prev Word",
      },
      {
        "g]",
        function()
          Snacks.words.jump(1, false)
        end,
        desc = "LSP Next Word",
      },
      {
        "<leader>bd",
        function()
          Snacks.bufdelete.delete()
        end,
        desc = "Delete buffer",
      },
      {
        "<leader>bD",
        function()
          Snacks.bufdelete.other()
        end,
        desc = "Delete other buffers",
      },
      {
        "<leader>d",
        function()
          if is_dim_enabled then
            Snacks.dim.disable()
            is_dim_enabled = false
          else
            Snacks.dim.enable()
            is_dim_enabled = true
          end
        end,
        desc = "Toggle Snacks Dim",
      },
    },
  },
}
