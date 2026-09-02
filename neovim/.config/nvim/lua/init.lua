-- Set leader key before loading plugins and keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General options
local opt = vim.opt

-- Tab & Indentation: 4 spaces
opt.tabstop = 4        -- 1 个 Tab 宽度对应 4 个空格
opt.shiftwidth = 4     -- 自动缩进、换行缩进移动 4 个空格
opt.softtabstop = 4    -- 插入模式下按 Backspace 一次删除 4 个空格
opt.expandtab = true   -- 按 Tab 键自动展开为 4 个空格
opt.autoindent = true  -- 继承上一行的缩进
opt.smartindent = true -- 智能代码块缩进

-- Editor behaviors
opt.clipboard = "unnamedplus"   -- Sync with system clipboard
opt.undofile = true             -- Enable persistent undo history
opt.cursorline = true           -- Highlight current line
opt.termguicolors = true        -- True color support
opt.signcolumn = "yes"          -- Always show sign column
opt.updatetime = 250            -- Faster completion and diagnostics

require('keymaps')

-- theme
require('plugins.catppuccin-config')

-- Plugins
require('plugins.lualine-config')
require('plugins.nvim-tree-config')
require('plugins.nvim-treesitter-config')
require('plugins.mason-config')
require('plugins.nvim-cmp-config')
require('plugins.commit-config')
require('plugins.autopairs-config')
require('plugins.bufferline-config')
require('plugins.gitsigns-config')
require('plugins.telescope-config')

local old_notify = vim.notify
vim.notify = function(msg, ...)
  if type(msg) == "string" and msg:match("deprecated") then
    return
  end
  old_notify(msg, ...)
end
