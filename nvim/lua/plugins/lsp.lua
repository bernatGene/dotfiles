return {
  "neovim/nvim-lspconfig",
  opts = {
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
