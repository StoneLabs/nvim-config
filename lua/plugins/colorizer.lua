return {
  "catgoose/nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    filetypes = {
      css = { mode = "background" },
      scss = { mode = "background" },
      less = { mode = "background" },
    },
  },
}
