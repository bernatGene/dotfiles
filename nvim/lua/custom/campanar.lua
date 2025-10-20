-- lua/chime/init.lua
local M = {
  enabled = false,
  timers = {},
  config = {
    quarter_sound = "/System/Library/Sounds/Ping.aiff",
    hour_sound = "/System/Library/Sounds/Purr.aiff",
  },
}

local function play_sound(path, label, repeats)
  repeats = repeats or 1
  local interval = 500 -- ms spacing

  for i = 0, repeats - 1 do
    local tmr = vim.loop.new_timer()
    tmr:start(
      i * interval,
      0,
      vim.schedule_wrap(function()
        vim.fn.jobstart({ "afplay", path }, { detach = true })
        vim.notify(("chime: %s %d/%d"):format(label, i + 1, repeats))
        tmr:stop()
        tmr:close()
      end)
    )
  end
end

local function tick(minute)
  vim.notify("tick" .. minute)
  local rem = minute % 60
  if rem % 15 == 0 then
    if rem == 0 then
      local count = (minute % 12) + 1
      play_sound(M.config.hour_sound, "hour " .. count, count)
    else
      local q = (rem / 15)
      play_sound(M.config.quarter_sound, "quarter " .. q, q)
    end
  end
end

-- test version: tick every 20s, derive “minute” from counter
local function schedule_next_tick(counter)
  counter = (counter or 0) + 1
  local minute = counter
  local delay = 1000
  local timer = vim.loop.new_timer()

  timer:start(
    delay,
    0,
    vim.schedule_wrap(function()
      tick(minute)
      timer:stop()
      timer:close()
      if M.enabled then
        schedule_next_tick(counter)
      end
    end)
  )

  table.insert(M.timers, timer)
end
-- local function schedule_next_tick()
--   local t = now()
--   local next_min = (math.floor(t.min / 15) + 1) * 15
--   if next_min >= 60 then
--     t.hour = (t.hour + 1) % 24
--     next_min = 0
--   end
--   t.min, t.sec = next_min, 0
--   local target = os.time(t)
--   local delay = (target - os.time()) * 1000
--   local timer = vim.loop.new_timer()
--   timer:start(
--     delay,
--     0,
--     vim.schedule_wrap(function()
--       M:tick()
--       timer:stop()
--       timer:close()
--       if M.enabled then
--         schedule_next_tick()
--       end
--     end)
--   )
--   table.insert(M.timers, timer)
-- end
--
-- function M:tick()
--   local t = now()
--   local q = math.floor(t.min / 15)
--   if q == 0 then
--     for _ = 1, t.hour % 12 == 0 and 12 or t.hour % 12 do
--       play_sound(self.config.hour_sound)
--     end
--   else
--     for _ = 1, q do
--       play_sound(self.config.quarter_sound)
--     end
--   end
-- end

function M.enable()
  if M.enabled then
    return
  end
  M.enabled = true
  schedule_next_tick()
end

function M.disable()
  M.enabled = false
  for _, timer in ipairs(M.timers) do
    timer:stop()
    timer:close()
  end
  M.timers = {}
end

function M.toggle()
  if M.enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.status()
  return M.enabled and "chime:on" or "chime:off"
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  vim.api.nvim_create_user_command("ChimeToggle", M.toggle, {})
end

return M
