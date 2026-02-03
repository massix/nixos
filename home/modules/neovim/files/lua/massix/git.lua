local M = {}

M.git = function()
  MiniDeps.add({
    source = "neogitorg/neogit",
    depends = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
  })

  MiniDeps.add({
    source = "linrongbin16/gitlinker.nvim",
  })

  require("neogit").setup({
    disable_hint = false,
    disable_signs = false,
    disable_line_numbers = false,
    console_timeout = 15000,
    disable_context_highlighting = true,
    status = {
      recent_commit_count = 50,
    },
    graph_style = "kitty",
    signs = {
      hunk = { "", "" },
      item = { " ", " " },
      section = { " ", " " },
    },
    integrations = {
      telescope = false,
      fzf_lua = false,
      diffview = true,
      snacks = true,
    },
    git_services = {
      ["git.questel.com"] = {
        pull_request = "https://git.questel.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
        commit = "https://git.questel.com/${owner}/${repository}/-/commit/${oid}",
        tree = "https://git.questel.com/${owner}/${repository}/-/tree/${branch_name}?ref_type=heads",
      },
    },
  })

  require("gitlinker").setup({
    router = {
      browse = {
        ["git.questel.com"] = "https://git.questel.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blob/"
          .. "{_A.REV}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}"
          .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
      },
      blame = {
        ["git.questel.com"] = "https://git.questel.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blame/"
          .. "{_A.REV}/"
          .. "{_A.FILE}?plain=1"
          .. "#L{_A.LSTART}"
          .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
      },
      default_branch = {
        ["git.questel.com"] = "https://git.questel.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blob/"
          .. "{_A.DEFAULT_BRANCH}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}"
          .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
      },
      current_branch = {
        ["git.questel.com"] = "https://git.questel.com/"
          .. "{_A.ORG}/"
          .. "{_A.REPO}/blob/"
          .. "{_A.CURRENT_BRANCH}/"
          .. "{_A.FILE}"
          .. "#L{_A.LSTART}"
          .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
      },
    },
  })

  require("mini.diff").setup()

  require("which-key").add({
    {
      "<leader>gg",
      function()
        require("neogit").open()
      end,
      desc = "Neogit",
    },
    {
      "<leader>go",
      function()
        MiniDiff.toggle_overlay(0)
      end,
      desc = "Toggle overlay",
    },
    { "<leader>gl", group = "links", mode = { "n", "v" } },
    { "<leader>glB", "<cmd>GitLink blame<cr>", desc = "Blame", mode = { "n", "v" } },
    { "<leader>glc", "<cmd>GitLink browse<cr>", desc = "Browse", mode = { "n", "v" } },
    { "<leader>glb", "<cmd>GitLink current_branch<cr>", desc = "Current branch", mode = { "n", "v" } },
    { "<leader>gld", "<cmd>GitLink default_branch<cr>", desc = "Default branch", mode = { "n", "v" } },
  })
end

return M
