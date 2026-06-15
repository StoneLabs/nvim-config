local M = {}

local QF_HEIGHT = 12

function M.open()
  if #vim.fn.getqflist() == 0 then
    return
  end
  vim.cmd("botright copen " .. QF_HEIGHT)
end

function M.toggle()
  if vim.fn.getqflistwinid() ~= 0 then
    vim.cmd("cclose")
  else
    M.open()
  end
end

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

map("<leader>dq", function()
  vim.diagnostic.setqflist()
  M.open()
end, "Diagnostics → quickfix")

map("<leader>qq", M.toggle, "Toggle quickfix")

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

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    require("which-key").add({
      { "<leader>q", group = "quickfix" },
    })
  end,
})

return M
