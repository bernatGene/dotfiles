return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      exclude = { "svelte" },
    },
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

      -- obsidian.nvim's LSP covers the vault; marksman breaks there (artempyanykh/marksman#469)
      marksman = {
        root_dir = function(bufnr, on_dir)
          local file = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
          for _, workspace in ipairs(LazyVim.opts("obsidian.nvim").workspaces or {}) do
            local vault = vim.fs.normalize(workspace.path)
            if file:sub(1, #vault + 1) == vault .. "/" then
              return
            end
          end
          on_dir(vim.fs.root(bufnr, { ".marksman.toml", ".git" }))
        end,
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
      ty = { enabled = false }, -- will come around to that but not right now
    },
  },
}
