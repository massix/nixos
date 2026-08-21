local M = {}

M.blink = function()
  local function build_plugin(params)
    vim.notify("Building blink.cmp into " .. params.path, vim.log.levels.INFO)

    local cmd = { "nix", "run", ".#build-plugin" }
    local result = vim.system(cmd, { cwd = params.path }):wait()
    if result.code == 0 then
      vim.notify("Building blink.cmp done", vim.log.levels.INFO)
    else
      vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
    end
  end

  MiniDeps.add({
    source = "saghen/blink.cmp",
    checkout = "v1.8.0",
    depends = {
      "rafamadriz/friendly-snippets",
      "saghen/blink.compat",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-calc",
      "echasnovski/mini.icons",
    },
    hooks = {
      post_checkout = function(params)
        if vim.fn.system("uname") ~= "%Linux%" then
          build_plugin(params)
        end
      end,
      post_install = function(params)
        if vim.fn.system("uname") ~= "%Linux%" then
          build_plugin(params)
        end
      end,
    },
  })

  require("blink.cmp").setup({
    keymap = { preset = "super-tab" },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 1000,
      },
      menu = {
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                if ctx.item.kind_icon ~= nil and ctx.item.kind_icon ~= "" then
                  return ctx.item.kind_icon
                end
                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                return kind_icon
              end,
              highlight = function(ctx)
                if ctx.item.kind_hl ~= nil then
                  return ctx.item.kind_hl
                end
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
            kind = {
              text = function(ctx)
                if ctx.item.kind_icon ~= nil and ctx.item.kind_icon ~= "" then
                  return ""
                end
                return ctx.kind
              end,
              highlight = function(ctx)
                if ctx.item.kind_hl ~= nil then
                  return ctx.item.kind_hl
                end
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
          },
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind" },
          },
        },
      },
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer", "emoji", "calc" },
      per_filetype = {
        opencode = { "lsp" },
      },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
        emoji = {
          name = "emoji",
          module = "blink.compat.source",
          score_offset = -30,
        },
        calc = {
          name = "calc",
          module = "blink.compat.source",
          score_offset = -40,
        },
      },
    },

    signature = { enabled = true },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  })
end

return M
