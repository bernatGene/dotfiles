local source = {}

local cache = {}

function source.new()
  return setmetatable({}, { __index = source })
end

local function is_opencode_buffer(buf)
  local root = vim.env.OPENCODE_EDIT_ROOT

  return vim.bo[buf].filetype == "markdown"
    and root ~= nil
    and vim.fn.isdirectory(root) == 1
    and vim.env.OPENCODE_EDIT_FILE ~= nil
end

function source:enabled()
  return is_opencode_buffer(vim.api.nvim_get_current_buf())
end

function source:get_trigger_characters()
  return { "@" }
end

local function ref_range(ctx)
  local cursor = ctx.cursor or {}
  local line_idx = (cursor[1] or vim.api.nvim_win_get_cursor(0)[1]) - 1
  local col = cursor[2] or vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_buf_get_lines(ctx.bufnr, line_idx, line_idx + 1, false)[1] or ""
  local before = line:sub(1, col)
  local start_col = before:match(".*()%@[^%s]*$")

  if not start_col then
    return nil
  end

  if start_col > 1 and before:sub(start_col - 1, start_col - 1):match("[%w._%%+%-]") then
    return nil
  end

  return {
    start = { line = line_idx, character = start_col - 1 },
    ["end"] = { line = line_idx, character = col },
  }
end

local function list_files(root)
  if cache[root] then
    return cache[root]
  end

  local res = vim.system({ "rg", "--files", "--hidden", "-g", "!.git" }, { cwd = root, text = true }):wait()
  if res.code ~= 0 then
    vim.notify("opencode refs: rg --files failed", vim.log.levels.WARN)
    cache[root] = {}
    return cache[root]
  end

  cache[root] = vim.split(res.stdout, "\n", { trimempty = true })
  return cache[root]
end

function source:get_completions(ctx, callback)
  local range = ref_range(ctx)
  if not range then
    callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
    return
  end

  local root = vim.env.OPENCODE_EDIT_ROOT
  local items = {}
  for _, path in ipairs(list_files(root)) do
    table.insert(items, {
      label = path,
      filterText = "@" .. path,
      sortText = path,
      kind = require("blink.cmp.types").CompletionItemKind.File,
      textEdit = {
        newText = "@" .. path,
        range = range,
      },
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    })
  end

  callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
end

return source
