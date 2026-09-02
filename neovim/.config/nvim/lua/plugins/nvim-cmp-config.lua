local has_words_before = function()
        local _unpack = unpack or table.unpack
        local line, col = _unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

-- Set up nvim-cmp.
local cmp = require('cmp')

cmp.setup({
        -- 性能优化配置：防抖与节流，防止打字打结
        performance = {
                debounce = 60,
                throttle = 30,
                fetching_timeout = 500,
                max_view_entries = 30,
        },
        snippet = {
                expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                end,
        },
        window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
                ['<C-Up>'] = cmp.mapping.scroll_docs(-4),
                ['<C-Down>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),

                ['<Up>'] = cmp.mapping.select_prev_item(),
                ['<Down>'] = cmp.mapping.select_next_item(),
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                ['<C-j>'] = cmp.mapping.select_next_item(),

                ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                                cmp.confirm({ select = true })
                        elseif vim.fn["vsnip#available"](1) == 1 then
                                feedkey("<Plug>(vsnip-expand-or-jump)", "")
                        else
                                fallback()
                        end
                end, { "i", "s" }),

                ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                                cmp.select_prev_item()
                        elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                                feedkey("<Plug>(vsnip-jump-prev)", "")
                        else
                                fallback()
                        end
                end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
                { name = 'nvim_lsp', priority = 1000 },
                { name = 'vsnip', priority = 750 },
        }, {
                { 
                        name = 'buffer',
                        priority = 500,
                        keyword_length = 3,
                        -- 仅索引当前可视窗口内的缓冲区，避免扫描上百个后台文件造成主线程卡顿
                        option = {
                                get_bufnrs = function()
                                        local bufs = {}
                                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                                                bufs[vim.api.nvim_win_get_buf(win)] = true
                                        end
                                        return vim.tbl_keys(bufs)
                                end
                        }
                },
        })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
                { name = 'git' },
        }, {
                { name = 'buffer' },
        })
})

-- Use buffer source for `/` and `?`
cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
                { name = 'buffer' }
        }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
                { name = 'path' }
        }, {
                { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
})
