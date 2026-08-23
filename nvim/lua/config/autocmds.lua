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

-- Prefix headings with their semantic number: `## 2. Foo`, `### 2.1. Bar`.
-- H1 stays unprefixed; children are numbered from the nearest numbered ancestor
-- (e.g. `###` directly under `#` becomes `1.`). Idempotent: existing prefixes are
-- stripped and recomputed. Headings inside fenced code blocks / frontmatter are
-- ignored (handled by the treesitter markdown parser, which must be installed).
local function number_headings()
  local buf = vim.api.nvim_get_current_buf()

  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if not ok or not parser then
    vim.notify("NumberHeadings: markdown treesitter parser not available", vim.log.levels.WARN)
    return
  end

  local root = parser:parse()[1]:root()
  local headings = {}
  local stack = { root }
  while #stack > 0 do
    local node = table.remove(stack)
    if node:type() == "atx_heading" then
      table.insert(headings, node)
    else
      -- push in reverse so popping yields children in document order
      for i = node:named_child_count() - 1, 0, -1 do
        stack[#stack + 1] = node:named_child(i)
      end
    end
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local counters = {}

  for _, node in ipairs(headings) do
    local marker = node:named_child(0)
    local level = marker and tonumber(marker:type():match("atx_h(%d)_marker"))
    local row = node:start() + 1
    local hashes, title = lines[row]:match("^(#+)%s+(%S.*)$")
    if level and hashes and #hashes <= 6 then
      local old_num = title:match("^(%d[%d%.]*)%.%s+")
      if old_num then
        title = title:sub(#old_num + 3)
      end
      counters[level] = (counters[level] or 0) + 1
      for deeper = level + 1, 6 do
        counters[deeper] = nil
      end
      if level > 1 then
        local parts = {}
        for l = 2, level do
          if counters[l] then
            parts[#parts + 1] = tostring(counters[l])
          end
        end
        title = table.concat(parts, ".") .. ". " .. title
      end
      lines[row] = hashes .. " " .. title
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.api.nvim_buf_create_user_command(ev.buf, "NumberHeadings", number_headings, {})
    vim.keymap.set("n", "<leader>mh", "<cmd>NumberHeadings<cr>", {
      buffer = ev.buf,
      desc = "Number markdown headings",
    })
  end,
})
