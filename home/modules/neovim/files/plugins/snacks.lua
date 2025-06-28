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
      Snacks.dim.disable()

      -- Override the default vim.ui.input
      vim.ui.input = Snacks.input.input
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
      win = { enabled = true },
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
      picker = {
        matcher = {
          frecency = true,
        },
        actions = {
          list_dir_or_confirm = function(picker, item, action)
            local explorer_actions = require("snacks.explorer.actions")
            local picker_actions = require("snacks.picker.actions")
            if item.dir then
              return explorer_actions.actions.confirm(picker, item, action)
            else
              picker_actions.pick_win(picker, item, action)
              explorer_actions.actions.confirm(picker, item, action)
            end
          end,
        },
        ui_select = true,
        sources = {
          explorer = {
            layout = {
              layout = { position = "right" },
            },
            win = {
              list = {
                keys = {
                  ["<ESC>"] = { "close", mode = { "n", "i" } },
                  ["<CR>"] = { "list_dir_or_confirm", mode = { "n", "i" } },
                  ["<S-CR>"] = { "confirm", mode = { "n", "i" } },
                  ["o"] = { "list_dir_or_confirm" },
                  ["l"] = { "list_dir_or_confirm" },
                  ["L"] = { "list_dir_or_confirm" },
                },
              },
            },
          },
        },
      },
      explorer = {
        enabled = true,
        replace_netrw = true,
      },
      statuscolumn = {
        enabled = true,
        left = { "fold", "mark" },
        right = { "sign", "git" },
        folds = {
          open = false,
          git_hl = true,
        },
        git = {
          patterns = { "GitSigns", "MiniDiffSign" },
        },
        refresh = 50,
      },

      dashboard = { enabled = false },
      bufdelete = { enabled = true },
      toggle = {
        enabled = true,
      },
      dim = {
        enabled = false,
        filter = filter_filetypes,
      },
    },

    init = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>p", group = "picker" },
        { "<leader>pl", group = "lsp" },
        { "<leader>pg", group = "git" },
      })
    end,

    -- stylua: ignore
    keys = {
      -- Picker keys (quick access)
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Live Grep" },
      { "<leader>.", function() Snacks.picker.files() end, desc = "Pick files" },
      { "<leader>;", function() Snacks.picker.git_files() end, desc = "Pick files [Git]" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Pick buffer" },
      { "<leader>L", function() Snacks.picker.lsp_symbols() end, desc = "Pick LSP Symbols" },
      { "<leader>m", function() Snacks.picker.marks() end, desc = "Pick Marks" },
      { "<leader>r", function() Snacks.picker.resume() end, desc = "Resume picker" },

      -- Picker submenu
      { "<leader>pb", function() Snacks.picker.buffers() end, desc = "Pick buffer" },
      { "<leader>p/", function() Snacks.picker.grep() end, desc = "Live Grep" },
      { "<leader>pf", function() Snacks.picker.files() end, desc = "Pick files" },
      { "<leader>pG", function() Snacks.picker.git_files() end, desc = "Pick files [Git]" },
      { "<leader>pm", function() Snacks.picker.marks() end, desc = "Pick marks" },
      { "<leader>pM", function() Snacks.picker.man() end, desc = "Pick man pages" },
      { "<leader>ph", function() Snacks.picker.help() end, desc = "Pick Help" },
      { "<leader>pc", function() Snacks.picker.commands() end, desc = "Pick commands" },
      { "<leader>pH", function() Snacks.picker.command_history() end, desc = "Pick commands" },
      { "<leader>pH", function() Snacks.picker.registers() end, desc = "Pick registers" },
      { "<leader>pd", function() Snacks.picker.diagnostics() end, desc = "Pick diagnostics" },
      { "<leader>pj", function() Snacks.picker.jumps() end, desc = "Pick jumps" },

      -- Picker git submenu
      { "<leader>pgb", function() Snacks.picker.git_branches() end, desc = "Pick git branches" },
      { "<leader>pgd", function() Snacks.picker.git_diff() end, desc = "Pick git diff" },
      { "<leader>pgf", function() Snacks.picker.git_files() end, desc = "Pick git files" },
      { "<leader>pgl", function() Snacks.picker.git_log() end, desc = "Pick git log" },

      -- Picker LSP submenu
      { "<leader>pls", function() Snacks.picker.lsp_symbols() end, desc = "Pick LSP Symbols" },
      { "<leader>plD", function() Snacks.picker.lsp_declarations() end, desc = "Pick LSP Declarations" },
      { "<leader>pld", function() Snacks.picker.lsp_definitions() end, desc = "Pick LSP Definitions" },
      { "<leader>plt", function() Snacks.picker.lsp_type_definitions() end, desc = "Pick LSP Type Definitions" },
      { "<leader>plr", function() Snacks.picker.lsp_references() end, desc = "Pick LSP References" },
      { "<leader>pli", function() Snacks.picker.lsp_implementations() end, desc = "Pick LSP Implementations" },

      -- Explorer keys
      { "<leader>e", function() Snacks.explorer.open() end, desc = "Open explorer" },
      { "<leader>fm", function() Snacks.explorer.open() end, desc = "Open explorer" },

      -- Other keys
      { "<leader>uH", function() Snacks.notifier.show_history() end, desc = "Snacks History" },
      { "g[", function() Snacks.words.jump(-1, false) end, desc = "LSP Prev Word" },
      { "g]", function() Snacks.words.jump(1, false) end, desc = "LSP Next Word" },
      { "<leader>d",
        function()
          if Snacks.dim.enabled then
            Snacks.dim.disable()
          else
            Snacks.dim.enable()
          end
        end,
        desc = "Toggle Snacks Dim",
      },
    },
  },
}
