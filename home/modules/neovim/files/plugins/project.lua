return {
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    event = "VeryLazy",
    opts = {
      manual_mode = false,
      detection_methods = { "pattern", "lsp" },
      exclude_dirs = {
        "/home/massi",
        "${HOME}",
        "~",
      },
      patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "Justfile",
        "justfile",
        "package.json",
        "index.org",
        "flake.nix",
        "shell.nix",
        "cargo.toml",
        "*.cabal",
        "stack.yaml",
        "spago.yaml",
        "spago.dhall",
        "go.mod",
      },
      datapath = vim.fn.stdpath("data"),
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
  },
}
