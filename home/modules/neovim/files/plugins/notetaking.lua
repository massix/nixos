local util = require("util.nix")

--- @type LazyPluginSpec[]
return {
  {
    "echaya/neowiki.nvim",
    opts = {
      discover_nested_roots = true,
    },
    -- stylua: ignore
    keys = {
      { "<leader>ww", function() require("neowiki").open_wiki() end, desc = "Open Wiki", },
      { "<leader>wW", function() require("neowiki").open_wiki_floating() end, desc = "Open Wiki in floating window", },
      { "<leader>wT", function() require("neowiki").open_wiki_new_tab() end, desc = "Open Wiki in new tab", },
    },
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
}
