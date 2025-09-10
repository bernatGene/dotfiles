-- lua/custom/timew.lua
local M = {}

local state = "STOP"

local known = {
  CODE = true,
  WRIT = true,
  PROC = true,
  READ = true,
  DRAW = true,
}

local function run(cmd)
  local out = vim.fn.system(cmd .. " 2>&1")
  local code = vim.v.shell_error
  return vim.trim(out or ""), code
end

local function parse_export_one(json_out)
  local ok, data = pcall(vim.json.decode, json_out)
  if not ok or type(data) ~= "table" or #data == 0 then
    return nil
  end
  local it = data[1] -- using @1 should return a single-element array
  if not it then
    return nil
  end
  if it["end"] == nil then
    if type(it.tags) == "table" and it.tags[1] then
      local tag = it.tags[1]
      return known[tag] and tag or "UNKNOWN"
    end
    return "UNKNOWN"
  end
  return "STOP"
end

function M.sync()
  local out, code = run("timew export @1")
  if code ~= 0 or out == "" then
    state = "STOP"
    return state
  end
  local res = parse_export_one(out)
  if res then
    state = res
  else
    state = "STOP"
  end
  return state
end

function M.init()
  M.sync()
  return state
end

-- start a known tag; update cache immediately
function M.start(tag)
  if not known[tag] then
    vim.schedule(function()
      vim.notify("timew: unknown tag: " .. tostring(tag), vim.log.levels.WARN)
    end)
    return nil, "unknown tag"
  end
  run("timew stop")
  run("timew start " .. tag)
  state = tag
  return state
end

-- stop tracking; update cache
function M.stop()
  run("timew stop")
  state = "STOP"
  return state
end

-- return cached state (no probing)
function M.current()
  return state
end

return M
