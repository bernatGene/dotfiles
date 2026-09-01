-- ~/.config/nvim/lua/plugins/obsidian.lua
local wk = require("which-key")
local vault_path = "/Users/bernat/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault"
local daily_notes_folder = "dailynote"
local calendar_folder = "calendar"
local daily_notes_date_format = "%Y-%m-%d-%a"
wk.add({
  { "<leader>o", group = "obsidian", desc = "obsidian", icon = { icon = "󰇈", color = "purple" } },
})

local function path_in_dir(path, dir)
  path = vim.fs.normalize(path)
  dir = vim.fs.normalize(dir)
  return path == dir or path:sub(1, #dir + 1) == dir .. "/"
end

local function open_vault_explorer()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local mf = require("mini.files")
  local opts = { windows = { preview = true } }
  if buf_path == "" then
    mf.open(vault_path, true, opts)
  end
  buf_path = vim.fs.normalize(buf_path)
  local vault_norm = vim.fs.normalize(vault_path)
  if not path_in_dir(buf_path, vault_norm) then
    mf.open(vault_path, true, opts)
    return
  end
  mf.open(buf_path, true, opts)
end

local function goto_daily(delta)
  local path = vim.api.nvim_buf_get_name(0)
  local fname = vim.fn.fnamemodify(path, ":t")
  local y, m, d = fname:match("^(%d+)%-(%d+)%-(%d+)%-%a")
  if not (y and m and d) then
    vim.notify("Not a daily note", vim.log.levels.WARN)
    return
  end
  local t = os.time({ year = y, month = m, day = d })
  local today = os.date("*t")
  local base = os.time({ year = today.year, month = today.month, day = today.day })
  -- TODO: Use civil-date arithmetic here; 86400-second offsets are DST-sensitive.
  local offset = math.floor((t - base) / 86400)
  vim.cmd("Obsidian today " .. (offset + delta))
end

local function project_scratch_dir(must_exist)
  local workspace = Obsidian.workspace
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local scratch_dir = workspace.path.filename .. "/" .. project_name
  local exists = vim.fn.isdirectory(scratch_dir) == 1
  if must_exist and not exists then
    vim.notify("No scratch notes directory for project: " .. project_name, vim.log.levels.WARN)
  end
  return scratch_dir, project_name, exists
end

local function new_project_scratch_note()
  local scratch_dir, project_name = project_scratch_dir(false)
  vim.fn.mkdir(scratch_dir, "p")
  local datetime = os.date("%Y%m%d%H%M")
  local base_name = string.format("%s_%s_note.md", datetime, project_name)
  local note_path = scratch_dir .. "/" .. base_name
  local counter = 1
  while vim.fn.filereadable(note_path) == 1 do
    note_path = string.format("%s/%s-%d_%s_note.md", scratch_dir, datetime, counter, project_name)
    counter = counter + 1
  end
  vim.cmd("edit " .. vim.fn.fnameescape(note_path))
  if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
    local lines = {
      "# Project Note - " .. project_name,
      "",
      "Created: " .. os.date("%Y-%m-%d %H:%M"),
      "Project: " .. vim.fn.getcwd(),
      "",
      "## Notes",
      "",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, { #lines, 0 })
  end
end

local function new_root_note()
  vim.ui.input({ prompt = "New root note title: " }, function(input)
    if input and input ~= "" then
      local note = require("obsidian.note").create({
        id = input,
        dir = vault_path,
        template = Obsidian.opts.note.template,
        should_write = true,
      })
      note:open({ sync = true })
    end
  end)
end

local function open_last_project_scratch_note()
  local scratch_dir, project_name, exists = project_scratch_dir(true)
  if not exists then
    return
  end
  local notes = {}
  for name, type in vim.fs.dir(scratch_dir) do
    if type == "file" and name:match("%note.md$") then
      table.insert(notes, name)
    end
  end
  if #notes == 0 then
    vim.notify("No scratch notes found for project: " .. project_name, vim.log.levels.WARN)
    return
  end
  table.sort(notes)
  vim.cmd("edit " .. vim.fn.fnameescape(scratch_dir .. "/" .. notes[#notes]))
end

local function search_project_scratch_notes()
  local scratch_dir, project_name, exists = project_scratch_dir(true)
  if not exists then
    return
  end
  require("fzf-lua").files({
    prompt = "Project Scratch Notes - " .. project_name,
    cwd = scratch_dir,
    fd_opts = "--type f --extension md",
  })
end

local function daily_link(ctx, offset, label)
  local note = ctx.partial_note
  if not note or not note.id then
    vim.notify("ctx.partial_note is nil or missing id", vim.log.levels.WARN)
    return ""
  end
  local y, m, d = note.id:match("(%d+)%-(%d+)%-(%d+)%-%a")
  if not (y and m and d) then
    vim.notify("Failed to parse date from id: " .. tostring(note.id), vim.log.levels.WARN)
    return ""
  end
  local t = os.time({ year = y, month = m, day = d })
  local date = os.date(daily_notes_date_format, t + offset * 86400)
  return string.format("[[%s/%s|%s]]", daily_notes_folder, date, label)
end

local function mention_link_for_path(path)
  return "[[" .. vim.fn.fnamemodify(path, ":t:r") .. "]]"
end

local function daily_note_has_link(lines, link)
  local escaped_link = vim.pesc(link)
  for _, line in ipairs(lines) do
    if line:find(escaped_link) then
      return true
    end
  end
  return false
end

local function insert_daily_mention(lines, mention_line)
  local mentions_heading = "## Mentions"
  local heading_index
  for i, line in ipairs(lines) do
    if line == mentions_heading then
      heading_index = i
      break
    end
  end

  if not heading_index then
    if #lines > 0 and lines[#lines] ~= "" then
      table.insert(lines, "")
    end
    table.insert(lines, mentions_heading)
    table.insert(lines, "")
    table.insert(lines, mention_line)
    return lines
  end

  local insert_at = heading_index + 1
  while insert_at <= #lines and lines[insert_at] == "" do
    insert_at = insert_at + 1
  end
  table.insert(lines, insert_at, mention_line)
  return lines
end

local function add_daily_mention(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" or vim.fn.fnamemodify(path, ":e") ~= "md" then
    return false
  end

  path = vim.fs.normalize(path)
  local vault_norm = vim.fs.normalize(vault_path)
  if not path_in_dir(path, vault_norm) then
    return false
  end

  local daily_notes_dir = vim.fs.normalize(vault_path .. "/" .. daily_notes_folder)
  local calendar_dir = vim.fs.normalize(vault_path .. "/" .. calendar_folder)
  if path_in_dir(path, daily_notes_dir) or path_in_dir(path, calendar_dir) then
    return false
  end

  local link = mention_link_for_path(path)
  local timestamp = os.time()
  local daily = require("obsidian.daily")
  local daily_path = vim.fs.normalize(tostring(daily.daily_note_path(timestamp)))
  if vim.fn.filereadable(daily_path) ~= 1 then
    daily_path = vim.fs.normalize(tostring(daily.daily({ date = timestamp }).path))
  end

  local lines = vim.fn.readfile(daily_path)

  if daily_note_has_link(lines, link) then
    return false
  end

  insert_daily_mention(lines, "- " .. link)
  if vim.fn.writefile(lines, daily_path) ~= 0 then
    vim.notify("Failed to add mention to " .. daily_path, vim.log.levels.ERROR)
    return false
  end
  return true, os.date("*t", timestamp).year
end

local function setup_daily_mentions()
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("ObsidianDailyMentions", { clear = true }),
    pattern = "*.md",
    callback = function(args)
      local added, year = add_daily_mention(args.buf)
      if added then
        require("config.obsidian_calendar").refresh_year(year)
      end
    end,
  })
end

local function attach_calendar_mappings(bufnr)
  local calendar = require("config.obsidian_calendar")
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end

  vim.keymap.set("n", "<CR>", function()
    if calendar.open_daily_at_cursor(bufnr) then
      return ""
    end
    return require("obsidian.api").smart_action()
  end, { buffer = bufnr, desc = "Open calendar daily note", expr = true })

  map("<leader>oj", function()
    calendar.move_week(bufnr, 1)
  end, "Next calendar week")
  map("<leader>ok", function()
    calendar.move_week(bufnr, -1)
  end, "Previous calendar week")
  map("<leader>oJ", function()
    calendar.open_adjacent_year(bufnr, 1)
  end, "Next calendar year")
  map("<leader>oK", function()
    calendar.open_adjacent_year(bufnr, -1)
  end, "Previous calendar year")
  map("<leader>oD", calendar.open_today, "Jump to today")
  map("]m", function()
    calendar.move_month(bufnr, 1)
  end, "Next calendar month")
  map("[m", function()
    calendar.move_month(bufnr, -1)
  end, "Previous calendar month")
end

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "saghen/blink.cmp",
    "nvim-mini/mini.files",
  },
  keys = {
    -- daily notes
    { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Open daily note" },
    {
      "<leader>oC",
      function()
        require("config.obsidian_calendar").open_current()
      end,
      desc = "Open current calendar",
    },
    { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Open yesterday's note" },
    { "<leader>ot", "<cmd>Obsidian tomorrow<cr>", desc = "Open tomorrow's note" },
    {
      "<leader>oj",
      function()
        goto_daily(1)
      end,
      desc = "Next daily note",
    },
    {
      "<leader>ok",
      function()
        goto_daily(-1)
      end,
      desc = "Previous daily note",
    },

    -- scratch notes
    { "<leader>on", new_project_scratch_note, desc = "New project scratch note" },
    { "<leader>ol", open_last_project_scratch_note, desc = "Open last project scratch note" },
    { "<leader>os", search_project_scratch_notes, desc = "Search project scratch notes" },

    -- general obsidian
    { "<leader>ox", open_vault_explorer, desc = "Explore notes" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch notes" },
    { "<leader>of", "<cmd>Obsidian search<cr>", desc = "Search notes" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show backlinks" },
    { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian app" },
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image from clipboard" },
    {
      "<leader>oc",
      function()
        vim.ui.input({ prompt = "New note title: " }, function(input)
          if input and input ~= "" then
            vim.cmd("Obsidian new " .. vim.fn.fnameescape(input))
          end
        end)
      end,
      desc = "New note in current dir",
    },
    { "<leader>om", new_root_note, desc = "New note in vault root" },
    { "<leader>ol", ":Obsidian link<cr>", mode = "v", desc = "Link selected text" },
    { "<leader>oL", ":Obsidian link_new<cr>", mode = "v", desc = "Link to new note" },
    {
      "<leader>oe",
      function()
        vim.ui.input({ prompt = "New note title: " }, function(input)
          if input and input ~= "" then
            vim.cmd("Obsidian extract_note " .. vim.fn.fnameescape(input))
          end
        end)
      end,
      mode = "v",
      desc = "Extract to new note",
    },
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "main",
        path = vault_path,
      },
    },
    notes_subdir = nil,
    daily_notes = {
      folder = daily_notes_folder,
      date_format = daily_notes_date_format,
      alias_format = "%B %-d, %Y",
      template = "dailynotetemplate.md",
      default_tags = { "daily-notes" },
      workdays_only = false,
    },
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 4,
    },
    new_notes_location = "current_dir",
    open_notes_in = "current",
    note_id_func = function(title, dir)
      local daily_notes_dir = Obsidian.dir / Obsidian.opts.daily_notes.folder
      if daily_notes_dir == dir then
        return title
      end
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return os.date("%Y%m%d%H%M") .. "-" .. suffix
    end,
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
      substitutions = {
        yesterday_link = function(ctx)
          return daily_link(ctx, -1, "Yesterday")
        end,
        tomorrow_link = function(ctx)
          return daily_link(ctx, 1, "Tomorrow")
        end,
      },
    },
    picker = { name = "fzf-lua" },
    ui = { enable = false },
    footer = {
      enabled = false,
    },
    checkbox = { order = { " ", "x" } },
    attachments = {
      folder = "assets/imgs",
      img_name_func = function()
        return string.format("Pasted image %s", os.date("%Y%m%d%H%M%S"))
      end,
      confirm_img_paste = true,
    },
    frontmatter = {
      enabled = false,
    },
    link = {
      style = "wiki",
    },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)
    require("config.obsidian_calendar").setup({
      vault_path = vault_path,
      daily_notes_folder = daily_notes_folder,
      daily_notes_date_format = daily_notes_date_format,
      calendar_folder = calendar_folder,
      on_attach = attach_calendar_mappings,
    })
    setup_daily_mentions()
  end,
}
