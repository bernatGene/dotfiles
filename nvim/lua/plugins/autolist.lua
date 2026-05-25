return {
  "gaoDean/autolist.nvim",
  ft = {
    "markdown",
    "text",
    "tex",
    "plaintex",
    "norg",
  },
  config = function()
    require("autolist").setup()

    local function sort_markdown_todos(start_line, end_line)
      if start_line > end_line then
        start_line, end_line = end_line, start_line
      end

      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      local first_line_index
      local base_indent

      for i, line in ipairs(lines) do
        if line:match("%S") then
          local indent = line:match("^(%s*)%- %[([ xX])%] ")
          if not indent then
            return
          end

          first_line_index = i
          base_indent = indent
          break
        end
      end

      if not first_line_index or not base_indent then
        return
      end

      local function checkbox_state(line)
        local indent, state = line:match("^(%s*)%- %[([ xX])%] ")
        if indent == base_indent then
          return state
        end
      end

      local function is_deeper(line)
        local indent = line:match("^(%s*)")
        return indent:sub(1, #base_indent) == base_indent and #indent > #base_indent
      end

      local pending = {}
      local done = {}
      local current_block
      local current_state

      for i = first_line_index, #lines do
        local line = lines[i]
        local state = checkbox_state(line)

        if state then
          if current_block then
            vim.list_extend(current_state == " " and pending or done, current_block)
          end
          current_block = { line }
          current_state = state
        elseif current_block and (line == "" or is_deeper(line) or line:match("%S")) then
          table.insert(current_block, line)
        else
          return
        end
      end

      if current_block then
        vim.list_extend(current_state == " " and pending or done, current_block)
      end

      if #pending == 0 or #done == 0 then
        return
      end

      local sorted = {}
      for i = 1, first_line_index - 1 do
        table.insert(sorted, lines[i])
      end
      vim.list_extend(sorted, pending)
      vim.list_extend(sorted, done)

      vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, sorted)
    end

    local function set_autolist_keymaps(buf)
      local map = function(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = buf
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      map("i", "<tab>", "<cmd>AutolistTab<cr>")
      map("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
      map("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
      map("n", "o", "o<cmd>AutolistNewBullet<cr>")
      map("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
      map("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
      map("n", "<leader>ar", "<cmd>AutolistRecalculate<cr>", { desc = "Autolist recalc" })
      map("n", ">>", ">><cmd>AutolistRecalculate<cr>")
      map("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
      map("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
      map("v", "d", "d<cmd>AutolistRecalculate<cr>")

      if vim.bo[buf].filetype == "markdown" then
        vim.api.nvim_buf_create_user_command(buf, "SortMarkdownTodos", function(opts)
          sort_markdown_todos(opts.line1, opts.line2)
        end, { range = true })

        map("v", "<leader>st", ":SortMarkdownTodos<cr>", { desc = "Sort markdown todos" })
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "text", "tex", "plaintex", "norg" },
      callback = function(ev)
        set_autolist_keymaps(ev.buf)
      end,
    })
  end,
}
