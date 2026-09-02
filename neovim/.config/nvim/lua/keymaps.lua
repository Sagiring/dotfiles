local keymap = vim.keymap

-- Basic navigation & editing
keymap.set("i", "jj", "<Esc>")
keymap.set("n", "H", "^")
keymap.set("n", "L", "$")

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

-- Nvim-tree & Window navigation
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree (Space+e)" })
keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { desc = "Toggle file tree (Ctrl+n)" })

-- Space + h: 切换回左侧目录树
keymap.set("n", "<leader>h", ":NvimTreeFocus<CR>", { desc = "Focus file tree (Space+h)" })

-- Space + l: 从目录树切换回右侧编辑器
keymap.set("n", "<leader>l", function()
    if vim.bo.filetype == "NvimTree" then
        vim.cmd("wincmd p")
    else
        vim.cmd("wincmd l")
    end
end, { desc = "Focus editor window (Space+l)" })

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
        local ok, tb = pcall(require, "telescope.builtin")
        if ok then tb.lsp_definitions() else vim.lsp.buf.definition() end
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
        local ok, tb = pcall(require, "telescope.builtin")
        if ok then tb.lsp_implementations() else vim.lsp.buf.implementation() end
    else
        -- 对于不原生提供 implementationProvider 的语言（如 PHP Intelephense / Python 等），智能秒切全局实现与引用检索
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

-- Diagnostic keymaps
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
