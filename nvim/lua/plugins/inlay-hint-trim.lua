return {
  "ray-d-song/inlay-hint-trim.nvim",
  config = function()
    require("inlay-hint-trim").setup({
      clients = {
        ["typescript-tools"] = true,
        ["tsserver"] = true,
        ["ts_ls"] = true,
        ["svelte"] = false,
      },
    })
  end,
}
