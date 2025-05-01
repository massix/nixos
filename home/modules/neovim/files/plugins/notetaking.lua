local util = require("util.nix")

--- @type LazyPluginSpec[]
return {
  {
    "obsidian-nvim/obsidian.nvim",
    event = { "VeryLazy" },
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = function()
      local workspaces = {}
      local personal_path = vim.fn.expand("~/OneDrive")
      local work_path = vim.fn.expand("~/OneDrive - QUESTEL")

      if vim.fn.isdirectory(work_path) == 1 then
        table.insert(workspaces, { name = "Work", path = work_path .. "/Vault" })
      end

      if vim.fn.isdirectory(personal_path) then
        table.insert(workspaces, { name = "Personal", path = personal_path .. "/Vault" })
      end

      return {
        workspaces = workspaces,

        daily_notes = {
          folder = "journal",
          date_format = "%Y-%m-%d",
        },

        completion = {
          nvim_cmp = true,
          blink = false,
          min_chars = 2,
        },

        preferred_link_style = "wiki",

        -- TODO: Create some templates
        templates = {
          folder = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          substitutions = {},
        },

        picker = {
          name = "snacks.pick",
        },

        ---@param spec { dir: obsidian.Path, id: string, title: string }
        note_path_func = function(spec)
          local path = spec.dir / (tostring(spec.id) .. "-" .. spec.title)
          return path:with_suffix(".md")
        end,

        follow_url_func = function(url)
          local cmd = vim.loop.os_uname().sysname == "Darwin" and "open" or "xdg-open"
          vim.fn.jobstart({ cmd, url })
        end,

        -- We are using the other Markdown rendering plugin
        ui = {
          enable = false,
        },
      }
    end,
  },

  {
    "michaelb/sniprun",
    ft = { "org", "markdown" },
    version = "v1.3.15",
    opts = {
      binary_path = util.sniprun,
      display = {
        "Classic",
        "VirtualTextOk",
      },
      live_display = {
        "Classic",
        "VirtualTextOk",
      },
      live_mode_toggle = "on",
      interpreter_options = {
        Generic = {
          fish_config = {
            supported_filetypes = { "fish" },
            interpreter = "fish",
            extension = ".fish",
            boilerplate_pre = "#!/usr/bin/env fish\nfunction sniprun_exec1234\n",
            boilerplate_post = "\nend\n\nsniprun_exec1234 $argv",
            compiler = "",
            exe_name = "",
          },
        },
      },
    },
    config = function(_, opts)
      require("sniprun").setup(opts)
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

  -- Show images
  {
    "3rd/image.nvim",
    ft = { "markdown" },
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
