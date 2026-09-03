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
opt.timeoutlen = 600            -- Keymap timeout (毫秒)，给快捷键充足的前缀输入等待时间
opt.hidden = true               -- 允许在有未保存修改时切换 Buffer（保留撤销历史与修改）
opt.confirm = true              -- 退出或关闭未保存文件时，弹出确认弹窗 (Y)es/(N)o/(C)ancel，不再报错阻断
opt.scrolloff = 8               -- 屏幕上下永远预留 8 行代码缓冲视野，光标绝不紧贴屏幕边缘
opt.sidescrolloff = 8           -- 水平滚动时左右预留 8 列缓冲
opt.wrap = false                -- 代码默认不折行，保持纯净排版与真实行号对其

-- Shortmess to avoid unnecessary hit-enter prompts
opt.shortmess:append("c")
opt.shortmess:append("s")
opt.shortmess:append("W")

-- 拦截已被底层覆盖或弃用的框架提示通知，避免终端弹窗扰屏
local old_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and (msg:match("deprecated") or msg:match("position_encoding")) then
    return
  end
  old_notify(msg, level, opts)
end

if vim.deprecate then
  local orig_deprecate = vim.deprecate
  vim.deprecate = function(name, alternative, version, plugin, backtrace)
    if name and name:match("lspconfig") then
      return
    end
    orig_deprecate(name, alternative, version, plugin, backtrace)
  end
end

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
require('plugins.which-key-config')
require('plugins.indent-blankline-config')
require('plugins.treesitter-context-config')

-- 兼容 Neovim 0.11: 自动补齐 make_position_params 的 position_encoding 参数，杜绝 Telescope / LSP 插件触发弹窗警告与 hit-enter 提示
do
  if vim.lsp and vim.lsp.util and vim.lsp.util.make_position_params then
    local orig_make_position_params = vim.lsp.util.make_position_params
    vim.lsp.util.make_position_params = function(winnr, position_encoding)
      if not position_encoding then
        local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({ bufnr = 0 })
        local client = clients and clients[1]
        position_encoding = client and (client.offset_encoding or client.position_encoding) or "utf-16"
      end
      return orig_make_position_params(winnr, position_encoding)
    end
  end

  -- 兼容修复 Neovim 0.11 下 Telescope / LSP 跳转 Jar 包字节码 (jdt://) 时，反编译文本异步填充导致的 "Cursor position outside buffer" 红色报错
  if vim.lsp and vim.lsp.util and vim.lsp.util.jump_to_location then
    local orig_jump_to_location = vim.lsp.util.jump_to_location
    vim.lsp.util.jump_to_location = function(location, offset_encoding)
      local uri = location.uri or location.targetUri
      if uri and vim.startswith(uri, "jdt://") then
        local bufnr = vim.uri_to_bufnr(uri)
        if not vim.api.nvim_buf_is_loaded(bufnr) then
          vim.fn.bufload(bufnr)
        end
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if line_count <= 1 then
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          if #lines == 0 or (#lines == 1 and lines[1] == "") then
            -- 阻塞等待 nvim-jdtls 反编译填充完成 (最多等待 2500ms)
            vim.wait(2500, function()
              return vim.api.nvim_buf_line_count(bufnr) > 1
            end, 50)
          end
        end
      end
      return orig_jump_to_location(location, offset_encoding)
    end
  end
end

-- 兼容修复 Treesitter 异步高亮渲染与 Lualine 状态栏更新
do
  if vim.api and vim.api.nvim__redraw then
    local orig_redraw = vim.api.nvim__redraw
    vim.api.nvim__redraw = function(opts)
      if type(opts) == "table" and opts.win and not vim.api.nvim_win_is_valid(opts.win) then
        return
      end
      pcall(orig_redraw, opts)
    end
  end

  -- 拦截 Neovim 0.11 下 lualine 偶发的 win_set_option / set_option E539 字符解析报错
  if vim.api and vim.api.nvim_win_set_option then
    local orig_win_set_option = vim.api.nvim_win_set_option
    vim.api.nvim_win_set_option = function(win, name, val)
      if not vim.api.nvim_win_is_valid(win) then return end
      pcall(orig_win_set_option, win, name, val)
    end
  end

  if vim.api and vim.api.nvim_set_option then
    local orig_set_option = vim.api.nvim_set_option
    vim.api.nvim_set_option = function(name, val)
      pcall(orig_set_option, name, val)
    end
  end
end

-- 自愈指令：一键清理 JDTLS 损坏的 Eclipse 缓存元数据与多工作区并重启
vim.api.nvim_create_user_command("JdtClean", function()
  local cache_dir1 = vim.fn.stdpath("cache") .. "/jdtls"
  local cache_dir2 = vim.fn.expand("~/.cache/jdtls")
  pcall(vim.cmd, "LspStop")
  vim.fn.delete(cache_dir1, "rf")
  vim.fn.delete(cache_dir2, "rf")
  vim.notify("JDTLS Eclipse 缓存与多工作区索引已彻底清理，正在重新载入 Java 语言服务...", vim.log.levels.INFO)
  vim.defer_fn(function()
    pcall(vim.cmd, "edit")
  end, 500)
end, { desc = "Clean JDTLS workspace cache and restart cleanly" })
