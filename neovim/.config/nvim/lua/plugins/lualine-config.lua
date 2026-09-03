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
        -- 进度结束后立即主动刷新状态栏，恢复为常驻绿色图标
        vim.schedule(function()
            pcall(vim.cmd, "redrawstatus")
        end)
    end
    pcall(vim.cmd, "redrawstatus")
end

-- 进度条与 LSP 状态组件
local function lsp_status_component()
    -- 仅当 LSP 处于活动工作进度中（如正在索引、编译、扫描 Maven 依赖）时显示进度条与旋转动画
    if lsp_progress.active then
        local spinner = spinner_frames[lsp_progress.spinner_idx]
        local bar = render_progress_bar(lsp_progress.percentage, 8)
        local extra_msg = lsp_progress.message ~= "" and (" " .. lsp_progress.message) or (lsp_progress.title ~= "" and (" " .. lsp_progress.title) or "")
        if #extra_msg > 20 then
            extra_msg = extra_msg:sub(1, 17) .. "..."
        end
        return string.format("%s [%s]%s%s", spinner, lsp_progress.client, bar, extra_msg)
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
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = false, -- 彻底消除中间大面积留白断层，让内容自然向两侧对齐
        globalstatus = true,
        refresh = {
            statusline = 100, -- 100ms 高刷，保证进度条平滑无延迟
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        -- 左侧：模式 + Git 分支 + 错误诊断 + 当前文件名
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diagnostics' },
        lualine_c = {
            { 'filename', path = 0, symbols = { modified = ' ●', readonly = ' 🔒' } }
        },
        -- 右侧：LSP 进度条 / 引擎状态 + 文件类型 + 行列位置
        lualine_x = {
            { 
                lsp_status_component, 
                color = function()
                    return lsp_progress.active and { fg = '#f5a97f', gui = 'bold' } or { fg = '#a6da95' }
                end,
            },
            'filetype',
        },
        lualine_y = {},
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
