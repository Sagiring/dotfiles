vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
	sort_by = "case_sensitive",

	-- 过滤巨型目录与无用编译产物，防止卡顿
	filters = {
		dotfiles = false,
		custom = { "^.git$", "^target$", "^node_modules$", "^.idea$", "^.vscode$", "^build$", "^.gradle$" },
	},

	git = {
		enable = true,
		ignore = true, -- 必须为 true：忽略被 gitignore 的编译产物 (如 target/dist)，避免遍历大目录引发严重卡顿
		timeout = 300,
	},

	diagnostics = {
		enable = true,
		show_on_dirs = true,
		debounce_delay = 100, -- 防抖延时，避免频繁重新扫描
	},

	filesystem_watchers = {
		enable = true,
		debounce_delay = 100,
		ignore_dirs = { "target", "node_modules", ".git", "build", ".gradle", ".venv" },
	},

	view = {
		side = "left",
		width = 32,
		number = false,
		relativenumber = false,
		signcolumn = "yes",
	},
	renderer = {
		group_empty = true,
		highlight_git = true,
		icons = {
			show = {
				git = true,
				folder = true,
				file = true,
				folder_arrow = true,
			},
		},
	},
})
