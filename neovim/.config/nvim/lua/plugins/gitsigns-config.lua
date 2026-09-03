local gitsigns = require('gitsigns')

gitsigns.setup({
    signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
    },
    -- GitLens 级体验：行末实时虚字展示作者、修改时间与提交信息
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 行末显示
        delay = 300,           -- 光标停顿 300ms 后浮现，不晃眼
        ignore_whitespace = false,
    },
    current_line_blame_formatter = ' <author>, <author_time:%Y-%m-%d %R> • <summary>',
    preview_config = {
        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation: 极速在上一个/下一个修改点跳转 (]c / [c)
        map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = "Git: Next hunk (跳到下一个修改点)" })

        map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = "Git: Prev hunk (跳到上一个修改点)" })

        -- Actions: 浮窗预览、单块撤销、Blame 开关
        map('n', '<leader>hp', gs.preview_hunk, { desc = "Git: Preview hunk (浮窗预览当前修改)" })
        map('n', '<leader>gp', gs.preview_hunk, { desc = "Git: Preview hunk (Space+gp 浮窗预览当前修改)" })
        map('n', '<leader>hr', gs.reset_hunk, { desc = "Git: Reset hunk (一键撤销当前修改块)" })
        map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = "Git: Reset selected hunk (撤销选中修改块)" })
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Git: Toggle line blame (开关行末 Blame 悬浮)" })
        map('n', '<leader>hd', gs.diffthis, { desc = "Git: Diff this (对比当前文件与 HEAD 的 Diff)" })
    end
})
