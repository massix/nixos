return {
  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local Util = require("util.defaults")
      local icons = Util.icons
      return {
        options = {
          theme = "catppuccin",
          globalstatus = true,
          icons_enabled = true,
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {
            {
              function()
                if vim.g.venn_enabled then
                  return "VNN"
                ---@diagnostic disable-next-line: undefined-field
                elseif vim.b.table_mode_active == 1 then
                  return "TBL"
                end
              end,
              cond = function()
                return vim.g.venn_enabled or (vim.b.table_mode_active == 1)
              end,
            },
            {
              "mode",
              fmt = function(input_string)
                local conversion = {
                  ["normal"] = "NRM",
                  ["insert"] = "INS",
                  ["visual"] = "VIS",
                  ["v-line"] = "VLN",
                  ["v-block"] = "VBL",
                  ["terminal"] = "TRM",
                  ["command"] = "CMD",
                  ["replace"] = "RPL",
                }

                return conversion[input_string:lower()]
              end,
            },
            {
              function()
                local status = require("better_escape").waiting
                if status then
                  return "…"
                else
                  return ""
                end
              end,
              cond = function()
                return package.loaded["better_escape"] and require("better_escape").waiting ~= nil
              end,
            },
          },
          lualine_b = {
            -- Get current LSPs
            {
              function()
                local msg = "No LSP"
                local bufnr = vim.api.nvim_get_current_buf()
                local bufft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
                local clients = {}

                for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                  table.insert(clients, client)
                end

                if next(clients) == nil then
                  return msg
                end

                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if client.name == "jdtls" or (filetypes and vim.fn.index(filetypes, bufft) ~= -1) then
                    local ret = client.name
                    if #clients > 1 then
                      ret = ret .. "+"
                    end
                    return ret
                  end
                end
                return msg
              end,
              icon = " ",
            },

            { "branch" },
          },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 1 } },
            {
              "filename",
              path = 1,
              symbols = { modified = "  ", readonly = "  ", unnamed = "  " },
              --- @param str string
              fmt = function(str)
                --- @type string
                local fn = vim.fn.expand("%:~:.")

                if vim.startswith(fn, "jdt://") then
                  return fn:gsub("?.*$", "")
                end
                return str
              end,
            },
          },
          lualine_x = {
            {
              "overseer",
              colored = true,
              unique = true,
            },

            -- stylua: ignore
            {
              ---@diagnostic disable-next-line: undefined-field
              function() return require("noice").api.status.command.get() end,
              ---@diagnostic disable-next-line: undefined-field
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = Util.fg("Statement"),
            },
            -- stylua: ignore
            {
              ---@diagnostic disable-next-line: undefined-field
              function() return require("noice").api.status.mode.get() end,
              ---@diagnostic disable-next-line: undefined-field
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = Util.fg("Constant"),
            },
            -- stylua: ignore
            {
             function() return "  " .. require("dap").status() end,
             cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
             color = Util.fg("Debug"),
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_y = {
            -- stylua: ignore
            { function() return require("codeium.virtual_text").status_string() end },
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          -- stylua: ignore
          lualine_z = {
           {
              function() return require("nomodoro").status() end,
              cond = function()
                return package.loaded["nomodoro"] and require("nomodoro").status() ~= nil
              end,
            },
            { function() return "  " .. os.date("%R") end, }
          },
        },
        inactive_sections = {
          lualine_c = {
            { "filetype", icon_only = true, separator = "" },
            { "filename", path = 0 },
          },
          lualine_x = {
            { "progress" },
            { "location" },
          },
        },
        tabline = {
          lualine_a = {
            {
              "buffers",
              mode = 4,
              use_mode_colors = false,
              filetype_names = {
                ["oil"] = "Oil",
                ["OverseerList"] = "Overseer List",
                ["lazy"] = "Lazy",
                ["grug-far"] = "Grug Far",
              },
            },
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {
            -- Print current filetype
            {
              function()
                return vim.bo.filetype
              end,
              cond = function()
                return vim.bo.buftype == ""
              end,
            },
            -- Get current nix shell
            {
              function()
                return vim.env.IN_NIX_SHELL
              end,
              cond = function()
                return vim.env.IN_NIX_SHELL ~= nil
              end,
              icon = " ",
            },
          },
          lualine_y = {
            { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = Util.fg("Special") },
          },
          lualine_z = {
            { "tabs", use_mode_colors = true },
          },
        },
        extensions = { "lazy", "trouble" },
      }
    end,
  },
}
