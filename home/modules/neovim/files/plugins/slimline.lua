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
      disabled_filetypes = {
        "alpha",
        "snacks_picker_list",
        "snacks_picker_input",
        "OverseerList",
      },
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
          -- Writes the name of the current devShell, if active
          function()
            local slimline = require("slimline")
            local shell_name = vim.env.IN_NIX_SHELL
            if shell_name ~= nil and shell_name ~= "" then
              return slimline.highlights.hl_component(
                { primary = shell_name, secondary = require("mini.icons").get("os", "nixos") },
                { primary = { text = "NvimOptionName" }, secondary = { text = "Function" } },
                slimline.get_sep("path"),
                "left",
                true,
                "fg"
              )
            else
              return ""
            end
          end,
        },
        center = {
          "path",
        },
        right = {
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
