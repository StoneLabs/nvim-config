call plug#begin()

Plug 'EdenEast/nightfox.nvim'
Plug 'rebelot/kanagawa.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'chrisbra/csv.vim'
Plug 'williamboman/mason.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'ms-jpq/coq_nvim'
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
Plug 'ms-jpq/coq.thirdparty', {'branch': '3p'}
Plug 'iabdelkareem/csharp.nvim'
Plug 'Tastyep/structlog.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', {'branch': 'v3.x'}
Plug 'MunifTanjim/nui.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'mfussenegger/nvim-dap'
Plug 'ziglang/zig.vim'
Plug 'Zeioth/compiler.nvim'
Plug 'stevearc/overseer.nvim'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'rcarriga/nvim-notify'
Plug 'stevearc/dressing.nvim'
Plug 'nvim-neotest/nvim-nio'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'folke/which-key.nvim'

call plug#end()

" ─────────────────────────────────────────────
" Leader (must be set before which-key and keymaps)
" ─────────────────────────────────────────────
:lua << EOF
vim.g.mapleader = "\\"
EOF

" ─────────────────────────────────────────────
" COQ (must be set before any require('coq'))
" ─────────────────────────────────────────────
:lua << EOF
vim.g.coq_settings = { auto_start = 'shut-up' }
EOF

" ─────────────────────────────────────────────
" Core plugin setups
" ─────────────────────────────────────────────
:lua << EOF
require("compiler").setup()
require("mason").setup()
require("gitsigns").setup()
require("which-key").setup()

require("neo-tree").setup({
    filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_default",
        filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_by_name = {
                "*.uid",
            },
        },
    },
    default_component_configs = {
        icon = {
            folder_closed = "",
            folder_open = "",
        },
    },
})
EOF

" ─────────────────────────────────────────────
" Notifications + Dressing (UI polish)
" ─────────────────────────────────────────────
:lua << EOF
vim.notify = require("notify")
require("dressing").setup()
EOF

" ─────────────────────────────────────────────
" Overseer + Compiler
" ─────────────────────────────────────────────
:lua << EOF
require("overseer").setup({
    task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
    },
})

vim.keymap.set('n', '<F6>',  '<cmd>CompilerOpen<cr>',                          { noremap = true, silent = true, desc = "Compiler: Open" })
vim.keymap.set('n', '<S-F6>', function()
    vim.cmd('CompilerStop')
    vim.cmd('CompilerRedo')
end,                                                                            { noremap = true, silent = true, desc = "Compiler: Stop & redo" })
vim.keymap.set('n', '<S-F7>', '<cmd>CompilerToggleResults<cr>',                { noremap = true, silent = true, desc = "Compiler: Toggle results" })
EOF

" ─────────────────────────────────────────────
" LSP
" Uses vim.lsp.config/enable (nvim 0.11+ native API).
" nvim-lspconfig is kept for its server definitions but NOT called as a
" framework — no require('lspconfig').X.setup() anywhere.
" Keymaps are set once via LspAttach autocmd (fires for every server).
" COQ capabilities injected globally via vim.lsp.config('*', ...).
" ─────────────────────────────────────────────
:lua << EOF
local coq = require('coq')

-- Inject COQ capabilities and a global root marker for all servers
vim.lsp.config('*', {
    capabilities = coq.lsp_ensure_capabilities({}).capabilities,
    root_markers = { '.git' },
})

-- LSP keymaps — fires once per buffer when any server attaches
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local opts = { noremap = true, silent = true, buffer = ev.buf }
        vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,    vim.tbl_extend('force', opts, { desc = "LSP: Go to definition" }))
        vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,   vim.tbl_extend('force', opts, { desc = "LSP: Go to declaration" }))
        vim.keymap.set('n', 'gr',         vim.lsp.buf.references,    vim.tbl_extend('force', opts, { desc = "LSP: References" }))
        vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation,vim.tbl_extend('force', opts, { desc = "LSP: Implementation" }))
        vim.keymap.set('n', 'K',          vim.lsp.buf.hover,         vim.tbl_extend('force', opts, { desc = "LSP: Hover docs" }))
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,        vim.tbl_extend('force', opts, { desc = "LSP: Rename" }))
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,   vim.tbl_extend('force', opts, { desc = "LSP: Code action" }))
        vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = "LSP: Show diagnostic" }))
        vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,  vim.tbl_extend('force', opts, { desc = "LSP: Prev diagnostic" }))
        vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,  vim.tbl_extend('force', opts, { desc = "LSP: Next diagnostic" }))
    end,
})



