local keymap = vim.keymap

-- Basic navigation & editing
keymap.set("i", "jj", "<Esc>")
keymap.set("n", "H", "^")
keymap.set("n", "L", "$")

-- 视野平滑控制：翻页与搜索跳转时光标始终牢牢居中，避免晕头
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })
keymap.set("n", "n", "nzzzv", { desc = "Next search match (centered)" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search match (centered)" })

-- Fast save & quit & close buffer
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit window" })
keymap.set("n", "<leader>c", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local modified = vim.bo[bufnr].modified
    if modified then
        local choice = vim.fn.confirm("当前文件有未保存修改，是否保存？", "&Yes\n&No\n&Cancel", 1)
        if choice == 1 then
            vim.cmd("write")
            vim.cmd("bdelete")
        elseif choice == 2 then
            vim.cmd("bdelete!")
        end
    else
        vim.cmd("bdelete")
    end
end, { desc = "Close current tab/buffer (Space+c)" })
keymap.set("n", "<leader><space>", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Visual mode indentation (keep selection)
keymap.set("v", "<", "<gv", { desc = "Indent left and keep selection" })
keymap.set("v", ">", ">gv", { desc = "Indent right and keep selection" })

-- Move selected lines up and down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Paste without replacing clipboard register
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Nvim-tree & Diffview 智能自适应开关与导航 (解决双树并存打架问题)
keymap.set("n", "<leader>e", function()
    local ok, lib = pcall(require, "diffview.lib")
    local view = ok and lib.get_current_view()
    if view then
        vim.cmd("DiffviewToggleFiles")
    else
        vim.cmd("NvimTreeToggle")
    end
end, { desc = "Toggle file tree / diff panel (Space+e 智能开关目录树/Diff树)" })
keymap.set("n", "<C-n>", "<leader>e", { remap = true, desc = "Toggle file tree (Ctrl+n)" })

-- Space + h: 智能聚焦到左侧目录树 (无论日常 NvimTree 还是 Diffview 变更树，杜绝双树打架)
keymap.set("n", "<leader>h", function()
    local ok, lib = pcall(require, "diffview.lib")
    local view = ok and lib.get_current_view()
    if view and view.panel then
        if not view.panel:is_open() then
            view.panel:open()
        end
        view.panel:focus()
    else
        vim.cmd("NvimTreeFocus")
    end
end, { desc = "Focus left tree (Space+h 智能聚焦左侧树，杜绝双树冲突)" })

-- Space + l: 从目录树平滑切回右侧主要编辑窗口 (自适应 NvimTree / DiffviewFiles)
keymap.set("n", "<leader>l", function()
    local ft = vim.bo.filetype
    if ft == "NvimTree" then
        vim.cmd("wincmd p")
    elseif ft == "DiffviewFiles" or ft == "DiffviewFileHistory" then
        local ok, lib = pcall(require, "diffview.lib")
        local view = ok and lib.get_current_view()
        if view and view.cur_layout then
            local main_win = view.cur_layout:get_main_win()
            if main_win and vim.api.nvim_win_is_valid(main_win.id) then
                vim.api.nvim_set_current_win(main_win.id)
                return
            end
        end
        vim.cmd("wincmd p")
    else
        vim.cmd("wincmd l")
    end
end, { desc = "Focus editor window from tree (Space+l 从树切回编辑器)" })

-- 分屏管理 (Split: Space+s 系列，彻底免去繁琐的 Ctrl+w)
keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically (垂直分屏 / 左右分屏)" })
keymap.set("n", "<leader>sp", ":split<CR>", { desc = "Split horizontally (水平分屏 / 上下分屏)" })
keymap.set("n", "<leader>sc", ":close<CR>", { desc = "Close current split window (关闭当前分屏)" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize split window sizes (均分所有分屏宽度)" })

-- 极速跨分屏窗口跳转 (同时支持单手无延迟 Ctrl+h/j/k/l 与 Space+s 流派)
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left (跳到左边分屏)" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down (跳到下边分屏)" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up (跳到上边分屏)" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right (跳到右边分屏)" })

keymap.set("n", "<leader>sh", "<C-w>h", { desc = "Window left (Space+sh 跳到左边分屏)" })
keymap.set("n", "<leader>sj", "<C-w>j", { desc = "Window down (Space+sj 跳到下边分屏)" })
keymap.set("n", "<leader>sk", "<C-w>k", { desc = "Window up (Space+sk 跳到上边分屏)" })
keymap.set("n", "<leader>sl", "<C-w>l", { desc = "Window right (Space+sl 跳到右边分屏)" })

-- Bufferline (同时支持 Ctrl 与 Space 快捷键)
keymap.set("n", "<C-L>", ":BufferLineCycleNext<CR>", { desc = "Next buffer (Ctrl+L)" })
keymap.set("n", "<C-H>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer (Ctrl+H)" })
keymap.set("n", "<leader>]", ":BufferLineCycleNext<CR>", { desc = "Next buffer (Space+])" })
keymap.set("n", "<leader>[", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer (Space+[)" })
keymap.set("n", "<leader>bn", ":BufferLineCycleNext<CR>", { desc = "Buffer Next (Space+bn)" })
keymap.set("n", "<leader>bp", ":BufferLineCyclePrev<CR>", { desc = "Buffer Prev (Space+bp)" })

-- 跳转历史导航 (同时支持 Space+o / Space+i 与原生的 Ctrl+o / Ctrl+i，无需扭曲手腕按 Ctrl)
keymap.set("n", "<leader>o", "<C-o>", { desc = "Jump backward / Back (Space+o 返回上一个位置)" })
keymap.set("n", "<leader>i", "<C-i>", { desc = "Jump forward (Space+i 前进到下一个位置)" })

-- LSP keymaps (自动适应 LSP 客户端与原生/Telescope 降级)
local function get_word_under_cursor()
    return vim.fn.expand("<cword>")
end

keymap.set("n", "gd", function()
    local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({ bufnr = 0 })
    if #clients > 0 then
        -- Java 文件优先使用原生/nvim-jdtls 优化的定义跳转，彻底避免 Telescope 在 Jar 包反编译时因光标溢出触发红屏
        if vim.bo.filetype == "java" then
            vim.lsp.buf.definition()
        else
            local ok, tb = pcall(require, "telescope.builtin")
            if ok then tb.lsp_definitions({ reuse_win = true }) else vim.lsp.buf.definition() end
        end
    else
        local word = get_word_under_cursor()
        local ok, tb = pcall(require, "telescope.builtin")
        if ok and word ~= "" then
            tb.grep_string({
                search = word,
                prompt_title = "跳转定义 (全局搜索: " .. word .. ")",
            })
        elseif word ~= "" then
            vim.cmd("normal! *")
        end
    end
end, { desc = "Go to definition (跳转定义 / 降级全局搜索)" })

keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to declaration" })
keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover documentation" })

-- 别名快捷键：支持 Space 风格的前缀跳转 (<Space>rd 跳定义, <Space>ri 跳实现)
keymap.set("n", "<leader>rd", "gd", { remap = true, desc = "Go to definition (Space+rd 等同于 gd，支持 Jar 反编译)" })
keymap.set("n", "<leader>ri", "gi", { remap = true, desc = "Go to implementation (Space+ri 等同于 gi，支持 Jar 反编译)" })

keymap.set("n", "gi", function()
    local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({ bufnr = 0 })
    local has_impl = false
    for _, c in ipairs(clients) do
        if c.server_capabilities and c.server_capabilities.implementationProvider then
            has_impl = true
            break
        end
    end

    if has_impl then
        if vim.bo.filetype == "java" then
            -- 优先使用原生 LSP 实现跳转，若由于光标位于普通方法/类上无下游子类实现时，智能回退至定义或全局检索
            local current_pos = vim.api.nvim_win_get_cursor(0)
            vim.lsp.buf.implementation()
            vim.defer_fn(function()
                -- 若 300ms 后光标未发生位移，说明当前符号没有不同的实现类（通常是普通类/方法），自动无缝跳转到定义
                local new_pos = vim.api.nvim_win_get_cursor(0)
                if current_pos[1] == new_pos[1] and current_pos[2] == new_pos[2] then
                    vim.lsp.buf.definition()
                end
            end, 300)
        else
            local ok, tb = pcall(require, "telescope.builtin")
            if ok then tb.lsp_implementations({ reuse_win = true }) else vim.lsp.buf.implementation() end
        end
    else
        -- 对于不原生提供 implementationProvider 的场景，智能全局检索
        local word = get_word_under_cursor()
        local ok, tb = pcall(require, "telescope.builtin")
        if ok and word ~= "" then
            tb.grep_string({
                search = word,
                prompt_title = "查找实现与引用 (全局检索: " .. word .. ")",
            })
        elseif word ~= "" then
            vim.cmd("normal! *")
        end
    end
end, { desc = "Go to implementation (查看实现 / 降级全局搜索)" })

keymap.set("n", "gr", function()
    local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({ bufnr = 0 })
    if #clients > 0 then
        local ok, tb = pcall(require, "telescope.builtin")
        if ok then tb.lsp_references() else vim.lsp.buf.references() end
    else
        local word = get_word_under_cursor()
        local ok, tb = pcall(require, "telescope.builtin")
        if ok and word ~= "" then
            tb.grep_string({
                search = word,
                prompt_title = "查看引用 (全局搜索: " .. word .. ")",
            })
        elseif word ~= "" then
            vim.cmd("normal! *")
        end
    end
end, { desc = "Find references (查看引用 / 降级全局搜索)" })
keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol" })
keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
keymap.set("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, { desc = "LSP: Format code" })
keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { desc = "LSP: Format code" })
keymap.set("n", "<leader>co", function()
    local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({ bufnr = 0 })
    local is_java = vim.bo.filetype == "java"
    if is_java then
        local ok, jdtls = pcall(require, "jdtls")
        if ok and jdtls.organize_imports then
            jdtls.organize_imports()
        else
            vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply = true,
            })
        end
    else
        vim.lsp.buf.code_action()
    end
end, { desc = "Organize Imports (自动导入与清除无用 import, Space+co 避免与 Space+o 冲突)" })

-- Diagnostic keymaps
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
