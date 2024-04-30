local keymap = vim.keymap

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap.set("n", "<M-h>", ":NvimTreeFocus<CR>")
keymap.set("n", "<M-l>", "::NvimTreeClose<CR>")

-- nvim-treesitter
keymap.set("n", "<C-M-l>", "gg=G")
