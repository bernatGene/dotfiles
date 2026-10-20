-- Template substitution that carries unticked tasks from the previous daily note into today's.
local M = {}

local heading = "## Tasques"
local lookback_days = 7

function M.setup(opts)
  heading = opts.heading or heading
  lookback_days = opts.lookback_days or lookback_days
end

local function shift_days(days)
  local date = os.date("*t")
  return os.time({ year = date.year, month = date.month, day = date.day + days, hour = 12 })
end

local function daily_path(days)
  local path = require("obsidian.daily").daily_note_path(shift_days(days))
  return vim.fs.normalize(tostring(path))
end

local function open_tasks(lines)
  local start
  for i, line in ipairs(lines) do
    if line == heading then
      start = i + 1
      break
    end
  end
  if not start then
    return {}
  end

  while lines[start] and lines[start]:match("^%s*$") do
    start = start + 1
  end

  local tasks = {}
  local carrying = false
  for i = start, #lines do
    local line = lines[i]
    if line:match("^%s*$") or line:match("^#") then
      break
    end
    if line:match("^%s") then
      if carrying then
        table.insert(tasks, line)
      end
    else
      carrying = line:match("^%- %[ %]%s*%S") ~= nil
      if carrying then
        table.insert(tasks, line)
      end
    end
  end
  return tasks
end

function M.substitution(ctx)
  if not ctx.destination_path or vim.fs.normalize(tostring(ctx.destination_path)) ~= daily_path(0) then
    return ""
  end
  for days = 1, lookback_days do
    local path = daily_path(-days)
    if vim.fn.filereadable(path) == 1 then
      local tasks = open_tasks(vim.fn.readfile(path))
      return #tasks > 0 and "\n" .. table.concat(tasks, "\n") or ""
    end
  end
  return ""
end

return M
