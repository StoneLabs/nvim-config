vim.g.mapleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.clipboard = "unnamedplus"

vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.opt.signcolumn = "yes"

vim.o.winborder = "single"

require("config.lazy")
require("config.fixes")
require("config.lsp")
require("config.editing")

vim.keymap.set("n", "<leader>r", function()
  dofile(vim.env.MYVIMRC)
end, { desc = "Reload config" })
