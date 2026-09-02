local telescope = require('telescope')
local actions = require('telescope.actions')
local builtin = require('telescope.builtin')

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<M-j>"] = actions.move_selection_next,
                ["<M-k>"] = actions.move_selection_previous,
                ["<Down>"] = actions.move_selection_next,
                ["<Up>"] = actions.move_selection_previous,
            },
            n = {
                ["j"] = actions.move_selection_next,
                ["k"] = actions.move_selection_previous,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<M-j>"] = actions.move_selection_next,
                ["<M-k>"] = actions.move_selection_previous,
            },
        },
    },
})

-- 全局与文件搜索
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files (全局文件名搜索)" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep (全局代码内容秒搜)" })
vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = "Grep string (搜索光标所在单词)" })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffers (查看已打开的文件)" })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = "Oldfiles (最近打开的历史文件)" })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help tags (帮助文档)" })

-- 当前文件专用搜索
vim.keymap.set('n', '<leader>fl', builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current buffer (当前文件行模糊搜索)" })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current buffer (当前文件行模糊搜索)" })
vim.keymap.set('n', '<leader>ds', function() 
    builtin.lsp_document_symbols({
        prompt_title = "Document Symbols (当前文件类结构/方法大纲)",
    }) 
end, { desc = "Document symbols (当前文件类结构/方法大纲)" })

-- Git 联动搜索
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = "Git commits (查看提交历史)" })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = "Git status (查看变更文件)" })

-- Java / LSP 类与符号搜索 (使用稳定的 lsp_workspace_symbols，避免 dynamic 多次 cancel 导致 JDTLS 响应丢失)
vim.keymap.set('n', '<leader>fs', function()
    builtin.lsp_workspace_symbols({
        prompt_title = "LSP Workspace Symbols (类与符号模糊搜索)",
    })
end, { desc = "Search classes & symbols (全局搜索类与符号)" })
