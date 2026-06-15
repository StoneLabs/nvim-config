return {
  "nvim-pack/nvim-spectre",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    {
      "<leader>r",
      function()
        require("spectre").open()
      end,
      desc = "Search and replace in files",
    },
  },
}
