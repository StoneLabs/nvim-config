vim.g.mapleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.clipboard = "unnamedplus"

require("config.lazy")

vim.keymap.set("n", "<leader>r", function()
  dofile(vim.env.MYVIMRC)
end, { desc = "Reload config" })
