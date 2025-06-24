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
Plug 'nvim-neo-tree/neo-tree.nvim', {'branch': 'v3.x'}
Plug 'MunifTanjim/nui.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'mfussenegger/nvim-dap'
Plug 'ziglang/zig.vim'
Plug 'Zeioth/compiler.nvim'
Plug 'stevearc/overseer.nvim'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" Add DAP UI and Virtual Text Plugins
Plug 'nvim-neotest/nvim-nio'
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'

call plug#end()

" Plugin setups
:lua << EOF
require("compiler").setup()
require("mason").setup()
require("gitsigns").setup()
require("neo-tree").setup({
    filesystem = {
        follow_current_file = true,
        hijack_netrw = true,
    },
    default_component_configs = {
        icon = {
            folder_closed = "",
            folder_open = "",
        },
    },
})
EOF

" Compiler and Overseer Setup
:lua << EOF
require("overseer").setup({
    task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1
    },
})
EOF

" Compiler Key Mappings
:lua << EOF
vim.api.nvim_set_keymap('n', '<F6>', "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-F6>',
     "<cmd>CompilerStop<cr>" .. "<cmd>CompilerRedo<cr>",
 { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-F7>', "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })
EOF

" LSP
:lua << EOF
local lspconfig = require('lspconfig')
local coq = require('coq') -- Ensure COQ integration

local on_attach = function(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

local servers = {'zls', 'pyright'} 
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup(coq.lsp_ensure_capabilities({
        on_attach = on_attach,
    }))
end

-- Omnisharp
lspconfig.omnisharp.setup(coq.lsp_ensure_capabilities({
    cmd = { "omnisharp" }, -- Mason installs OmniSharp with this name by default
    root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj"),

    enable_import_completion = true,
    organize_imports_on_format = true,
    enable_roslyn_analyzers = true,

    capabilities = vim.lsp.protocol.make_client_capabilities(),
}))
EOF

" Treesitter
:lua << EOF
require('nvim-treesitter.configs').setup {
    ensure_installed = { "python", "lua", "javascript", "html", "css", "c_sharp" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}
EOF

" DAP Setup
:lua << EOF
local dap = require('dap')

-- Adapter configuration
dap.adapters.coreclr = {
    type = 'executable',
    --command = '/opt/netcoredbg/netcoredbg', -- Adjusted path for netcoredbg
    args = {'--interpreter=vscode'},
}

-- Launch configuration
dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
    },
}

-- DAP UI setup
local dapui = require("dapui")
dapui.setup()

-- DAP Virtual Text setup
require("nvim-dap-virtual-text").setup()

-- Key Mappings for DAP
vim.keymap.set('n', '<F5>', function() dap.continue() end, { noremap = true, silent = true })
vim.keymap.set('n', '<F10>', function() dap.step_over() end, { noremap = true, silent = true })
vim.keymap.set('n', '<F11>', function() dap.step_into() end, { noremap = true, silent = true })
vim.keymap.set('n', '<F12>', function() dap.step_out() end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>du', function() dapui.toggle() end, { noremap = true, silent = true })
EOF

" Keybinds
:lua << EOF
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>e', ':NeoTreeShowToggle<CR>', { noremap = true, silent = true })
EOF

" Options
:lua << EOF
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
EOF
tnoremap <C-w> <C-\><C-o><C-w>

" Colorscheme
:lua << EOF
vim.cmd('colorscheme carbonfox')
EOF
