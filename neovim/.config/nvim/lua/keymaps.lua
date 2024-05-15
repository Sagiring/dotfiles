local keymap = vim.keymap

keymap.set("n","h","^")
keymap.set("n","l","$")
-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap.set("n", "<M-h>", ":NvimTreeFocus<CR>")
keymap.set("n", "<M-l>", "::NvimTreeClose<CR>")

-- nvim-treesitter
keymap.set("n", "<C-M-l>", "gg=G")

-- bufferline
keymap.set("n", "<C-L>", ":BufferLineCycleNext<CR>")
keymap.set("n", "<C-H>", ":BufferLineCyclePrev<CR>")

