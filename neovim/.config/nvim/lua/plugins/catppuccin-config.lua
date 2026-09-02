require("catppuccin").setup({
        flavour = "macchiato", -- latte, frappe, macchiato, mocha
        transparent_background = false,
        integrations = {
                nvimtree = true,
                treesitter = true,
                ts_rainbow2 = true,
                cmp = true,
                gitsigns = true,
                bufferline = true,
                telescope = {
                        enabled = true,
                }
        },
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"
