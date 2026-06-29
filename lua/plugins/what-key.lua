return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>k", group = "Comment" },
      { "<leader>f", group = "Find" },
      { "<leader>h", group = "Hunks" },
      { "<leader>w", group = "Workspace" },
      { "<leader>q", group = "quickfix" },
      { "<leader>d", group = "Diagnostics" },
      { "<leader>c", group = "Compile" },
      { "<leader>g", group = "Git" },
    },
    triggers = {
      { "<auto>", mode = "nixsotc" },
      { "<leader>k", mode = { "n", "v" } },
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
