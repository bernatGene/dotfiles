-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

map("n", "<leader>t", function()
  vim.cmd("vsplit | terminal")
  vim.cmd("startinsert")
end, { desc = "V Terminal" })

map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

map("n", "<leader>gg", function()
  vim.cmd("Flog -date=short")
end, { desc = "Git graph (flog)" })
