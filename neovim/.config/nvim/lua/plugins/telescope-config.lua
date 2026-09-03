local telescope = require('telescope')
local actions = require('telescope.actions')
local builtin = require('telescope.builtin')
local previewers = require('telescope.previewers')
local utils = require('telescope.utils')

-- 拦截 Telescope URI 过滤，使其能够原生识别和加载 jdt:// 协议（Jar 包内类文件）
local orig_is_uri = utils.is_uri
utils.is_uri = function(filename)
    if filename and filename:match("^jdt://") then
        return false
    end
    return orig_is_uri(filename)
end

-- 自定义 Telescope 预览器，支持实时反编译预览 Jar 包内的 .class 源码
local default_maker = previewers.buffer_previewer_maker
local custom_previewer_maker = function(filepath, bufnr, opts)
    opts = opts or {}
    if filepath and filepath:match("^jdt://") then
        local jdt_buf = vim.fn.bufnr(filepath)
        if jdt_buf ~= -1 and vim.api.nvim_buf_is_loaded(jdt_buf) then
            local lines = vim.api.nvim_buf_get_lines(jdt_buf, 0, -1, false)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            vim.bo[bufnr].filetype = "java"
            if opts.callback then opts.callback(bufnr) end
            return
        end

        local client = (vim.lsp.get_clients and vim.lsp.get_clients({ name = "jdtls" }) or {})[1]
        if client then
            client:request("java/classFileContents", { uri = filepath }, function(err, result)
                if result and vim.api.nvim_buf_is_valid(bufnr) then
                    local normalized = string.gsub(result, "\r\n", "\n")
                    local lines = vim.split(normalized, "\n", { plain = true })
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
                    vim.bo[bufnr].filetype = "java"
                    if opts.callback then opts.callback(bufnr) end
                end
            end, bufnr)
            return
        end
    end
    default_maker(filepath, bufnr, opts)
end

telescope.setup({
    defaults = {
        buffer_previewer_maker = custom_previewer_maker,
        path_display = function(opts, path)
            if path and path:match("^jdt://") then
                local jar = path:match("contents/([^/]+)/") or "jar"
                local class = path:match("([^/]+%.class)") or path
                return string.format("[Jar] %s (%s)", class, jar)
            end
            return utils.path_tail(path)
        end,
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
