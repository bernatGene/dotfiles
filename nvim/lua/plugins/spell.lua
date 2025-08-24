return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>r",
        function()
          local word = vim.fn.expand("<cword>")
          vim.notify(word)
          local suggestions = vim.fn.spellsuggest(word)
          vim.notify(suggestions)
          if #suggestions == 0 then
            vim.notify("No spelling suggestions")
            return
          end

          vim.ui.select(suggestions, {
            prompt = "Spelling suggestions:",
          }, function(choice)
            if choice then
              vim.cmd("normal! ciw" .. choice)
            end
          end)
        end,
        desc = "Spell suggest",
      },
      {
        "<leader>z",
        function()
          local langs = { "en", "es", "ca" }
          local current = vim.opt.spelllang:get()[1] or "none"

          vim.ui.select(langs, {
            prompt = "Select spell language (current: " .. current .. ")",
            format_item = function(item)
              return item == current and (item .. " ✓") or item
            end,
          }, function(choice)
            if choice then
              vim.opt.spell = true
              vim.opt.spelllang = { choice }
              vim.notify("Spell language set to " .. choice, vim.log.levels.INFO)
            end
          end)
        end,
        desc = "Set spell language",
      },
    },
  },
}
