-- ==============================================================================
-- Lualine Configuration - Ultra-Clean & Professional Minimalist Design
-- ==============================================================================

local lsp_progress = {
    active = false,
    client = "LSP",
    title = "",
    message = "",
    percentage = nil,
    spinner_idx = 1,
}

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

-- 生成高颜值平滑进度条: 如 [████░░░░ 50%]
local function render_progress_bar(percent, bar_len)
    bar_len = bar_len or 8
    if not percent then return "" end
    local p = math.max(0, math.min(100, tonumber(percent) or 0))
    local filled = math.floor((p / 100) * bar_len)
    local empty = bar_len - filled
    local bar = string.rep("█", filled) .. string.rep("░", empty)
    return string.format(" [%s %d%%]", bar, p)
end

-- 监听 LSP 进度推送 ($/progress)，捕获 JDTLS/LSP 编译索引进度
vim.lsp.handlers["$/progress"] = function(_, result, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = client and client.name or "LSP"
    local val = result.value
    if not val or not val.kind then
        return
    end

    if val.kind == "begin" or val.kind == "report" then
        lsp_progress.active = true
        lsp_progress.client = client_name
        lsp_progress.title = val.title or ""
        lsp_progress.message = val.message or ""
        lsp_progress.percentage = val.percentage
        lsp_progress.spinner_idx = (lsp_progress.spinner_idx % #spinner_frames) + 1
    elseif val.kind == "end" then
        lsp_progress.active = false
        lsp_progress.percentage = nil
        lsp_progress.title = ""
        lsp_progress.message = ""
        vim.defer_fn(function()
            pcall(vim.cmd, "redrawstatus")
        end, 300)
    end
    pcall(vim.cmd, "redrawstatus")
end

-- 状态栏组件：
-- 1. 正在编译/索引时：醒目展示动态进度条 [████░░░░ 50%]
-- 2. 原生 vim.lsp.status() 兼容：适配 Neovim 0.11 的内置状态
-- 3. 空闲就绪时：展示极简绿点就绪图标
local function lsp_status_component()
    if lsp_progress.active then
        local spinner = spinner_frames[lsp_progress.spinner_idx]
        local bar = render_progress_bar(lsp_progress.percentage, 8)
        local extra_msg = lsp_progress.message ~= "" and (" " .. lsp_progress.message) or (lsp_progress.title ~= "" and (" " .. lsp_progress.title) or "")
        if #extra_msg > 20 then
            extra_msg = extra_msg:sub(1, 17) .. "..."
        end
        return string.format("%s [%s]%s%s", spinner, lsp_progress.client, bar, extra_msg)
    end

    if vim.lsp.status then
        local st = vim.lsp.status()
        if st and st ~= "" then
            return "󰑮 " .. st
        end
    end

    local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
    local buf_clients = get_clients and get_clients({ bufnr = 0 }) or {}
    if #buf_clients == 0 then
        return ""
    end

    local names = {}
    for _, c in ipairs(buf_clients) do
        table.insert(names, c.name)
    end
    return "󰒋 " .. table.concat(names, ", ")
end

require('lualine').setup({
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '│', right = '│' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 100, -- 100ms 高刷，保证进度条平滑无延迟
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        -- 左侧：仅保留模式 (NORMAL/INSERT) 与 Git 分支 + 错误/警告小徽标
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diagnostics' },
        -- 中间：仅显示当前文件名（最简短名字，不再显示长路径）
        lualine_c = {
            { 'filename', path = 0, symbols = { modified = ' ●', readonly = ' 🔒' } }
        },
        -- 右侧：LSP 动态进度/引擎名称 + 极简行号位置（砍掉冗余编码、换行符、百分比、多余图标）
        lualine_x = {
            { 
                lsp_status_component, 
                color = function()
                    return lsp_progress.active and { fg = '#f5a97f', gui = 'bold' } or { fg = '#a6da95' }
                end,
            },
        },
        lualine_y = { 'filetype' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 0 } },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = { 'nvim-tree' }
})
