vim.g.mapleader = "\\"

-- dotnet global tools (~/.dotnet/tools) are often missing from GUI/Cursor PATH
local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
if vim.fn.isdirectory(dotnet_tools) == 1 and not vim.env.PATH:find(dotnet_tools, 1, true) then
  vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
end

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.clipboard = "unnamedplus"

require("config.lazy")
require("config.lsp")

vim.keymap.set("n", "<leader>r", function()
  dofile(vim.env.MYVIMRC)
end, { desc = "Reload config" })
