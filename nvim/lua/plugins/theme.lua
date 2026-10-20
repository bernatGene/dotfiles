local function system_theme()
  local h = io.popen([[osascript -e 'tell app "System Events" to return dark mode of appearance preferences']])
  if h == nil then
    return "dark"
  end
  local res = h:read("*a")
  h:close()
  return res:match("true") and "dark" or "light"
end

-- markdown colors from opencode's default theme (packages/tui/src/theme/assets/opencode.json)
local opencode_md = {
  dark = {
    heading = "#9d7cd8",
    link = "#fab283",
    link_text = "#56b6c2",
    code = "#7fd88f",
    quote = "#e5c07b",
    emph = "#e5c07b",
    strong = "#f5a742",
    muted = "#808080",
    list = "#fab283",
    text = "#eeeeee",
  },
  light = {
    heading = "#d68c27",
    link = "#3b7dd8",
    link_text = "#318795",
    code = "#3d9a57",
    quote = "#b0851f",
    emph = "#b0851f",
    strong = "#d68c27",
    muted = "#8a8a8a",
    list = "#3b7dd8",
    text = "#1a1a1a",
  },
}

local function set_markdown_hl()
  local c = opencode_md[vim.o.background]
  local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end
  for _, g in ipairs({ "", ".1", ".2", ".3", ".4", ".5", ".6" }) do
    hl("@markup.heading" .. g .. ".markdown", { fg = c.heading, bold = true })
  end
  hl("@markup.raw.block.markdown", { fg = c.text })
  hl("@markup.list.markdown", { fg = c.list })
  hl("@markup.quote.markdown", { fg = c.quote, italic = true })
  hl("@markup.link.url.markdown", { fg = c.link, underline = true })
  hl("@markup.link.label.markdown", { fg = c.link_text })
  hl("@punctuation.special.markdown", { fg = c.muted })
  hl("@markup.strong.markdown_inline", { fg = c.strong, bold = true })
  hl("@markup.italic.markdown_inline", { fg = c.emph, italic = true })
  hl("@markup.raw.markdown_inline", { fg = c.code })
  hl("@markup.link.markdown_inline", { fg = c.muted })
  hl("@markup.link.label.markdown_inline", { fg = c.link_text })
  hl("@markup.link.url.markdown_inline", { fg = c.link, underline = true })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = set_markdown_hl })

local theme = system_theme()
return {
  "projekt0n/github-nvim-theme",
  name = "github-theme",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require("github-theme").setup({
      options = {
        terminal_colors = true,
      },
    })

    vim.cmd.colorscheme(theme == "light" and "github_light" or "github_dark")
  end,
}
