local ok, ibl = pcall(require, "ibl")
if not ok then
    return
end

ibl.setup({
    indent = {
        char = "│",
        tab_char = "│",
    },
    scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        injected_languages = false,
        highlight = { "Function", "Label" },
        priority = 500,
    },
    exclude = {
        filetypes = {
            "help",
            "NvimTree",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lspinfo",
            "TelescopePrompt",
            "TelescopeResults",
        },
        buftypes = {
            "terminal",
            "nofile",
            "quickfix",
            "prompt",
        },
    },
})
