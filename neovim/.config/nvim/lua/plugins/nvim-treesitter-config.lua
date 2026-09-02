local ok, rainbow_delimiters = pcall(require, 'rainbow-delimiters')
if ok then
	vim.g.rainbow_delimiters = {
		strategy = {
			[''] = rainbow_delimiters.strategy['global'],
		},
		query = {
			[''] = 'rainbow-delimiters',
		},
		highlight = {
			'RainbowDelimiterYellow',
			'RainbowDelimiterViolet',
			'RainbowDelimiterBlue',
			'RainbowDelimiterOrange',
			'RainbowDelimiterGreen',
			'RainbowDelimiterCyan',
			'RainbowDelimiterRed',
		},
	}
end

-- 优先使用 git clone 方式下载/编译语法解析器，避免 tarball 解压分支名不匹配 (main/master) 导致的 mv 报错
require('nvim-treesitter.install').prefer_git = true

require('nvim-treesitter.configs').setup {
	-- 自动安装并确保以下常用语言/格式的高亮解析器就绪
	ensure_installed = {
		"java",
		"php",
		"php_only",
		"python",
		"json",
		"jsonc",
		"yaml",
		"toml",
		"xml",
		"html",
		"css",
		"javascript",
		"typescript",
		"bash",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"markdown",
		"markdown_inline",
		"sql",
		"dockerfile",
		"diff",
		"git_config",
		"gitcommit",
	},
	-- 关闭自动在线检查与安装，避免打开文件时联网检测引发前台阻塞卡顿
	auto_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
		-- 超大文件 (>256KB) 自动禁用 Treesitter，防止打字和滚动卡死
		disable = function(lang, buf)
			local max_filesize = 256 * 1024 -- 256 KB
			local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
	},
	-- 强烈建议关闭 Treesitter 实验性缩进：在 Java/Python/Lua 中换行会频繁重新遍历语法树导致严重卡顿
	indent = {
		enable = false
	},
}
