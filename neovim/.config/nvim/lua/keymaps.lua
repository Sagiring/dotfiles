local keymap = vim.keymap

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap.set("n", "<leader>t", ":NvimTreeFocus<CR>")

-- nvim-treesitter
keymap.set("n", "<C-M-l>", "gg=G")
