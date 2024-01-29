local util = require("util.nix")

return {
  {
    "massix/orgmode",
    branch = "feat/repeat_to_state",
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "akinsho/org-bullets.nvim", config = true, lazy = false },
      {
        "lyz-code/telescope-orgmode.nvim",
        config = function()
          require("telescope").load_extension("orgmode")
        end,
        lazy = false,
        keys = {
          { "<leader>sO", "<cmd>Telescope orgmode search_headings<cr>", desc = "Search org files" },
        },
      },
    },
    config = function(_, opts)
      require("orgmode").setup_ts_grammar()
      require("orgmode").setup(opts)

      -- Disable column in orgagenda
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = { "orgagenda" },
        callback = function()
          vim.opt_local.foldcolumn = "0"
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = "no"
        end,
      })
    end,
    opts = {
      org_agenda_files = {
        "~/org/*.org",
      },
      org_todo_keywords = {
        "TODO(t)",
        "NEXT(n)",
        "PROGRESS(p)",
        "WAITING(w)",
        "MEET(m)",
        "|",
        "DONE(d)",
        "CANCELLED(c)",
        "DELEGATED(l)",
      },
      org_default_notes_file = "~/org/refile.org",
      org_agenda_text_search_extra_files = { "agenda-archives" },
      org_startup_indented = true,
      org_adapt_indentation = false,
      org_tags_column = 0,
      win_split_mode = "horizontal",
      win_border = "rounded",
      org_hide_leading_stars = true,
      org_hide_emphasis_markers = true,
      org_log_into_drawer = "LOGBOOK",
      org_startup_folded = "inherit",
      org_capture_templates = {
        t = {
          description = "Task",
          template = "* TODO %?\n%u",
          headline = "Tasks",
          target = "~/org/refile.org",
        },
        r = {
          description = "Random note",
          template = "* %?\n%u",
          headline = "Notes",
          target = "~/org/refile.org",
        },
        c = {
          description = "Work calendar entry",
          template = "* MEET %?\nSCHEDULED: %T\n",
          headline = "Calendar",
          target = "~/org/work.org",
        },
      },
      mappings = {
        org = {
          org_toggle_checkbox = "<C-p>",
          org_forward_heading_same_level = "<leader>]",
          org_backward_heading_same_level = "<leader>[",
        },
      },
      notifications = {
        enabled = true,
        cron_enabled = false,
        reminder_time = { 15, 10, 5, 0 },
      },
      org_todo_keyword_faces = {
        WAITING = ":foreground #ffee93",
        MEET = ":foreground #fce1e4 :weight bold :underline on",
        NEXT = ":foreground #d4afb9",
      },
    },
  },

  {
    "michaelb/sniprun",
    lazy = false,
    version = "v1.3.9",
    opts = {
      binary_path = util.sniprun,

      interpreter_options = {
        OrgMode_original = {
          use_on_filetypes = { "org" },
        },
      },
    },
  },

  {
    "HakonHarnes/img-clip.nvim",
    event = "BufEnter",
    opts = {
      default = {
        dir_path = "resources",
      },
    },
    keys = {
      { "<leader>Ip", "<cmd>PasteImage<cr>", desc = "Paste clipboard image" },
    },
  },

  -- mkdnflow for 2nd brain and markdown navigation
  {
    "jakewvincent/mkdnflow.nvim",
    ft = "markdown",
    lazy = true,
    opts = {
      modules = {
        cmp = true,
      },
      wrap = true,
      links = {
        style = "markdown",
        transform_explicit = function(text)
          text = text:gsub(" ", "-")
          text = text:lower()
          return text
        end,
      },
      new_file_template = {
        use_template = true,
        template = "# {{ title }}",
      },
    },
  },

  -- Draw diagrams
  {
    "jbyuki/venn.nvim",
    lazy = false,
    event = "VeryLazy",
    config = function()
      vim.g.venn_enabled = false

      -- Create a function in the global namespace
      -- FIXME: probably not the best solution
      function _G.Toggle_Venn()
        if vim.g.venn_enabled == false then
          vim.notify("Enabling Venn mode", vim.log.levels.INFO)
          vim.g.venn_enabled = true

          vim.opt_local.virtualedit = "all"
          vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", { noremap = true })
          vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
        else
          vim.notify("Disabling Venn mode", vim.log.levels.INFO)
          vim.g.venn_enabled = false

          vim.opt_local.virtualedit = "none"
          vim.api.nvim_buf_del_keymap(0, "n", "J")
          vim.api.nvim_buf_del_keymap(0, "n", "H")
          vim.api.nvim_buf_del_keymap(0, "n", "K")
          vim.api.nvim_buf_del_keymap(0, "n", "L")
          vim.api.nvim_buf_del_keymap(0, "v", "f")
        end
      end

      -- stylua: ignore
      vim.api.nvim_set_keymap( "n", "<leader>Iv", "<cmd>lua Toggle_Venn()<CR>", { noremap = true, desc = "Toggle Venn Mode" })
    end,
  },
}
