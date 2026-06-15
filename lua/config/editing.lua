-- <leader>k* = code (g* = inspect / navigate)

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

-- Comment
kmap("n", "c", comment_line, "Comment line")
kmap("n", "b", comment_block, "Comment block")
kmap("v", "c", function()
  comment_visual("linewise")
end, "Comment line")
kmap("v", "b", function()
  comment_visual("blockwise")
end, "Comment block")
map("n", "<C-_>", comment_line, "Comment line")
map("v", "<C-_>", function()
  comment_visual("linewise")
end, "Comment line")

-- LSP edit
kmap("n", "a", function()
  require("tiny-code-action").code_action()
end, "Code action")
kmap("n", "x", function()
  require("tiny-code-action").code_action({ context = { only = { "quickfix" } } })
end, "Quick fix")
kmap("n", "r", vim.lsp.buf.rename, "Rename symbol")
kmap("n", "o", function()
  require("tiny-code-action").code_action({ context = { only = { "source.organizeImports" } } })
end, "Organize imports")
kmap("n", "f", function()
  vim.lsp.buf.format({ async = true, timeout_ms = 3000 })
end, "Format buffer")
kmap("n", "l", function()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.lsp.buf.format({
    async = true,
    timeout_ms = 3000,
    range = {
      start = { line = row, character = 0 },
      ["end"] = { line = row, character = 999 },
    },
  })
end, "Format line")
kmap("v", "s", function()
  vim.lsp.buf.format({ async = true, timeout_ms = 3000 })
end, "Format selection")

-- Line ops
kmap("n", "d", "<cmd>copy .<cr>", "Duplicate line")
kmap("n", "k", "dd", "Delete line")
kmap("n", "j", "J", "Join lines")
kmap("v", "j", "J", "Join selection")
kmap("n", "J", "<cmd>m+1<cr>", "Move line down")
kmap("n", "K", "<cmd>m-2<cr>", "Move line up")

-- Indent
kmap("n", ">", ">>", "Indent line")
kmap("n", "<", "<<", "Outdent line")
kmap("v", ">", ">gv", "Indent selection")
kmap("v", "<", "<gv", "Outdent selection")

-- Cleanup
kmap("n", "w", function()
  vim.cmd([[%s/\s\+$//e]])
end, "Trim trailing whitespace")
