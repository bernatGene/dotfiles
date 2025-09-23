-- ~/.config/nvim/lua/plugins/obsidian.lua
local wk = require("which-key")
wk.add({
  { "<leader>o", group = "obsidian", desc = "obsidian", icon = { icon = "󰇈", color = "purple" } },
})

local function open_vault_explorer()
  local vault = "/Users/bernatskrabec/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault"
  require("snacks.explorer").open({
    cwd = vault,
  })
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
  require("telescope.builtin").find_files({
    prompt_title = "Project Scratch Notes - " .. project_name,
    cwd = scratch_dir,
    search_file = "*.md",
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
  local date = os.date(ctx.template_opts.date_format, t + offset * 86400)
  return string.format("[[dailynote/%s|%s]]", date, label)
end

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "saghen/blink.cmp",
    "folke/snacks.nvim",
  },
  keys = {
    -- daily notes
    { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Open daily note" },
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
    { "<leader>ox", open_vault_explorer, desc = "Quick switch notes" },
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
    workspaces = {
      {
        name = "main",
        path = "/Users/bernatskrabec/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault",
      },
    },
    notes_subdir = nil,
    daily_notes = {
      folder = "dailynote",
      date_format = "%Y-%m-%d-%a",
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
    note_id_func = function(title)
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
    picker = { name = "telescope.nvim" },
    ui = { enable = false },
    footer = {
      enabled = false,
    },
    checkbox = { order = { " ", "x" } },
    attachments = {
      img_folder = "assets/imgs",
      img_name_func = function()
        return string.format("Pasted image %s", os.date("%Y%m%d%H%M%S"))
      end,
      confirm_img_paste = true,
    },
    disable_frontmatter = true,
    preferred_link_style = "wiki",
  },
}
