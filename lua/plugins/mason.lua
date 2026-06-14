return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "lua-language-server",
          "pyright",
          "roslyn-language-server",
          "typescript-language-server",
          "rust-analyzer",
          "gopls",
          "clangd",
          "bash-language-server",
          "json-lsp",
          "yaml-language-server",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
}
