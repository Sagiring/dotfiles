-- ==============================================================================
-- Lualine Configuration with Real-Time LSP / JDTLS Progress Display
-- ==============================================================================

local lsp_progress_message = ""

-- 监听 LSP 进度推送事件 ($/progress)，实时捕获 JDTLS/LSP 初始化与编译索引进度
vim.lsp.handlers["$/progress"] = function(_, result, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = client and client.name or "LSP"
    local val = result.value
    if not val or not val.kind then
        return
    end

    if val.kind == "begin" or val.kind == "report" then
        local title = val.title or ""
        local msg = val.message and (": " .. val.message) or ""
        local percent = val.percentage and string.format(" %d%%", val.percentage) or ""
        lsp_progress_message = string.format("󰑮 [%s] %s%s%s", client_name, title, msg, percent)
    elseif val.kind == "end" then
        lsp_progress_message = ""
        vim.defer_fn(function()
            pcall(vim.cmd, "redrawstatus")
        end, 500)
    end
    pcall(vim.cmd, "redrawstatus")
end

-- 状态栏组件：正在索引时展示动态进度条，完成后展示就绪的 LSP 引擎
local function lsp_status_component()
    if lsp_progress_message ~= "" then
        return lsp_progress_message
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
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = { 'NvimTree' },
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 200, -- 200ms 高刷，保证进度条丝滑更新
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
                    return lsp_progress_message ~= "" and { fg = '#f5a97f', gui = 'bold' } or { fg = '#8bd5ca' }
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
    extensions = {}
})
