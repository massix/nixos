---@type LazyPluginSpec
return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },
  event = "VeryLazy",
  opts = function()
    local bufferline = require("bufferline")
    local opts = {
      mode = "buffers",
      style_preset = bufferline.style_preset.no_italic,
      numbers = "none",
      diagnostics = "nvim_lsp",

      offsets = {
        {
          filetype = "snacks_layout_box",
          text = "Snacks Picker",
          text_align = "center",
          separator = true,
        },
        {
          filetype = "OverseerList",
          text = "Overseer",
          text_align = "center",
          separator = true,
        },
      },

      color_icons = true,
      show_tab_indicators = true,
      show_duplicate_prefix = true,
      show_close_icon = false,
      separator_style = "slant",
      always_show_bufferline = true,

      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },

      ---@param element { filetype: string, extension: string, path: string }
      get_element_icon = function(element)
        local get = require("mini.icons").get
        local icon, hl, default = get("file", element.path)

        if default and element.filetype ~= "" then
          icon, hl, default = get("filetype", element.filetype)
        end

        if default then
          icon, hl = get("extension", element.extension)
        end

        return icon, hl
      end,
    }

    return { options = opts }
  end,
  keys = {
    { "<leader>bb", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    -- stylua: ignore
    { "<leader>bd", function() Snacks.bufdelete.delete() end, desc = "Close current buffer" },
    { "<leader>bD", "<cmd>BufferLineCloseOthers<cr>", desc = "Close all other buffers" },
    { "<leader>bB", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle pin" },
  },
}
