require("catppuccin").setup({
    flavour = "macchiato", -- latte, frappe, macchiato, mocha
    transparent_background = false,
    custom_highlights = function(colors)
        return {
            -- 1:1 像素级对齐 VS Code 官方经典 Bracket Pair Colorization 彩虹括号调色板
            RainbowDelimiterYellow = { fg = "#FFD700" }, -- Level 1: 经典明亮金黄 (VS Code 原生 #ffd700)
            RainbowDelimiterViolet = { fg = "#DA70D6" }, -- Level 2: 经典优雅兰花粉紫 (VS Code 原生 #da70d6)
            RainbowDelimiterBlue   = { fg = "#179FFF" }, -- Level 3: 经典清爽天蓝青色 (VS Code 原生 #179fff)
            RainbowDelimiterOrange = { fg = "#FF9E64" }, -- Level 4: 温暖柔和橙色
            RainbowDelimiterGreen  = { fg = "#50FA7B" }, -- Level 5: 清晰翠绿色
            RainbowDelimiterCyan   = { fg = "#8BE9FD" }, -- Level 6: 明亮青浅蓝
            RainbowDelimiterRed    = { fg = "#FF5555" }, -- Level 7: 柔和珊瑚红
        }
    end,
    integrations = {
        nvimtree = true,
        treesitter = true,
        ts_rainbow2 = false, -- 关闭默认沉闷暗淡的 gruvbox 色调，全面采用上面的 VS Code 调色板
        cmp = true,
        gitsigns = true,
        bufferline = true,
        telescope = {
            enabled = true,
        }
    },
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"

-- 注册主题加载回调与即时生效，确保彩虹括号颜色 100% 保持 VS Code 纯净清爽视觉
local function apply_vscode_rainbow_bracket_colors()
    vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#FFD700", force = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#DA70D6", force = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterBlue",   { fg = "#179FFF", force = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#FF9E64", force = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterGreen",  { fg = "#50FA7B", force = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterCyan",   { fg = "#8BE9FD", force = true })
    vim.api.nvim_set_hl(0, "RainbowDelimiterRed",    { fg = "#FF5555", force = true })
end

apply_vscode_rainbow_bracket_colors()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = apply_vscode_rainbow_bracket_colors,
})
