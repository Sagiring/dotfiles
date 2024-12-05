vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- default to don't open nvim-tree

require("nvim-tree").setup({
	sort_by = "case_sensitive",

	git = {
		enable = false,
	},

	view = {
		side = "left",
		number = false,
		relativenumber = false,
		signcolumn = "yes",
	},
	renderer = {
		group_empty = true,
	},
})
