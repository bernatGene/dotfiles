local M = {}

local title_line = 1
local first_day_line = title_line + 2

local function path_in_dir(path, dir)
  path = vim.fs.normalize(path)
  dir = vim.fs.normalize(dir)
  return path == dir or path:sub(1, #dir + 1) == dir .. "/"
end

local function noon(year, month, day)
  return os.time({ year = year, month = month, day = day, hour = 12 })
end

local function shift_date(timestamp, days)
  local date = os.date("*t", timestamp)
  return noon(date.year, date.month, date.day + days)
end

local function today()
  local date = os.date("*t")
  return noon(date.year, date.month, date.day)
end

local function date_offset(from, to)
  return math.floor(os.difftime(to, from) / 86400 + 0.5)
end

local function count_wiki_links(lines)
  local count = 0
  for _, line in ipairs(lines) do
    for _ in line:gmatch("%[%[[^%]]-%]%]") do
      count = count + 1
    end
  end
  return count
end

local function date_for_calendar_line(year, line)
  local offset = line - first_day_line
  if offset < 0 then
    return nil
  end
  local timestamp = shift_date(noon(year, 1, 1), offset)
  return os.date("*t", timestamp).year == year and timestamp or nil
end

local function calendar_line_for_date(year, timestamp)
  if os.date("*t", timestamp).year ~= year then
    return nil
  end

  local offset = date_offset(noon(year, 1, 1), timestamp)
  return first_day_line + offset
end

function M.setup(opts)
  local vault_path = opts.vault_path
  local daily_notes_folder = opts.daily_notes_folder
  local daily_notes_date_format = opts.daily_notes_date_format
  local calendar_dir = vault_path .. "/" .. opts.calendar_folder

  local function calendar_path(year)
    return string.format("%s/%04d.md", calendar_dir, year)
  end

  local function calendar_year(path)
    path = vim.fs.normalize(path)
    if vim.fn.fnamemodify(path, ":h") ~= vim.fs.normalize(calendar_dir) then
      return nil
    end
    return tonumber(vim.fn.fnamemodify(path, ":t"):match("^(%d%d%d%d)%.md$"))
  end

  local function render_calendar(year)
    local lines = { string.format("# %d Calendar", year), "" }
    local timestamp = noon(year, 1, 1)
    local current_date = today()
    local days = date_offset(timestamp, noon(year + 1, 1, 1))
    for _ = 1, days do
      local date = os.date("*t", timestamp)
      local filename = os.date(daily_notes_date_format, timestamp)
      local daily_path = string.format("%s/%s/%s.md", vault_path, daily_notes_folder, filename)
      local exists = vim.fn.filereadable(daily_path) == 1
      local daily_lines = exists and vim.fn.readfile(daily_path) or {}
      local link = string.format("[[%s]]", filename)
      local visualization = #daily_lines == 0 and "0" or string.rep("#", math.ceil(#daily_lines / 5)) .. #daily_lines
      table.insert(
        lines,
        string.format(
          "%s%s {%s} | %s | %02d | %s",
          date.wday == 2 and "* " or "  ",
          timestamp == current_date and ">" or "-",
          exists and "x" or " ",
          link,
          count_wiki_links(daily_lines),
          visualization
        )
      )
      timestamp = shift_date(timestamp, 1)
    end
    return lines
  end

  local function write_calendar(year)
    local path = calendar_path(year)
    local lines = render_calendar(year)
    local old_lines = vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or nil
    if old_lines and vim.deep_equal(old_lines, lines) then
      return lines
    end
    vim.fn.mkdir(calendar_dir, "p")
    vim.fn.writefile(lines, path)
    return lines
  end

  local function date_at_cursor(bufnr)
    local year = calendar_year(vim.api.nvim_buf_get_name(bufnr))
    return year and date_for_calendar_line(year, vim.api.nvim_win_get_cursor(0)[1]) or nil
  end

  local function jump_to_date(bufnr, timestamp)
    local year = calendar_year(vim.api.nvim_buf_get_name(bufnr))
    local line = year and calendar_line_for_date(year, timestamp)
    if not line then
      return false
    end
    vim.api.nvim_win_set_cursor(0, { line, 0 })
    return true
  end

  local function update_buffer(bufnr, lines)
    if vim.deep_equal(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), lines) then
      return
    end
    local cursor = vim.api.nvim_get_current_buf() == bufnr and vim.api.nvim_win_get_cursor(0) or nil
    vim.bo[bufnr].readonly = false
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modified = false
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].readonly = true
    if cursor then
      vim.api.nvim_win_set_cursor(0, { math.min(cursor[1], #lines), cursor[2] })
    end
  end

  local function reconcile(bufnr)
    local year = calendar_year(vim.api.nvim_buf_get_name(bufnr))
    if year then
      update_buffer(bufnr, write_calendar(year))
    end
  end

  local function open_calendar(year, timestamp)
    if vim.fn.filereadable(calendar_path(year)) == 0 then
      write_calendar(year)
    end
    vim.cmd("edit " .. vim.fn.fnameescape(calendar_path(year)))
    if timestamp then
      jump_to_date(0, timestamp)
    end
  end

  local function prepare_buffer(bufnr)
    if vim.b[bufnr].obsidian_calendar_initialized then
      return
    end
    vim.b[bufnr].obsidian_calendar_initialized = true
    reconcile(bufnr)
    vim.bo[bufnr].readonly = true
    vim.bo[bufnr].modifiable = false
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        opts.on_attach(bufnr)
      end
    end)
  end

  local function enter_buffer(bufnr)
    prepare_buffer(bufnr)
    local current_date = today()
    if calendar_year(vim.api.nvim_buf_get_name(bufnr)) == os.date("*t", current_date).year then
      jump_to_date(bufnr, current_date)
    end
  end

  local function refresh_year(year)
    local lines = write_calendar(year)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) and calendar_year(vim.api.nvim_buf_get_name(bufnr)) == year then
        update_buffer(bufnr, lines)
      end
    end
  end

  local group = vim.api.nvim_create_augroup("ObsidianCalendars", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = group,
    pattern = "*.md",
    callback = function(args)
      if calendar_year(vim.api.nvim_buf_get_name(args.buf)) then
        prepare_buffer(args.buf)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = "*.md",
    callback = function(args)
      if calendar_year(vim.api.nvim_buf_get_name(args.buf)) then
        enter_buffer(args.buf)
      end
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ObsidianNoteEnter",
    callback = function(args)
      if calendar_year(vim.api.nvim_buf_get_name(args.buf)) then
        opts.on_attach(args.buf)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.md",
    callback = function(args)
      local path = vim.api.nvim_buf_get_name(args.buf)
      if path_in_dir(path, vault_path .. "/" .. daily_notes_folder) then
        local year = tonumber(vim.fn.fnamemodify(path, ":t"):match("^(%d%d%d%d)%-"))
        if year then
          refresh_year(year)
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.b[bufnr].obsidian_calendar_initialized then
          reconcile(bufnr)
        end
      end
    end,
  })
  pcall(vim.api.nvim_del_user_command, "ObsidianCalendarRefresh")
  vim.api.nvim_create_user_command("ObsidianCalendarRefresh", function(command)
    local year = tonumber(command.args) or calendar_year(vim.api.nvim_buf_get_name(0)) or os.date("*t", today()).year
    local started = vim.uv.hrtime()
    refresh_year(year)
    vim.notify(string.format("Calendar %d refreshed in %.1f ms", year, (vim.uv.hrtime() - started) / 1e6))
  end, { nargs = "?", desc = "Rebuild an Obsidian calendar year" })

  if calendar_year(vim.api.nvim_buf_get_name(0)) then
    enter_buffer(0)
  end

  M.open_current = function()
    local current_date = today()
    open_calendar(os.date("*t", current_date).year, current_date)
  end
  M.open_daily_at_cursor = function(bufnr)
    local timestamp = date_at_cursor(bufnr)
    if not timestamp then
      return false
    end

    local link = string.format("[[%s]]", os.date(daily_notes_date_format, timestamp))
    local line = vim.api.nvim_get_current_line()
    local link_start, link_end = line:find(link, 1, true)
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
    if not link_start or cursor_col < link_start or cursor_col > link_end then
      return false
    end

    require("obsidian.daily").daily({ date = timestamp }):open()
    return true
  end
  M.move_week = function(bufnr, weeks)
    local timestamp = date_at_cursor(bufnr)
    if timestamp then
      jump_to_date(bufnr, shift_date(timestamp, weeks * 7))
    end
  end
  M.open_adjacent_year = function(bufnr, delta)
    local year = calendar_year(vim.api.nvim_buf_get_name(bufnr))
    if year then
      open_calendar(year + delta)
    end
  end
  M.open_today = function()
    local timestamp = today()
    open_calendar(os.date("*t", timestamp).year, timestamp)
  end
  M.move_month = function(bufnr, delta)
    local timestamp = date_at_cursor(bufnr)
    if timestamp then
      local date = os.date("*t", timestamp)
      jump_to_date(bufnr, noon(date.year, date.month + delta, 1))
    end
  end
  M.refresh_year = refresh_year
end

return M
