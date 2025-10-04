local function system_theme()
  local h = io.popen([[osascript -e 'tell app "System Events" to return dark mode of appearance preferences']])
  if h == nil then
    return "dark"
  end
  local res = h:read("*a")
  h:close()
  return res:match("true") and "dark" or "light"
end

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
