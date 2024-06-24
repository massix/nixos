--- @type LazyPluginSpec[]
return {
  {
    "nvim-pack/nvim-spectre",
    event = "VeryLazy",
    opts = {
      live_update = true,
    },
    cmd = { "Spectre" },
    keys = {
      {
        "<leader>So",
        function()
          require("spectre").toggle()
        end,
        desc = "Open Spectre",
      },
      {
        "<leader>Sw",
        function()
          require("spectre").open_visual({ select_word = true })
        end,
        desc = "Search current word",
      },
      {
        "<leader>Sw",
        function()
          require("spectre").open_visual({ select_word = true })
        end,
        mode = "v",
        desc = "Search current word",
      },
      {
        "<leader>Sp",
        function()
          require("spectre").open_file_search({ select_word = true })
        end,
        desc = "Search on current file",
      },
    },
  },
}
