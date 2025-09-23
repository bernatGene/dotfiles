return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    enabled = true,
    render_modes = false,
    file_types = { "markdown" },

    -- disable almost everything
    heading = { enabled = false },
    paragraph = { enabled = false },
    code = { enabled = false, style = "none" },
    dash = { enabled = false },
    bullet = { enabled = false },
    checkbox = { enabled = false },
    quote = { enabled = false },
    pipe_table = { enabled = false },
    sign = { enabled = false },
    indent = { enabled = true },
    html = { enabled = false },
    latex = { enabled = false },
    yaml = { enabled = false },
    inline_highlight = { enabled = false },

    link = {
      enabled = true,
      render_modes = true,
      custom = {
        web = {
          pattern = "^https",
          icon = "󰖟 ",
          body = function(destination, label)
            return "[" .. (label or destination) .. "]"
          end,
        },
      },
    },

    -- Conceal only the "(url)" part of inline links [text](url)
    document = {
      enabled = true,
      render_modes = false,
      conceal = {
        char_patterns = {
          "%[.-%]%((.-)%)", -- matches [text](url) and conceals the parenthesis part
        },
        line_patterns = {},
      },
    },

    -- make conceal visible when rendered
    win_options = {
      conceallevel = { default = vim.o.conceallevel, rendered = 3 },
      concealcursor = { default = vim.o.concealcursor, rendered = "" },
    },

    -- keep anti-conceal conservative
    anti_conceal = { enabled = true, above = 0, below = 0 },

    log_level = "error",
  },
}
