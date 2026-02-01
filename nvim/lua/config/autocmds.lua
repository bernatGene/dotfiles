-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--

-- avoids adding > below a line with > in svelte files.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "svelte",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "floggraph",
  callback = function()
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 88
    vim.opt_local.formatoptions:append("t")
  end,
})

local function get_visual_selection()
  vim.cmd('normal! "zy')
  return vim.fn.getreg("z")
end

-- Autocomand to copy markdown as html-rendered-markdown into the clipboard
-- Works only on macOS and requires pandoc.
local function copy_md_rich()
  if vim.uv.os_uname().sysname ~= "Darwin" then
    vim.notify("copy_md_rich: macOS only (uses osascript)", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("pandoc") ~= 1 then
    vim.notify("copy_md_rich: pandoc not found. Install with: brew install pandoc", vim.log.levels.ERROR)
    return
  end

  local md = get_visual_selection()
  if md == "" then
    return
  end

  local res = vim.system({ "pandoc", "-f", "gfm", "-t", "html" }, { stdin = md, text = true }):wait()

  if res.code ~= 0 then
    vim.notify("pandoc: " .. res.stderr, vim.log.levels.ERROR)
    return
  end

  local tmp = os.tmpname() .. ".html"
  local f = io.open(tmp, "w")
  if not f then
    vim.notify("copy_md_rich: failed to create temp file", vim.log.levels.ERROR)
    return
  end
  f:write(res.stdout)
  f:close()

  local script = string.format('set the clipboard to (read (POSIX file "%s") as «class HTML»)', tmp)
  local clip_res = vim.system({ "osascript", "-e", script }):wait()
  os.remove(tmp)

  if clip_res.code ~= 0 then
    vim.notify("clipboard: " .. clip_res.stderr, vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.keymap.set("v", "<leader>j", copy_md_rich, {
      buffer = ev.buf,
      desc = "Copy selection as rich HTML (pandoc, macOS)",
    })
  end,
})
