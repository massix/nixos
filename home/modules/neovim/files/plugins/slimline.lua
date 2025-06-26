return {
  -- statusline
  {
    "sschleemilch/slimline.nvim",
    dependencies = {
      "echasnovski/mini.icons",
    },
    lazy = false,
    opts = {
      style = "fg",
      bold = true,
      configs = {
        mode = {
          verbose = false,
        },
        diagnostics = {
          workspace = true,
        },
        progress = {
          column = true,
        },
        path = {
          hl = {
            primary = "Define",
            secondary = "Comment",
          },
        },
        git = {
          style = "bg",
          hl = {
            primary = "Function",
            secondary = "Identifier",
          },
        },
        filetype_lsp = {
          style = "bg",
          hl = {
            primary = "String",
            secondary = "Identifier",
          },
        },
      },

      components = {
        left = {
          "mode",
          "git",
          "diagnostics",
        },
        center = {
          "path",
        },
        right = {
          function()
            local slimline = require("slimline")
            local codeium_status = require("codeium.virtual_text").status_string()
            local icon = require("mini.icons").get("os", "freebsd")
            local primary_highlight = "String"

            if codeium_status:match("*") then
              codeium_status = "..."
              primary_highlight = "Comment"
            elseif codeium_status:match("0") then
              codeium_status = "N/A"
              primary_highlight = "CodeiumSuggestion"
            end

            return slimline.highlights.hl_component(
              { primary = codeium_status, secondary = icon },
              { primary = { text = primary_highlight }, secondary = { text = "Define" } },
              slimline.get_sep("path"),
              "right",
              true
            )
          end,
          "recording",
          "filetype_lsp",
          "progress",
        },
      },
    },
    config = function(_, opts)
      vim.opt.laststatus = 3
      require("slimline").setup(opts)
    end,
  },
}
