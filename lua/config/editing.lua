local api = require("Comment.api")

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

local function kmap(mode, key, rhs, desc)
  map(mode, "<leader>k" .. key, rhs, desc)
end

local function comment_line()
  api.locked("toggle.linewise.current")()
end

local function comment_block()
  api.locked("toggle.blockwise.current")()
end

local function comment_visual(ctype)
  local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  api.locked("toggle." .. ctype)(vim.fn.visualmode())
end

kmap("n", "c", comment_line, "Comment line")
kmap("n", "b", comment_block, "Comment block")
kmap("v", "c", function()
  comment_visual("linewise")
end, "Comment line")
kmap("v", "b", function()
  comment_visual("blockwise")
end, "Comment block")
kmap("n", "a", function()
  require("tiny-code-action").code_action()
end, "Code action")
kmap("n", "o", function()
  require("tiny-code-action").code_action({ context = { only = { "source.organizeImports" } } })
end, "Organize imports")
kmap("n", "r", vim.lsp.buf.rename, "Rename symbol")
map("n", "<C-_>", comment_line, "Comment line")
map("v", "<C-_>", function()
  comment_visual("linewise")
end, "Comment line")
