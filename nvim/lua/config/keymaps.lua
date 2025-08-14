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
