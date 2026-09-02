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
