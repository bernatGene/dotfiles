-- Obsidian Calendar Events: shared in-memory EventKit data and daily-note display.
-- On macOS, compile once from the dotfiles root (Swift command-line tools required):
--   mkdir -p ~/.local/bin
--   swiftc -O nvim/lua/plugins/obsidian/obsidian-calendar-events.swift -o ~/.local/bin/obsidian-calendar-events
-- Put ~/.local/bin on Neovim's PATH; grant Full Calendar Access when prompted.
-- The helper only reads events; its JSON output contains private event data.
-- Set calendar_events_enabled = false in plugins/obsidian.lua to disable.
local M = {}

local namespace = vim.api.nvim_create_namespace("ObsidianCalendarEvents")
local cache = {}
local enabled = false
local on_update
local daily_date
local calendar_year
local missing_notified = false
local failure_notified = false

local function noon(year, month, day)
  return os.time({ year = year, month = month, day = day, hour = 12 })
end

local function date_key(timestamp)
  return os.date("%Y-%m-%d", timestamp)
end

local function clean(text)
  return text:gsub("%s+", " "):gsub("[%c]", " ")
end

local function index_events(year, events)
  if type(events) ~= "table" or not vim.islist(events) then
    return nil
  end

  local by_day = {}
  for _, event in ipairs(events) do
    if
      type(event) ~= "table"
      or type(event.title) ~= "string"
      or type(event.start) ~= "number"
      or type(event["end"]) ~= "number"
      or event["end"] < event.start
      or type(event.allDay) ~= "boolean"
      or type(event.calendars) ~= "table"
    then
      return nil
    end
    for i, calendar in ipairs(event.calendars) do
      if type(calendar) ~= "string" then
        return nil
      end
      event.calendars[i] = clean(calendar)
    end

    event.title = clean(event.title)
    local start = os.date("*t", event.start)
    local last = os.date("*t", math.max(event.start, event["end"] - 1))
    local day = math.max(noon(start.year, start.month, start.day), noon(year, 1, 1))
    local final_day = math.min(noon(last.year, last.month, last.day), noon(year, 12, 31))
    while day <= final_day do
      local key = date_key(day)
      by_day[key] = by_day[key] or {}
      table.insert(by_day[key], event)
      local current = os.date("*t", day)
      day = noon(current.year, current.month, current.day + 1)
    end
  end
  for _, events in pairs(by_day) do
    table.sort(events, function(a, b)
      if a.start ~= b.start then
        return a.start < b.start
      end
      return a.title < b.title
    end)
  end
  return by_day
end

local function time_for_day(event, timestamp)
  if event.allDay then
    return "All day"
  end
  if event.start == event["end"] then
    return os.date("%H:%M", event.start)
  end
  local key = date_key(timestamp)
  local first = date_key(event.start)
  local last = date_key(math.max(event.start, event["end"] - 1))
  if key ~= first and key ~= last then
    return "All day (continuing)"
  elseif key ~= first then
    return "Until " .. os.date("%H:%M", event["end"])
  elseif key ~= last then
    return os.date("%H:%M", event.start) .. " onward"
  end
  return os.date("%H:%M", event.start) .. "–" .. os.date("%H:%M", event["end"])
end

local function draw_daily(bufnr, year, timestamp)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  local result = cache[year]
  if not result or not result.by_day then
    return
  end

  local events = result.by_day[date_key(timestamp)] or {}
  local lines = { { { "", "Normal" } }, { { "Calendar:", "Normal" } } }
  if #events == 0 then
    table.insert(lines, { { "  - No events", "Normal" } })
  else
    for _, event in ipairs(events) do
      local time = time_for_day(event, timestamp)
      local source = table.concat(event.calendars, ", ")
      local spacing = string.rep(" ", math.max(1, 22 - vim.fn.strdisplaywidth(time)))
      table.insert(lines, { { "  - " .. time .. spacing .. event.title .. " · " .. source, "Normal" } })
    end
  end
  vim.api.nvim_buf_set_extmark(bufnr, namespace, vim.api.nvim_buf_line_count(bufnr) - 1, 0, {
    virt_lines = lines,
    virt_lines_above = false,
    virt_lines_leftcol = true,
  })
end

function M.count(year, timestamp)
  local result = enabled and cache[year]
  if not result or not result.by_day then
    return nil
  end
  return #(result.by_day[date_key(timestamp)] or {})
end

function M.ensure(year)
  if not enabled or not year then
    return
  end
  local state = cache[year] or {}
  cache[year] = state
  local now = vim.uv.hrtime() / 1e9
  if state.in_flight or (state.last_attempt and now - state.last_attempt < 60) then
    return
  end
  state.last_attempt = now

  local executable = vim.fn.exepath("obsidian-calendar-events")
  if executable == "" then
    if not missing_notified then
      missing_notified = true
      vim.notify(
        "Obsidian Calendar Events: helper missing; see plugins/obsidian/obsidian_calendar_events.lua for setup",
        vim.log.levels.WARN
      )
    end
    return
  end

  state.in_flight = true
  vim.system({ executable, string.format("%04d", year) }, { text = true, timeout = 10000 }, function(process)
    vim.schedule(function()
      if not enabled or cache[year] ~= state then
        return
      end
      state.in_flight = false
      local ok, data = pcall(vim.json.decode, process.stdout or "")
      local by_day = process.code == 0 and ok and index_events(year, data) or nil
      if not by_day then
        if not failure_notified then
          failure_notified = true
          vim.notify(
            "Obsidian Calendar Events: query failed; check Calendar permissions or helper setup",
            vim.log.levels.WARN
          )
        end
        return
      end
      failure_notified = false
      state.by_day = by_day
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local daily_year, timestamp = daily_date(vim.api.nvim_buf_get_name(bufnr))
          if daily_year == year then
            draw_daily(bufnr, year, timestamp)
          end
        end
      end
      on_update(year)
    end)
  end)
end

function M.setup(opts)
  enabled = opts.enabled and vim.fn.has("mac") == 1
  on_update = opts.on_update
  daily_date = opts.daily_date
  calendar_year = opts.calendar_year
  cache = {}

  local group = vim.api.nvim_create_augroup("ObsidianCalendarEvents", { clear = true })
  if not enabled then
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      end
    end
    return
  end
  local function enter_buffer(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    local year, timestamp = daily_date(path)
    if year then
      draw_daily(bufnr, year, timestamp)
    end
    M.ensure(year or calendar_year(path))
  end
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
    group = group,
    callback = function(args)
      enter_buffer(args.buf or vim.api.nvim_get_current_buf())
    end,
  })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
    group = group,
    callback = function(args)
      local year, timestamp = daily_date(vim.api.nvim_buf_get_name(args.buf))
      if year then
        draw_daily(args.buf, year, timestamp)
      end
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ObsidianNoteEnter",
    callback = function(args)
      enter_buffer(args.buf)
    end,
  })
  enter_buffer(vim.api.nvim_get_current_buf())
end

return M
