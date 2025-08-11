return {
  "bernatGene/sherlock.nvim",
  -- dir = "/Users/bernatskrabec/p/sherlock.nvim", -- comment to test online version
  ft = { "svelte", "typescript" }, -- Only load for these filetypes
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("sherlock").setup({
      translation_file_path = "src/lib/paraglide/messages/en.js",
      highlight_group = "DiagnosticInfo",
      prefix = " >> ",
    })

    -- Your keybinding
    vim.keymap.set("n", "<leader>tp", "<cmd>ParaglideToggle<cr>", { desc = "Toggle paraglide hints" })

    vim.keymap.set("v", "<leader>te", function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      vim.schedule(function()
        require("sherlock").extract_translation()
      end)
    end, { desc = "Extract translation" })
  end,
}
