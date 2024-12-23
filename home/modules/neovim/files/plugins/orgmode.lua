local util = require("util.nix")

--- @type LazyPluginSpec[]
return {
  {
    "nvim-orgmode/orgmode",
    enabled = true,
    ft = { "org", "orgagenda" },
    init = function()
      require("which-key").add({
        { "<leader>o", group = "orgmode" },
      })
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      {
        "danilshvalov/org-modern.nvim",
        opts = {},
        config = function() end,
      },
      {
        "massix/org-checkbox.nvim",
        opts = {},
        main = "orgcheckbox",
      },
      {
        "nvim-orgmode/org-bullets.nvim",
        opts = {},
      },
      {
        "chipsenkbeil/org-roam.nvim",
        opts = {
          directory = "~/org/roam",
          bindings = {
            prefix = "<leader>on",
            add_alias = "<leader>onAa",
            remove_alias = "<leader>onAr",
          },
          database = {
            persist = true,
            update_on_save = true,
          },
        },
        init = function()
          require("which-key").add({
            { "<leader>on", group = "roam" },
            { "<leader>onA", group = "alias" },
            { "<leader>ond", group = "daily" },
            { "<leader>ono", group = "origin" },
          })
        end,
        keys = {
          {
            "<leader>onf",
            function()
              require("org-roam").api.find_node()
            end,
            desc = "Find node",
          },
          {
            "<leader>ondn",
            function()
              require("org-roam").ext.dailies.goto_today()
            end,
            desc = "Today's note",
          },
          {
            "<leader>ondd",
            function()
              require("org-roam").ext.dailies.goto_date()
            end,
            desc = "Go to specific date",
          },
          {
            "<leader>ondy",
            function()
              require("org-roam").ext.dailies.goto_yesterday()
            end,
            desc = "Yesterday's note",
          },
          {
            "<leader>ondt",
            function()
              require("org-roam").ext.dailies.goto_tomorrow()
            end,
            desc = "Tomorrow's note",
          },
        },
        config = function(_, opts)
          require("org-roam").setup(opts)

          -- Add some bindings while in insert mode (only in org files)
          local group = vim.api.nvim_create_augroup("OrgRoamCustom", { clear = true })
          vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = "org",
            group = group,
            callback = function(args)
              local roam = require("org-roam")
              local wk = require("which-key")
              local prefix = "<C-c>n"

              wk.add({
                {
                  mode = "i",
                  buffer = args.buf,
                  { prefix, group = "roam" },
                  { prefix .. ".", roam.api.complete_node, desc = "Complete node" },
                  { prefix .. "i", roam.api.insert_node, desc = "Insert node" },
                  {
                    prefix .. "m",
                    function()
                      roam.api.insert_node({ immediate = true })
                    end,
                    desc = "Insert node (immediate)",
                  },
                },
              })
            end,
          })
        end,
      },
      { "andreadev-it/orgmode-multi-key", opts = {} },
    },
    config = function(_, opts)
      local orgmode = require("orgmode")
      orgmode.setup(opts)

      -- Automatically refresh the agenda view when editing an agenda file
      local orgmode_group = vim.api.nvim_create_augroup("OrgMode", { clear = true })

      -- Set conceal stuff when in orgmode
      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "org",
        group = orgmode_group,
        callback = function(args)
          vim.wo.concealcursor = "nvic"
          vim.wo.conceallevel = 3

          -- Enable modeline for org buffers
          vim.opt_local.modeline = true
          vim.opt_local.modelines = 30

          -- Allow the cursor to go one character past the end of the line
          vim.opt_local.virtualedit = "onemore"

          -- Add a marker at the 80th column
          vim.opt_local.colorcolumn = "80"

          require("which-key").add({
            {
              buffer = args.buf,
              {
                "<C-c>c",
                function()
                  if vim.wo.conceallevel > 0 then
                    vim.wo.conceallevel = 0
                    vim.notify("Conceal off", vim.log.levels.INFO)
                  else
                    vim.wo.conceallevel = 3
                    vim.notify("Conceal on", vim.log.levels.INFO)
                  end
                end,
                desc = "Toggle conceal",
                mode = { "n", "i", "v" },
              },
              {
                "<C-c><CR>",
                function()
                  require("orgmode").action("org_mappings.meta_return")
                end,
                desc = "Org Meta Return",
                mode = { "i", "n" },
              },
            },
          })
        end,
      })
    end,
    opts = function()
      local Menu = require("org-modern.menu")
      return {
        ui = {
          menu = {
            handler = function(data)
              local org = require("orgmode").instance()

              local custom_items = {
                {
                  label = "Agenda for current week",
                  key = "a",
                  action = function()
                    org.agenda:agenda({
                      span = "week",
                    })
                  end,
                },
                {
                  label = "Agenda for Today",
                  key = "d",
                  action = function()
                    org.agenda:agenda({
                      span = "day",
                    })
                  end,
                },
                {
                  label = "Personal To-Do",
                  key = "p",
                  action = function()
                    org.agenda:tags({
                      todo_only = true,
                      search = "+personal-project-recurring-habit/-MEET-WAITING",
                    })
                  end,
                },
                {
                  label = "Personal Projects",
                  key = "P",
                  action = function()
                    org.agenda:tags({
                      todo_only = true,
                      search = "+personal+project-recurring-habit/-MEET-WAITING",
                    })
                  end,
                },
                {
                  label = "Work To-Do",
                  key = "w",
                  action = function()
                    org.agenda:tags({
                      todo_only = true,
                      search = "+work-project-recurring-habit/-MEET-WAITING",
                    })
                  end,
                },
                {
                  label = "Work Projects",
                  key = "W",
                  action = function()
                    org.agenda:tags({
                      todo_only = true,
                      search = "+work+project-recurring-habit/-MEET-WAITING",
                    })
                  end,
                },
                {
                  label = "Search for To-Dos",
                  key = "s",
                  action = function()
                    org.agenda:tags({
                      todo_only = true,
                    })
                  end,
                },
                {
                  label = "Search all headings",
                  key = "S",
                  action = function()
                    org.agenda:tags()
                  end,
                },
              }

              Menu:new({ window = { margin = { 1, 1, 1, 1 } } }):open({
                prompt = data.prompt,
                title = data.title,
                items = data.title == "Select a capture template" and data.items or custom_items,
              })
            end,
          },
        },
        org_agenda_files = {
          "~/org/*.org",
          "~/org/roam/*.org",
          "~/org/roam/daily/*.org",
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
        org_todo_repeat_to_state = "NEXT",
        org_default_notes_file = "~/org/refile.org",
        org_agenda_text_search_extra_files = { "agenda-archives" },
        org_startup_indented = true,
        org_adapt_indentation = false,
        org_indent_mode_turns_off_org_adapt_indentation = true,
        org_tags_column = -80,
        win_split_mode = "bo 20sp",
        win_border = "rounded",
        org_hide_leading_stars = false,
        org_hide_emphasis_markers = false,
        org_log_into_drawer = "LOGBOOK",
        org_startup_folded = "content",
        org_id_link_to_org_use_id = true,
        org_id_method = "uuid",
        org_id_uuid_program = "uuidgen",
        org_capture_templates = {
          r = {
            description = "Refilable Task",
            template = "* TODO %?\n%u",
            headline = "Tasks",
            target = "~/org/refile.org",
          },
          t = {
            description = "Personal Task",
            template = "* TODO %?\n%u",
            headline = "Tasks",
            target = "~/org/index.org",
          },
          T = {
            description = "Work Task",
            template = "* TODO %?\n%u",
            headline = "Tasks",
            target = "~/org/work.org",
          },
          c = {
            description = "Personal calendar entry",
            template = "* MEET %?\nSCHEDULED: %^{Meeting Time}T\n",
            headline = "Calendar",
            target = "~/org/index.org",
          },
          C = {
            description = "Work calendar entry",
            template = "* MEET %?\nSCHEDULED: %^{Meeting Time}T\n",
            headline = "Calendar",
            target = "~/org/work.org",
          },
        },
        mappings = {
          org = {
            org_toggle_checkbox = "<C-p>",
          },
          capture = {
            org_capture_finalize = "<C-c>O<CR>",
            org_capture_refile = "<C-c>Or",
            org_capture_kill = "<C-c>Ok",
          },
          note = {
            org_note_finalize = "<C-c>O<CR>",
            org_note_kill = "<C-c>Ok",
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
      }
    end,
    -- stylua: ignore
    keys = {
      { "<leader>oR", function() require("orgmode").instance().clock:init() end, desc = "org reload clock" },
      { "<leader>oa", function() require("orgmode").action("agenda.prompt") end, desc = "org agenda" },
      { "<leader>oc", function() require("orgmode").action("capture.prompt") end, desc = "org capture" },
    },
  },

  {
    "michaelb/sniprun",
    ft = { "org" },
    version = "v1.3.15",
    opts = {
      binary_path = util.sniprun,

      interpreter_options = {
        OrgMode_original = {
          use_on_filetypes = { "org" },
        },
      },
    },
    config = function(_, opts)
      require("sniprun").setup(opts)

      -- Configure keys for orgmode files
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "org" },
        callback = function(args)
          local wk = require("which-key")
          wk.add({
            {
              buffer = args.buf,
              { "<C-c>s", group = "sniprun" },
              { "<C-c>s<CR>", "<cmd>SnipRun<cr>", desc = "Run" },
              { "<C-c>sr", "<cmd>SnipReset<cr>", desc = "Reset" },
              { "<C-c>sc", "<cmd>SnipClose<cr>", desc = "Close" },
              { "<C-c>si", "<cmd>SnipInfo<cr>", desc = "Info" },
              { "<C-c>sC", "<cmd>SnipReplMemoryClean<cr>", desc = "Cancel" },
            },
          })
        end,
      })
    end,
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

  -- Show images
  {
    "3rd/image.nvim",
    -- ft = { "markdown", "org", "html", "css" },
    event = "VeryLazy",
    cond = function()
      return not vim.g.neovide
    end,
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
        },
        html = {
          enabled = true,
        },
        css = {
          enabled = true,
        },
      },
    },
  },
}
