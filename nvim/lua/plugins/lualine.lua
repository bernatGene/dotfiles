local git_diff_cache = require("custom/git_diff_cache")

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
      },
    }
  end,
}
