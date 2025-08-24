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
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "text", "tex", "plaintex", "norg" },
      callback = function(ev)
        set_autolist_keymaps(ev.buf)
      end,
    })
  end,
}
