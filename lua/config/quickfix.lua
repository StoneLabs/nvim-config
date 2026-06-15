local M = {}

local QF_HEIGHT = 12

local function qf_winid()
  return vim.fn.getqflist({ winid = 0 }).winid
end

function M.open()
  if #vim.fn.getqflist() == 0 then
    return
  end
  vim.cmd("botright copen " .. QF_HEIGHT)
end

function M.open_or_jump()
  if #vim.fn.getqflist() == 0 then
    return
  end

  local winid = qf_winid()
  if winid == 0 then
    vim.cmd("botright copen " .. QF_HEIGHT)
    winid = qf_winid()
  end

  if winid ~= 0 then
    vim.api.nvim_set_current_win(winid)
  end
end

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

map("<leader>qp", function()
  vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
  M.open()
end, "Populate quickfix with errors")

map("<leader>qq", M.open_or_jump, "Open or jump to quickfix")

map("<leader>qc", function()
  vim.cmd("cclose")
end, "Close quickfix")

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "[^l]*",
  callback = function()
    vim.schedule(function()
      if #vim.fn.getqflist() > 0 then
        M.open()
      end
    end)
  end,
})

return M
