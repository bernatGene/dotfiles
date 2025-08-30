-- lua/git_diff_cache.lua
local M = { diff = nil, running = false }

local function update()
  if M.running then
    return
  end
  M.running = true

  vim.system({ "git", "status", "--porcelain" }, { text = true }, function(obj)
    M.running = false
    if obj.code ~= 0 then
      M.diff = nil
      return
    end

    local added, modified, removed = 0, 0, 0
    for line in obj.stdout:gmatch("[^\r\n]+") do
      local status = line:sub(1, 2)
      if status == "??" or status:find("A") then
        added = added + 1
      elseif status:find("M") then
        modified = modified + 1
      elseif status:find("D") then
        removed = removed + 1
      end
    end

    if added + modified + removed == 0 then
      M.diff = nil
    else
      M.diff = { added = added, modified = modified, removed = removed }
    end
  end)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "GitsignsUpdate",
  callback = update,
})

-- initial run
update()

return M
