local mason_netcoredbg = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"

local function resolve_csproj(cb)
  local buf = vim.api.nvim_buf_get_name(0)
  if buf:match("%.csproj$") or buf:match("%.fsproj$") then
    cb(vim.fn.fnamemodify(buf, ":p"))
    return
  end

  if buf:match("%.cs$") or buf:match("%.fs$") then
    require("easy-dotnet.roslyn.root_finder").find_csproj_from_file(buf, cb)
    return
  end

  local active = require("easy-dotnet.active-project").get()
  if active.projectPath then
    cb(active.projectPath)
    return
  end

  cb(nil)
end

local function build_project(rebuild)
  resolve_csproj(function(csproj)
    if not csproj then
      vim.notify("No .csproj found for current buffer", vim.log.levels.ERROR)
      return
    end

    local dotnet = require("easy-dotnet")
    if rebuild then
      dotnet.build("/t:Rebuild")
    else
      dotnet.build()
    end
  end)
end

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
          require("easy-dotnet").run()
        end,
        desc = "Run .NET project",
      },
      {
        "<leader>cb",
        function()
          build_project(false)
        end,
        desc = "Build .NET project",
      },
      {
        "<leader>cB",
        function()
          require("easy-dotnet").build_solution()
        end,
        desc = "Build .NET solution",
      },
      {
        "<leader>cc",
        function()
          build_project(true)
        end,
        desc = "Clean build .NET project",
      },
      {
        "<leader>cC",
        function()
          require("easy-dotnet").build_solution("/t:Rebuild")
        end,
        desc = "Clean build .NET solution",
      },
      {
        "<leader>cd",
        function()
          require("easy-dotnet").debug()
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
