local spec = {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "sindrets/diffview.nvim", lazy = false },
      "ibhagwan/fzf-lua",
    },
    opts = {
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
        fzf_lua = true,
        diffview = true,
      },
      git_services = {
        ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
        ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
        ["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
        ["azure.com"] = "https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target_branch}",
        ["git.questel.com"] = "https://git.questel.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
      },
    },
    --stylua: ignore
    keys = {
      { "<leader>gg", function() require("neogit").open() end, desc = "Neogit", },
    },
    cmd = { "Neogit" },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>g", mode = "v", group = "git" },
      })
    end,
    keys = {
      {
        "<leader>gB",
        "<cmd>Gitsigns toggle_current_line_blame<cr>",
        desc = "Toggle Git blame",
      },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
      { "<leader>gP", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview hunk (inline)" },
      { "<leader>gS", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk", mode = { "n", "v" } },
      { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo stage Hunk" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset hunk", mode = { "n", "v" } },
      { "<leader>gb", "<cmd>Gitsigns blame<cr>", desc = "Blame file" },
    },
  },

  -- Easily copy shareable links for different platforms
  {
    "linrongbin16/gitlinker.nvim",
    cmd = { "GitLink" },
    opts = {
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
    },
  },
}

return spec
