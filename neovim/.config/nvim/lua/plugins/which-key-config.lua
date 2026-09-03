local ok, wk = pcall(require, "which-key")
if not ok then
    return
end

wk.setup({
    preset = "helix", -- 紧凑高级的主题预设
    delay = 300,      -- 停顿 300ms 后浮现菜单，完全不打扰快速打字
    icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
    },
    win = {
        border = "rounded",
        padding = { 1, 2 },
    },
})

-- 注册 Space 快捷键分组导航标签，让弹出浮窗层级一目了然
wk.add({
    { "<leader>f", group = "查找与检索 (Find)" },
    { "<leader>g", group = "Git 版本控制 (Git)" },
    { "<leader>s", group = "分屏与窗口 (Split)" },
    { "<leader>c", group = "代码重构与格式化 (Code)" },
    { "<leader>d", group = "语法诊断 (Diagnostics)" },
    { "<leader>b", group = "标签页管理 (Buffer)" },
})