vim.lsp.enable({ 'zls', 'pyright'})
EOF

" ─────────────────────────────────────────────
" Treesitter
" ─────────────────────────────────────────────
:lua << EOF
require('nvim-treesitter').setup({
    ensure_installed = { "python", "lua", "javascript", "html", "css", "c_sharp" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})
EOF

" ─────────────────────────────────────────────
" DAP + DAP UI + Virtual Text
" ─────────────────────────────────────────────
:lua << EOF
local dap = require('dap')
local dapui = require("dapui")

-- netcoredbg installed via Mason
dap.adapters.coreclr = {
    type = 'executable',
    command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
    args = { '--interpreter=vscode' },
}

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "Launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
    },
}

dapui.setup()
require("nvim-dap-virtual-text").setup()

-- Auto-open/close DAP UI with debug sessions
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

-- DAP keymaps
vim.keymap.set('n', '<F5>',       function() dap.continue() end,                                             { noremap = true, silent = true, desc = "DAP: Continue" })
vim.keymap.set('n', '<F10>',      function() dap.step_over() end,                                            { noremap = true, silent = true, desc = "DAP: Step over" })
vim.keymap.set('n', '<F11>',      function() dap.step_into() end,                                            { noremap = true, silent = true, desc = "DAP: Step into" })
vim.keymap.set('n', '<F12>',      function() dap.step_out() end,                                             { noremap = true, silent = true, desc = "DAP: Step out" })
vim.keymap.set('n', '<leader>b',  function() dap.toggle_breakpoint() end,                                    { noremap = true, silent = true, desc = "DAP: Toggle breakpoint" })
vim.keymap.set('n', '<leader>B',  function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { noremap = true, silent = true, desc = "DAP: Conditional breakpoint" })
vim.keymap.set('n', '<leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point: ')) end,  { noremap = true, silent = true, desc = "DAP: Log point" })
vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end,                                            { noremap = true, silent = true, desc = "DAP: Open REPL" })
vim.keymap.set('n', '<leader>du', function() dapui.toggle() end,                                             { noremap = true, silent = true, desc = "DAP: Toggle UI" })
EOF

" ─────────────────────────────────────────────
" csharp.nvim
" ─────────────────────────────────────────────
:lua << EOF
require("csharp").setup()
require("csharp").debug_project()
EOF
" ─────────────────────────────────────────────
" Diagnostics
" ─────────────────────────────────────────────
:lua << EOF
vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        prefix = "■",
    },
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = true,
})
EOF

" ─────────────────────────────────────────────
" Telescope keymaps
" ─────────────────────────────────────────────
:lua << EOF
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files,        { desc = "Find: Files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep,         { desc = "Find: Grep" })
vim.keymap.set('n', '<leader>fb', builtin.buffers,           { desc = "Find: Buffers" })
vim.keymap.set('n', '<leader>fh', builtin.help_tags,         { desc = "Find: Help" })
vim.keymap.set('n', '<leader>e',  '<cmd>Neotree toggle<CR>', { noremap = true, silent = true, desc = "Toggle file tree" })
EOF

" ─────────────────────────────────────────────
" which-key group labels (shows in popup)
" ─────────────────────────────────────────────
:lua << EOF
local wk = require("which-key")
wk.add({
    { "<leader>f",  group = "Find (Telescope)" },
    { "<leader>d",  group = "Debug" },
    { "<leader>l",  group = "LSP" },
    { "<leader>b",  desc  = "DAP: Toggle breakpoint" },
    { "<leader>B",  desc  = "DAP: Conditional breakpoint" },
    { "<leader>e",  desc  = "Toggle file tree" },
    { "<leader>rn", desc  = "LSP: Rename" },
    { "<leader>ca", desc  = "LSP: Code action" },
})
EOF

" ─────────────────────────────────────────────
" Editor options
" ─────────────────────────────────────────────
:lua << EOF
-- Hybrid line numbers: absolute on current line, relative elsewhere
vim.opt.number         = true
vim.opt.relativenumber = true

vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true

-- Clipboard: sync with system clipboard (Ctrl-Shift-C/V in Kitty)
vim.opt.clipboard      = "unnamedplus"
EOF

" Allow Ctrl-W in terminal mode to switch windows
tnoremap <C-w> <C-\><C-o><C-w>

" ─────────────────────────────────────────────
" Colorscheme
" ─────────────────────────────────────────────
:lua << EOF
vim.cmd('colorscheme carbonfox')
EOF