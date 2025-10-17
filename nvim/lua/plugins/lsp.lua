return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      float = {
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    },
    servers = {
      biome = {
        filetypes = {
          "javascript",
          "typescript",
          "json",
        },
      },

      astro = {},
      pyright = {
        settings = {
          python = {
            analysis = {
              -- disable all type checking
              typeCheckingMode = "off",
              autoImportCompletions = false,
            },
          },
        },
      },
    },
  },
}
