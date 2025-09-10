-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

map("n", "<leader>gg", function()
  vim.cmd("Flog -date=short -all")
end, { desc = "Git graph (flog)" })

map("v", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map("v", "<leader>x", '"+x', { desc = "Cut to system clipboard" })

--spell.lua
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
  local langs = { "en", "es", "ca", "en,ca", "" }
  local display_names = {
    en = "English",
    es = "Castellano",
    ca = "Català",
    ["en,ca"] = "En/Ca",
    [""] = "Disable",
  }
  local current = ""
  if vim.o.spell then
    current = vim.opt.spelllang:get()[1] or ""
  end
  vim.ui.select(langs, {
    prompt = "Select spell language (current: " .. (display_names[current] or "Disabled") .. ")",
    format_item = function(item)
      return item == current and (display_names[item] .. " ✓") or display_names[item]
    end,
  }, function(choice)
    if choice then
      if choice == "" then
        vim.opt.spell = false
        vim.notify("Spell check disabled", vim.log.levels.INFO)
      else
        vim.opt.spell = true
        vim.opt.spelllang = { choice }
        vim.notify("Spell language set to " .. display_names[choice], vim.log.levels.INFO)
      end
    end
  end)
end, { desc = "Set spell language" })

--timew
local wk = require("which-key")
local timew = require("custom/timew")
wk.add({
  { "<leader>t", group = "timew" },

  {
    "<leader>tc",
    function()
      timew.start("CODE")
    end,
    desc = "Start CODE",
    icon = { icon = "", color = "green" },
  },
  {
    "<leader>tw",
    function()
      timew.start("WRIT")
    end,
    desc = "Start WRIT",
    icon = { icon = "", color = "yellow" },
  },
  {
    "<leader>tp",
    function()
      timew.start("PROC")
    end,
    desc = "Start PROC",
    icon = { icon = "", color = "red" },
  },
  {
    "<leader>tr",
    function()
      timew.start("READ")
    end,
    desc = "Start READ",
    icon = { icon = "", color = "blue" },
  },
  {
    "<leader>td",
    function()
      timew.start("DRAW")
    end,
    desc = "Start DRAW",
    icon = { icon = "", color = "azure" },
  },

  {
    "<leader>ts",
    function()
      timew.stop()
    end,
    desc = "STOPPED",
    icon = { icon = "", color = "grey" },
  },
}, { mode = "n" })
