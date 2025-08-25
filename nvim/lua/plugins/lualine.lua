return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    return {
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          {
            "diff",
            colored = true,
            symbols = { added = "+", modified = "~", removed = "-" },
            source = function()
              local handle = io.popen("git status --porcelain 2>/dev/null")
              if not handle then
                return nil
              end

              local result = handle:read("*a")
              handle:close()

              if not result or result == "" then
                return nil
              end

              local added, modified, removed = 0, 0, 0
              for line in result:gmatch("[^\r\n]+") do
                local status = line:sub(1, 2)
                if status == "??" or status:find("A") then
                  added = added + 1
                elseif status:find("M") then
                  modified = modified + 1
                elseif status:find("D") then
                  removed = removed + 1
                end
              end
              if added == 0 and modified == 0 and removed == 0 then
                return nil
              end

              return { added = added, modified = modified, removed = removed }
            end,
          },
        },
      },
    }
  end,
}
