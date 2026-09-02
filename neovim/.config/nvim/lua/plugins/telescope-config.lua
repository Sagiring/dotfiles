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
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep (全局代码内容秒搜，支持 \\b 词边界正则)" })
vim.keymap.set('n', '<leader>fw', function()
    builtin.grep_string({
        word_match = "-w",
        prompt_title = "Grep Exact Word (全词精确搜索光标单词)",
    })
end, { desc = "Grep exact word (全词精确搜索光标所在单词)" })

vim.keymap.set('n', '<leader>fW', function()
    local search_term = vim.fn.input("全词精确搜索 (Whole Word) > ")
    if search_term and search_term ~= "" then
        builtin.grep_string({
            search = search_term,
            word_match = "-w",
            prompt_title = "Grep Exact Word: " .. search_term,
        })
    end
end, { desc = "Grep exact word by prompt (手动输入关键词进行全词精确搜索)" })

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

-- Git 联动与切分支
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = "Git branches (查看并切换分支，回车秒切)" })
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = "Git commits (查看提交历史)" })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = "Git status (查看变更文件)" })

-- Warning / Error 诊断搜索列表
vim.keymap.set('n', '<leader>fd', function()
    builtin.diagnostics({
        bufnr = 0,
        prompt_title = "Document Diagnostics (当前文件 Warning/Error 列表)",
    })
end, { desc = "Diagnostics in current file (当前文件 Warning/Error 列表)" })

vim.keymap.set('n', '<leader>fD', function()
    builtin.diagnostics({
        prompt_title = "Workspace Diagnostics (全工程 Warning/Error 列表)",
    })
end, { desc = "Workspace Diagnostics (全工程 Warning/Error 列表)" })

-- Java / LSP 类与符号搜索 (优先 LSP，降级全局 ripgrep 极速匹配)
vim.keymap.set('n', '<leader>fs', function()
    local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({ bufnr = 0 })
    if #clients > 0 then
        builtin.lsp_dynamic_workspace_symbols({
            prompt_title = "LSP Workspace Symbols (类与符号动态查询)",
        })
    else
        builtin.live_grep({
            prompt_title = "Live Grep (全局代码/类名搜索)",
        })
    end
end, { desc = "Search classes & symbols (搜索类与符号 / 降级全局搜索)" })
