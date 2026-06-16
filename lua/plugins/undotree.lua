return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  config = function()
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_SplitWidth = 40
  end,
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
  },
}
