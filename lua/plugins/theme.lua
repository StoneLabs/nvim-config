return {
  "EdenEast/nightfox.nvim",
  priority = 1000,
  config = function()
    local colors = {
      keyword = "#C586C0",
      type = "#D7BA7D",
      method = "#61AFEF",
      variable = "#D4D4D4",
      field = "#D16969",
      string = "#98C379",
      number = "#D19A66",
      param_label = "#7A8CA5",
      operator = "#ABB2BF",
      comment = "#6A9955",
      search_bg = "#3d4f6a",
      indent = "#353535",
      indent_active = "#505050",
    }

    require("nightfox").setup({
      palettes = {
        carbonfox = {
          comment = colors.comment,
        },
      },
      specs = {
        carbonfox = {
          syntax = {
            keyword = colors.keyword,
            conditional = colors.keyword,
            statement = colors.keyword,
            type = colors.type,
            func = colors.method,
            variable = colors.variable,
            ident = colors.variable,
            field = colors.field,
            string = colors.string,
            number = colors.number,
            operator = colors.operator,
            bracket = colors.operator,
            comment = colors.comment,
            builtin0 = colors.variable,
            builtin1 = colors.type,
            builtin2 = colors.number,
            const = colors.number,
          },
        },
      },
      groups = {
        carbonfox = {
          StorageClass = { fg = colors.keyword },
          Identifier = { fg = colors.variable },

          Search = { fg = colors.field, bg = colors.search_bg, sp = colors.method },
          IncSearch = { fg = colors.field, bg = colors.search_bg, sp = colors.method },
          CurSearch = { link = "IncSearch" },

          ["@keyword"] = { fg = colors.keyword },
          ["@keyword.storage"] = { fg = colors.keyword },
          ["@keyword.return"] = { fg = colors.keyword },
          ["@keyword.function"] = { fg = colors.keyword },

          ["@type"] = { fg = colors.type },
          ["@type.builtin"] = { fg = colors.type },
          ["@lsp.type.class"] = { fg = colors.type },
          ["@lsp.type.struct"] = { fg = colors.type },
          ["@lsp.type.enum"] = { fg = colors.type },
          ["@lsp.type.interface"] = { fg = colors.type },
          ["@lsp.type.type"] = { fg = colors.type },
          ["@lsp.type.typeAlias"] = { fg = colors.type },
          ["@lsp.type.namespace"] = { fg = colors.type },

          ["@function"] = { fg = colors.method },
          ["@function.call"] = { fg = colors.method },
          ["@function.method"] = { fg = colors.method },
          ["@function.method.call"] = { fg = colors.method },
          ["@method"] = { fg = colors.method },
          ["@method.call"] = { fg = colors.method },
          ["@lsp.type.method"] = { fg = colors.method },
          ["@lsp.type.function"] = { fg = colors.method },

          ["@variable"] = { fg = colors.variable },
          ["@variable.parameter"] = { fg = colors.variable },
          ["@lsp.type.variable"] = { fg = colors.variable },
          ["@lsp.type.parameter"] = { fg = colors.variable },

          ["@variable.member"] = { fg = colors.field },
          ["@property"] = { fg = colors.field },
          ["@lsp.type.property"] = { fg = colors.field },

          ["@label"] = { fg = colors.param_label },
          ["@label.json"] = { fg = colors.param_label },

          ["@string"] = { fg = colors.string },
          ["@lsp.type.string"] = { fg = colors.string },

          ["@number"] = { fg = colors.number },
          ["@lsp.type.number"] = { fg = colors.number },

          ["@operator"] = { fg = colors.operator },
          ["@punctuation.delimiter"] = { fg = colors.operator },
          ["@punctuation.bracket"] = { fg = colors.operator },
          ["@lsp.type.operator"] = { fg = colors.operator },

          IndentBlanklineChar = { fg = colors.indent },
          IndentBlanklineContextChar = { fg = colors.indent_active },
        },
      },
    })

    vim.cmd.colorscheme("carbonfox")
  end,
}
