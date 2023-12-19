return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    config = function(_, opts)
      require("orgmode").setup_ts_grammar()
      require("orgmode").setup(opts)
    end,
    opts = {
      org_agenda_files = { "~/org/**/*" },
      org_default_notes_file = "~/org/refile.org",
      org_indent_mode = "virtual_indent",
      ui = {
        virtual_indent = {
          handler = nil,
        },
      },
    },
  },
}
