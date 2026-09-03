local highlights = {}
local ok, catppuccin_bufferline = pcall(require, "catppuccin.special.bufferline")
if ok and catppuccin_bufferline.get_theme then
        highlights = catppuccin_bufferline.get_theme()
elseif ok and catppuccin_bufferline.get then
        highlights = catppuccin_bufferline.get()
end

require("bufferline").setup {
        highlights = highlights,
        options = {
                -- 自定义 Buffer 标签名称（针对 Jar 包反编译的 jdt:// 类文件进行极简化展示）
                name_formatter = function(buf)
                        if buf.path and buf.path:match("^jdt://") then
                                local clean_path = buf.path:gsub("%?.*$", "")
                                local class = clean_path:match("([^/]+)$") or buf.name
                                return "[Jar] " .. class
                        end
                end,
                -- 使用 nvim 内置 lsp 诊断
                diagnostics = "nvim_lsp",
                -- 左侧让出 nvim-tree 的位置
                offsets = {{
                        filetype = "NvimTree",
                        text = "",
                        highlight = "Directory",
                        text_align = "left"
                }},
        }
}
