return {
    'nvim-telescope/telescope.nvim', version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    keys = function()
        local b = require("telescope.builtin")
        return {
            { "<leader>ff", b.find_files, desc = "Find files" },
            { "<leader>fg", b.live_grep,  desc = "Live grep" },
            { "<leader>fb", b.buffers,    desc = "Buffers" },
            { "<leader>fh", b.help_tags,  desc = "Help tags" },
        }
    end,
}
