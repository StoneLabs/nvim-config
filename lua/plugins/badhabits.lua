return {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
        disabled_keys = {
             ["<C-Up>"] = { "n", "x", "i" },
             ["<C-Down>"] = { "n", "x", "i" },
        },
    }
}
