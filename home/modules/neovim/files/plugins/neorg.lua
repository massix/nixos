--- @type LazyPluginSpec[]
return {
  {
    "nvim-neorg/neorg",
    ft = "norg",
    cmd = "Neorg",
    opts = {
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp",
          },
        },
        ["core.integrations.nvim-cmp"] = {},
        ["core.dirman"] = {
          config = {
            default_workspace = "private",
            workspaces = {
              private = "~/neorg",
            },
            index_file = "index.norg",
          },
        },
        ["core.ui.calendar"] = {},
        ["core.summary"] = {},
        ["core.esupports.metagen"] = {
          config = {
            author = "massix",
            type = "empty",
          },
        },
      },
    },
  },
}
