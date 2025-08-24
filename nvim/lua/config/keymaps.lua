-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

map("n", "<leader>gg", function()
  vim.cmd("Flog -date=short")
end, { desc = "Git graph (flog)" })

map("v", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map("v", "<leader>x", '"+x', { desc = "Cut to system clipboard" })

--spell
vim.keymap.set("n", "<leader>r", function()
  local word = vim.fn.expand("<cword>")
  local suggestions = vim.fn.spellsuggest(word)
  if #suggestions == 0 then
    vim.notify("No spelling suggestions")
    return
  end
  vim.ui.select(suggestions, { prompt = "Spelling suggestions:" }, function(choice)
    if choice then
      vim.cmd("normal! ciw" .. choice)
    end
  end)
end, { desc = "Spell suggest" })

vim.keymap.set("n", "<leader>z", function()
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
end, { desc = "Set spell language" })
