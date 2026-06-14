return {
  "numToStr/Comment.nvim",
  lazy = false,
  opts = {
    padding = true,
    sticky = true,
    mappings = {
      basic = false,
      extra = false,
    },
    pre_hook = function(ctx)
      local cstr = vim.bo.commentstring
      if cstr and cstr ~= "" and cstr:find("%%s") then
        return cstr
      end

      local ft = require("Comment.ft")
      local U = require("Comment.utils")
      local lang = vim.bo.filetype:match("([^%.]+)$") or vim.bo.filetype

      return ft.get(lang, ctx.ctype)
        or ft.get(vim.bo.filetype, ctx.ctype)
        or (ctx.ctype == U.ctype.linewise and "//%s" or "/*%s*/")
    end,
  },
}
