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
      pyright = {
        settings = {
          python = {
            analysis = {
              -- disable all type checking
              typeCheckingMode = "off",
              -- or fine-tune specific diagnostics:
            },
          },
        },
      },
    },
  },
}
