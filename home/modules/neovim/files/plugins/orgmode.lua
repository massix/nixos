local util = require("util.nix")

return {
  {
    "nvim-orgmode/orgmode",
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "akinsho/org-bullets.nvim", config = true, lazy = false },
      {
        "lukas-reineke/headlines.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        lazy = false,
        event = "VeryLazy",
      },
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
        "~/org/**/*.org",
      },
      org_todo_keywords = {
        "TODO(t)",
        "NEXT(n)",
        "PROGRESS(p)",
        "WAITING(w)",
        "|",
        "DONE(d)",
        "CANCELLED(c)",
        "DELEGATED(D)",
      },
      org_default_notes_file = "~/org/refile.org",
      org_indent_mode = "virtual_indent",
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
        m = {
          description = "Meeting minutes",
          template = "* %<%Y-%m-%d> %?\n%u\n** Participants\n** Topics",
          headline = "Meetings",
          target = "~/org/work.org",
        },
      },
      ui = {
        virtual_indent = {
          handler = nil,
        },
      },
      mappings = {
        org = {
          org_toggle_checkbox = "<C-p>",
        },
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
    opts = {},
    ft = "markdown",
    lazy = true,
  },
}
