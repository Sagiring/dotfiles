require("bufferline").setup {
        highlights = require("catppuccin.groups.integrations.bufferline").get(),
        options = {
                -- 使用 nvim 内置lsp
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

