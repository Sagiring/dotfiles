vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 自动打开目录树：当用 nvim 打开目录时自动进入 NvimTree
local function open_nvim_tree(data)
  -- 检查参数是否为一个真实存在的目录
  local directory = vim.fn.isdirectory(data.file) == 1
  if not directory then
    return
  end
  -- 切换到该目录并打开目录树
  vim.cmd.cd(data.file)
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

require("nvim-tree").setup({
	sort_by = "case_sensitive",

	-- 基础视图
	view = {
		side = "left",
		width = 32,
		number = false,
		relativenumber = false,
		signcolumn = "no", -- 关闭标记列，界面更纯粹清爽
	},

	-- 过滤巨型目录与编译产物，防止任何不必要的遍历
	filters = {
		dotfiles = false,
		custom = { "^.git$", "^target$", "^node_modules$", "^.idea$", "^.vscode$", "^build$", "^.gradle$" },
	},

	-- 精简：关闭后台文件系统监听与防抖（避免消耗系统句柄与内存，需要时按 R 刷新即可）
	filesystem_watchers = {
		enable = false,
	},

	-- 精简：关闭 LSP 树状错误诊断（彻底消除每次敲代码时目录树反复重绘的 CPU 开销）
	diagnostics = {
		enable = false,
	},

	-- Git 状态轻量展示
	git = {
		enable = true,
		ignore = true,
		timeout = 200,
	},

	renderer = {
		group_empty = true,
		highlight_git = false, -- 关闭复杂的整行高亮，保持极简
		icons = {
			show = {
				git = true,
				folder = true,
				file = true,
				folder_arrow = true,
			},
		},
	},

	actions = {
		open_file = {
			quit_on_open = false,
			resize_window = true,
		},
	},
})
