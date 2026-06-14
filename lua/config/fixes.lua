-- dotnet global tools (~/.dotnet/tools) are often missing from GUI/Cursor PATH
local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
if vim.fn.isdirectory(dotnet_tools) == 1 and not vim.env.PATH:find(dotnet_tools, 1, true) then
  vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
end

