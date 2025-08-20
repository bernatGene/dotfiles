-- ~/.config/nvim/lua/plugins/obsidian.lua
local wk = require("which-key")
wk.add({
  { "<leader>o", group = "obsidian", desc = "obsidian", icon = { icon = "󰇈", color = "purple" } },
})

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for file system operations
    "nvim-telescope/telescope.nvim",
    "saghen/blink.cmp", -- Your completion engine
    "folke/snacks.nvim", -- For image viewing
  },
  keys = {
    -- Daily notes
    { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Open daily note" },
    { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Open yesterday's note" },
    { "<leader>ot", "<cmd>Obsidian tomorrow<cr>", desc = "Open tomorrow's note" },

    -- Project scratch notes (custom functions)
    {
      "<leader>on",
      function()
        local workspace = Obsidian.workspace
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        local scratch_dir = workspace.path.filename .. "/" .. project_name

        vim.fn.mkdir(scratch_dir, "p")

        local timestamp = os.time()
        local note_name = timestamp .. "_note.md"
        local note_path = scratch_dir .. "/" .. note_name

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
      end,
      desc = "New project scratch note",
    },

    {
      "<leader>ol",
      function()
        local workspace = Obsidian.workspace
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        local scratch_dir = workspace.path.filename .. "/" .. project_name

        if vim.fn.isdirectory(scratch_dir) == 0 then
          vim.notify("No scratch notes directory for project: " .. project_name, vim.log.levels.WARN)
          return
        end

        local notes = {}

        for name, type in vim.fs.dir(scratch_dir) do
          if type == "file" and name:match("%.md$") and name:match("^%d+_note%.md$") then
            local timestamp = tonumber(name:match("^(%d+)_note%.md$"))
            if timestamp then
              table.insert(notes, {
                file = scratch_dir .. "/" .. name,
                timestamp = timestamp,
              })
            end
          end
        end

        if #notes == 0 then
          vim.notify("No scratch notes found for project: " .. project_name, vim.log.levels.WARN)
          return
        end

        table.sort(notes, function(a, b)
          return a.timestamp > b.timestamp
        end)
        vim.cmd("edit " .. vim.fn.fnameescape(notes[1].file))
      end,
      desc = "Open last project scratch note",
    },

    {
      "<leader>os",
      function()
        local workspace = Obsidian.workspace
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        local scratch_dir = workspace.path.filename .. "/" .. project_name

        if vim.fn.isdirectory(scratch_dir) == 0 then
          vim.notify("No scratch notes directory for project: " .. project_name, vim.log.levels.WARN)
          return
        end

        require("telescope.builtin").find_files({
          prompt_title = "Project Scratch Notes - " .. project_name,
          cwd = scratch_dir,
          search_file = "*.md",
        })
      end,
      desc = "Search project scratch notes",
    },

    -- Standard obsidian commands
    { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch notes" },
    { "<leader>of", "<cmd>Obsidian search<cr>", desc = "Search notes" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show backlinks" },
    { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian app" },
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image from clipboard" },

    -- Link operations (visual mode)
    { "<leader>ol", ":Obsidian link<cr>", mode = "v", desc = "Link selected text" },
    { "<leader>oL", ":Obsidian link_new<cr>", mode = "v", desc = "Link to new note" },
  },
  opts = {
    workspaces = {
      {
        name = "main",
        path = "/Users/bernatskrabec/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault", -- Adjust path
      },
    },

    notes_subdir = nil,

    daily_notes = {
      folder = "dailynote",
      date_format = "%Y-%m-%d-%a", -- e.g. 2023-12-14-Thu
      alias_format = "%B %-d, %Y",
      template = "dailynotetemplate.md",
      default_tags = { "daily-notes" },
    },

    completion = {
      nvim_cmp = false, -- Disable nvim-cmp
      blink = true, -- Enable blink.cmp
      min_chars = 2,
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
      return tostring(os.time()) .. "_" .. suffix
    end,

    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    picker = {
      name = "telescope.nvim",
    },

    -- Disable UI concealing
    ui = {
      enable = false,
    },

    -- Image attachments configuration
    attachments = {
      img_folder = "assets/imgs", -- Save images to assets/imgs folder
      img_name_func = function()
        return string.format("Pasted image %s", os.date("%Y%m%d%H%M%S"))
      end,
      confirm_img_paste = true,
    },

    disable_frontmatter = true,
    preferred_link_style = "wiki",
  },
}
