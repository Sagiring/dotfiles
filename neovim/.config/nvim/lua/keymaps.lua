local keymap = vim.keymap

keymap.set("i","jj","<Esc>")
keymap.set("n","H","^")
keymap.set("n","L","$")
-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap.set("n", "<M-h>", ":NvimTreeFocus<CR>")
keymap.set("n", "<M-l>", "::NvimTreeClose<CR>")

-- nvim-treesitter
keymap.set("n", "<S-M-f>", "gg=G")

-- bufferline
keymap.set("n", "<C-L>", ":BufferLineCycleNext<CR>")
keymap.set("n", "<C-H>", ":BufferLineCyclePrev<CR>")

