require('keymaps')

-- theme
-- require('github-theme-config')
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
