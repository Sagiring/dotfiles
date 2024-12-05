require("catppuccin").setup({
        flavour = "macchiato", -- latte, frappe, macchiato, mocha
        transparent_background = false, -- disables setting the background color.
        integrations = {
                nvimtree = true,
                treesitter = true,
                ts_rainbow2 = true,
                cmp = true,
                gitsigns = true,
                telescope = {
                        enabled = true,
                        -- style = "nvchad"
                }
        },


})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"
