local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 and not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.enable({
  "lua_ls",
  "pyright",
  "roslyn_ls",
  "ts_ls",
  "rust_analyzer",
  "gopls",
  "clangd",
  "bashls",
  "jsonls",
  "yamlls",
})

vim.diagnostic.config({ virtual_text = true })

local float_opts = { focusable = true }

local function peek_location(method)
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  vim.lsp.buf_request_all(bufnr, method, function(client)
    return vim.lsp.util.make_position_params(win, client.offset_encoding)
  end, function(results)
    local locations = {}

    for _, res in pairs(results) do
      if res and res.result then
        local locs = vim.islist(res.result) and res.result or { res.result }
        vim.list_extend(locations, locs)
      end
    end

    if #locations == 0 then
      vim.notify("No location found", vim.log.levels.INFO)
      return
    end

    local function preview(loc)
      vim.lsp.util.preview_location(loc, float_opts)
    end

    if #locations == 1 then
      preview(locations[1])
      return
    end

    vim.ui.select(locations, {
      prompt = "Peek location",
      format_item = function(loc)
        return vim.fn.fnamemodify(vim.uri_to_fname(loc.uri or loc.targetUri), ":t")
      end,
    }, preview)
  end)
end

local augroup = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.name == "roslyn_ls" then
      local bufnr = event.buf
      local function pull_diagnostics()
        client:request(
          vim.lsp.protocol.Methods.textDocument_diagnostic,
          { textDocument = vim.lsp.util.make_text_document_params(bufnr) },
          nil,
          bufnr
        )
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        group = augroup,
        buffer = bufnr,
        callback = pull_diagnostics,
      })
      pull_diagnostics()
    end

    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
    end

    local tb = require("telescope.builtin")

    map("gd", tb.lsp_definitions, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gr", tb.lsp_references, "Go to references")
    map("gi", tb.lsp_implementations, "Go to implementation")
    map("gt", tb.lsp_type_definitions, "Go to type definition")
    map("gpd", function()
      peek_location("textDocument/definition")
    end, "Peek definition")
    map("gpD", function()
      peek_location("textDocument/declaration")
    end, "Peek declaration")
    map("gpi", function()
      peek_location("textDocument/implementation")
    end, "Peek implementation")
    map("gpt", function()
      peek_location("textDocument/typeDefinition")
    end, "Peek type definition")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", function()
      require("tiny-code-action").code_action()
    end, "Code action")
    map("<leader>ds", tb.lsp_document_symbols, "Document symbols")
    map("<leader>ws", tb.lsp_workspace_symbols, "Workspace symbols")

    map("[d", function()
      vim.diagnostic.jump({ count = -1 })
    end, "Previous diagnostic")
    map("]d", function()
      vim.diagnostic.jump({ count = 1 })
    end, "Next diagnostic")
  end,
})
