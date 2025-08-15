return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      win = {
        position = "float",
      },
    },
  },
  image = {
    resolve = function(path, src)
      if require("obsidian.api").path_is_note(path) then
        return require("obsidian.api").resolve_image_path(src)
      end
    end,
  },
}
