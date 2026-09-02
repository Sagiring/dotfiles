-- ==============================================================================
-- Lualine Configuration with Smooth LSP Progress Bar & Zero-Flicker State
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

-- 状态栏组件：正在索引时展示高颜值动态进度条，空闲时展示稳定就绪的 LSP 引擎
local function lsp_status_component()
    if lsp_progress.active then
        local spinner = spinner_frames[lsp_progress.spinner_idx]
        local bar = render_progress_bar(lsp_progress.percentage, 8)
        local extra_msg = lsp_progress.message ~= "" and (" " .. lsp_progress.message) or (lsp_progress.title ~= "" and (" " .. lsp_progress.title) or "")
        -- 截断过长消息防止顶破状态栏
        if #extra_msg > 24 then
            extra_msg = extra_msg:sub(1, 21) .. "..."
        end
        return string.format("%s [%s]%s%s", spinner, lsp_progress.client, bar, extra_msg)
    end

    -- 空闲就绪状态：稳定展示所有挂载的 LSP 引擎，杜绝任何微小抖动与闪烁
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
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 200, -- 200ms 高刷，保证进度条平滑更新
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
            { 'filename', path = 1 }, -- 显示相对路径
            { 
                lsp_status_component, 
                color = function()
                    return lsp_progress.active and { fg = '#f5a97f', gui = 'bold' } or { fg = '#8bd5ca' }
                end,
            },
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = { 'nvim-tree' }
})
