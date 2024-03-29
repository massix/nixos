local util = require("util.nix")

_G.org_toggle_conceal = function()
  if vim.wo.conceallevel > 0 then
    vim.wo.conceallevel = 0
  else
    vim.wo.conceallevel = 3
  end
end

return {
  {
    "nvim-orgmode/orgmode",
    enabled = true,
    ft = { "org", "orgagenda" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      {
        "akinsho/org-bullets.nvim",
        config = true,
        ft = { "org" },
      },
      {
        "lyz-code/telescope-orgmode.nvim",
        config = function()
          require("telescope").load_extension("orgmode")
        end,
        keys = {
          { "<leader>sO", "<cmd>Telescope orgmode search_headings<cr>", desc = "Search org headings" },
        },
      },
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
    },
    config = function(_, opts)
      local orgmode = require("orgmode")
      orgmode.setup_ts_grammar()
      orgmode.setup(opts)

      -- Automatically refresh the agenda view when editing an agenda file
      local orgmode_group = vim.api.nvim_create_augroup("OrgMode", { clear = true })

      -- Set conceal stuff when in orgmode
      vim.api.nvim_create_autocmd({ "Filetype" }, {
        pattern = { "org" },
        group = orgmode_group,
        callback = function()
          vim.wo.concealcursor = "nvic"
          vim.wo.conceallevel = 3

          -- Make sure we only move one character when tabbing
          vim.opt_local.shiftwidth = 1
          vim.opt_local.tabstop = 1

          local map = function(modes, lhs)
            -- stylua: ignore
            if type(modes) == "table" then
              for _, mode in ipairs(modes) do
                vim.api.nvim_buf_set_keymap(0, mode, lhs, "<cmd>lua org_toggle_conceal()<CR>", { desc = "Toggle conceal" })
              end
            else
              vim.api.nvim_buf_set_keymap(0, modes, lhs, "<cmd>lua org_toggle_conceal()<CR>", { desc = "Toggle conceal" })
            end
          end

          map({ "n", "v", "i" }, "<C-c>c")
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
        org_startup_indented = false,
        org_adapt_indentation = true,
        org_tags_column = 80,
        win_split_mode = "bo 20sp",
        win_border = "rounded",
        org_hide_leading_stars = false,
        org_hide_emphasis_markers = true,
        org_log_into_drawer = "LOGBOOK",
        org_startup_folded = "content",
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
            template = "* MEET %?\nSCHEDULED: %T\n",
            headline = "Calendar",
            target = "~/org/index.org",
          },
          C = {
            description = "Work calendar entry",
            template = "* MEET %?\nSCHEDULED: %T\n",
            headline = "Calendar",
            target = "~/org/work.org",
          },
        },
        mappings = {
          org = {
            org_toggle_checkbox = "<C-p>",
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
