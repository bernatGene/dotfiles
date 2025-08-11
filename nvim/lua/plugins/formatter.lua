return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Keep existing opts
    return opts
  end,
  keys = {
    {
      "<leader>cf",
      function()
        if vim.bo.filetype == "bigfile" then
          vim.cmd([[%!python -m json.tool]])
          vim.cmd("write")
        else
          require("conform").format({ async = true })
        end
      end,
      mode = { "n", "v" },
      desc = "Format",
    },
  },
}
