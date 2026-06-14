return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "q", group = "edit" },
    },
    triggers = {
      { "<auto>", mode = "nixsotc" },
      { "q", mode = { "n", "v" } },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
