local mason_netcoredbg = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"

return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "csproj", "sln", "slnx", "props", "csx", "targets" },
    cmd = "Dotnet",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        "<leader>cr",
        function()
          require("easy-dotnet").run_default()
        end,
        desc = "Run .NET project",
      },
      {
        "<leader>cb",
        function()
          require("easy-dotnet").build_default()
        end,
        desc = "Build .NET project",
      },
      {
        "<leader>cd",
        function()
          require("easy-dotnet").debug_default()
        end,
        desc = "Debug .NET project",
      },
      {
        "<leader>ct",
        function()
          require("easy-dotnet").testrunner()
        end,
        desc = "Toggle .NET test runner",
      },
      {
        "<leader>cs",
        function()
          require("easy-dotnet").stop()
        end,
        desc = "Stop .NET run/debug session",
      },
    },
    config = function(_, opts)
      require("dap-view")
      require("easy-dotnet").setup(opts)
    end,
    opts = {
      picker = "telescope",
      lsp = {
        enabled = false, -- keep roslyn_ls from config/lsp.lua + Mason
      },
      debugger = {
        auto_register_dap = true,
        bin_path = vim.fn.executable(mason_netcoredbg) == 1 and mason_netcoredbg or nil,
        engine = "netcoredbg",
        console = "integratedTerminal",
      },
    },
  },
}
