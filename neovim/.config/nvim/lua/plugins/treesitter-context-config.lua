local ok, tc = pcall(require, "treesitter-context")
if not ok then
    return
end

tc.setup({
    enable = true,
    max_lines = 3,            -- 顶部最多锁定 3 行表头（类名、方法名），绝不挤占过多代码视野
    min_window_height = 15,   -- 窗口高度小于 15 行时不显示
    line_numbers = true,
    multiline_threshold = 1,  -- 多行方法签名只显示首行，保持极简
    trim_scope = 'outer',     -- 超出限制时从外层开始折叠
    mode = 'cursor',          -- 根据光标位置计算上下文
    separator = nil,          -- 不加粗糙分割线，融入背景
})

-- 快捷键：随时按 [c 跳回当前代码块最顶部的函数/类定义行
vim.keymap.set("n", "[c", function()
    tc.go_to_context()
end, { silent = true, desc = "Treesitter: Jump to context header (跳至当前代码块顶部声明)" })
