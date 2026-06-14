-- q* = editing (g* = inspect / navigate)

local api = require("Comment.api")

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
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
map("n", "qc", comment_line, "Comment line")
map("n", "qb", comment_block, "Comment block")
map("v", "qc", function()
  comment_visual("linewise")
end, "Comment line")
map("v", "qb", function()
  comment_visual("blockwise")
end, "Comment block")
map("n", "<C-_>", comment_line, "Comment line")
map("v", "<C-_>", function()
  comment_visual("linewise")
end, "Comment line")

-- LSP edit
map("n", "qa", function()
  require("tiny-code-action").code_action()
end, "Code action")
map("n", "qx", function()
  require("tiny-code-action").code_action({ context = { only = { "quickfix" } } })
end, "Quick fix")
map("n", "qr", vim.lsp.buf.rename, "Rename symbol")
map("n", "qo", function()
  require("tiny-code-action").code_action({ context = { only = { "source.organizeImports" } } })
end, "Organize imports")
map("n", "qf", function()
  vim.lsp.buf.format({ async = true, timeout_ms = 3000 })
end, "Format buffer")
map("n", "ql", function()
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
map("v", "qs", function()
  vim.lsp.buf.format({ async = true, timeout_ms = 3000 })
end, "Format selection")

-- Line ops
map("n", "qd", "<cmd>copy .<cr>", "Duplicate line")
map("n", "qk", "dd", "Delete line")
map("n", "qj", "J", "Join lines")
map("v", "qj", "J", "Join selection")
map("n", "qJ", "<cmd>m+1<cr>", "Move line down")
map("n", "qK", "<cmd>m-2<cr>", "Move line up")

-- Indent
map("n", "q>", ">>", "Indent line")
map("n", "q<", "<<", "Outdent line")
map("v", "q>", ">gv", "Indent selection")
map("v", "q<", "<gv", "Outdent selection")

-- Cleanup
map("n", "qw", function()
  vim.cmd([[%s/\s\+$//e]])
end, "Trim trailing whitespace")

-- which-key replays q* via feedkeys; locked comment + pre_hook avoids silent fail
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    require("which-key").add({
      { "q", group = "edit" },
    })
  end,
})
