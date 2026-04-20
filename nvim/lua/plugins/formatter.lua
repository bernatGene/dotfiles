return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters = opts.formatters or {}

    local biome_configs = { "biome.json", "biome.jsonc" }

    opts.formatters.biome = {
      condition = function(_, ctx)
        return vim.fs.find(biome_configs, { path = ctx.filename, upward = true })[1] ~= nil
      end,
    }

    local biome_or_prettier = { "biome", "prettier", stop_after_first = true }
    local filetypes = {
      "astro",
      "svelte",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    }

    for _, ft in ipairs(filetypes) do
      opts.formatters_by_ft[ft] = biome_or_prettier
    end

    opts.formatters_by_ft.python = { "ruff_format" }
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
