local git_diff_cache = require("custom/git_diff_cache")
local timew = require("custom/timew")
local chime = require("custom/campanar")
chime.setup()
timew.init()

return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    return {
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          {
            "diff",
            colored = true,
            symbols = { added = "+", modified = "~", removed = "-" },
            source = function()
              return git_diff_cache.diff
            end,
          },
        },
        lualine_x = {
          chime.status,
        },
      },
    }
  end,
}
