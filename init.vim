call plug#begin()

Plug 'EdenEast/nightfox.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" ^-- :TSInstall <language_to_install> 

Plug 'williamboman/mason.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'ms-jpq/coq_nvim'
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
Plug 'ms-jpq/coq.thirdparty', {'branch': '3p'}
Plug 'iabdelkareem/csharp.nvim'

"Plug 'nvim-lua/completion-nvim'
Plug 'ziglang/zig.vim'

call plug#end()

" Plugin setups
:lua << EOF
	require("mason").setup()
EOF

" LSP

:lua << EOF
    local lspconfig = require('lspconfig')

    local on_attach = function(_, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    end

    local servers = {'zls', 'pyright'} -- Add 'pyright' for Python LSP
    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
            on_attach = on_attach,
        }
    end
EOF

" treesitter
:lua << EOF
    require('nvim-treesitter.configs').setup {
        -- List of parsers to install
        ensure_installed = { "python", "lua", "javascript", "html", "css" },

        -- Enable highlighting
        highlight = {
            enable = true,              -- Enable Treesitter highlighting
            additional_vim_regex_highlighting = false, -- Disable default Vim highlighting
        },
    }
EOF

" Options
:lua << EOF
	vim.opt.relativenumber = true
EOF

" Keybinds
:lua << EOF
	local builtin = require('telescope.builtin')
	vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
	vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
	vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
	vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
EOF

:lua << EOF
    vim.cmd('colorscheme carbonfox')
EOF
