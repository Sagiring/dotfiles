local ok, diffview = pcall(require, "diffview")
if not ok then
    return
end

local actions = require("diffview.actions")

--- 一键退出 Diff 并直接在普通编辑窗口中停留在当前文件的当前行
local function close_diff_and_edit_at_cursor()
    local lib = require("diffview.lib")
    local view = lib.get_current_view()
    if not view then
        return
    end

    local file = view:infer_cur_file()
    if not file or not file.absolute_path then
        vim.cmd("DiffviewClose")
        return
    end

    local path = file.absolute_path
    local cursor = nil
    if view.cur_layout then
        local win = view.cur_layout:get_main_win()
        if win and vim.api.nvim_win_is_valid(win.id) then
            cursor = vim.api.nvim_win_get_cursor(win.id)
        end
    end

    vim.cmd("DiffviewClose")
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    if cursor then
        pcall(vim.api.nvim_win_set_cursor, 0, cursor)
    end
end

diffview.setup({
    diff_mappings = true,
    enhanced_diff_hl = true,
    view = {
        default = {
            layout = "diff2_horizontal",
            winbar_info = true,
        },
        merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
        },
        file_history = {
            layout = "diff2_horizontal",
            winbar_info = true,
        },
    },
    file_panel = {
        listing_style = "tree",             -- 目录树展示，结构清晰
        tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
        },
        win_config = {
            position = "left",
            width = 35,
        },
    },
    default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
    },
    keymaps = {
        disable_defaults = false,
        view = {
            -- 1. 退出 Diff 视图
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            { "n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },

            -- 2. 跳转到源文件并精确停留在当前行（两大模式）
            -- 模式 A：按 gf 或 <leader>ge，在主工作区 Tab 打开文件并定位到光标行（后台保留 Diff 视图，可随时切回）
            { "n", "gf", actions.goto_file_edit, { desc = "打开源文件并跳转到当前行 (保留 Diff 标签页)" } },
            { "n", "<leader>ge", actions.goto_file_edit, { desc = "打开源文件并跳转到当前行 (保留 Diff 标签页)" } },

            -- 模式 B：按 <leader>gq，直接关闭 Diffview 标签页，并停留在当前文件当前行开始编辑
            { "n", "<leader>gq", close_diff_and_edit_at_cursor, { desc = "关闭 Diff 并停留在当前行开始编辑" } },

            -- 模式 C：分屏或在新 Tab 中打开源文件并定位到当前行
            { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "水平分屏打开源文件并定位到当前行" } },
            { "n", "<C-w>gf", actions.goto_file_tab, { desc = "新标签页打开源文件并定位到当前行" } },
        },
        file_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            { "n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            { "n", "j", actions.next_entry, { desc = "下一条变更" } },
            { "n", "k", actions.prev_entry, { desc = "上一条变更" } },
            { "n", "<cr>", actions.select_entry, { desc = "打开该文件的对比视图" } },
            { "n", "o", actions.select_entry, { desc = "打开该文件的对比视图" } },
            { "n", "<tab>", actions.select_entry, { desc = "打开当前光标文件的对比视图 (杜绝回撤)" } },
            { "n", "l", actions.select_entry, { desc = "展开目录或打开文件对比" } },
            { "n", "h", actions.close_fold, { desc = "折叠目录" } },
            { "n", "R", actions.refresh_files, { desc = "刷新变更文件列表" } },
            { "n", "<leader>gf", actions.toggle_files, { desc = "开关侧边文件面板" } },

            -- 文件列表中按 gf 或 <leader>ge 或 <leader>gq 同样支持直达文件编辑
            { "n", "gf", actions.goto_file_edit, { desc = "打开源文件编辑 (保留 Diff 标签页)" } },
            { "n", "<leader>ge", actions.goto_file_edit, { desc = "打开源文件编辑 (保留 Diff 标签页)" } },
            { "n", "<leader>gq", close_diff_and_edit_at_cursor, { desc = "关闭 Diff 并打开源文件编辑" } },
        },
        file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close file history" } },
            { "n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close file history" } },
            { "n", "j", actions.next_entry, { desc = "上一个提交记录" } },
            { "n", "k", actions.prev_entry, { desc = "下一个提交记录" } },
            { "n", "<cr>", actions.select_entry, { desc = "查看该提交的 Diff" } },
            { "n", "o", actions.select_entry, { desc = "查看该提交的 Diff" } },
            { "n", "<tab>", actions.select_entry, { desc = "查看该提交的 Diff" } },
            { "n", "gf", actions.goto_file_edit, { desc = "打开历史文件版本并定位" } },
        },
    },
})

--- 智能检测主干分支并与共同祖先进行三点对比 (git diff {base}...HEAD)
local function open_diff_with_master()
    -- 检查是否处于 git 仓库
    local is_git = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("%s+", "")
    if is_git ~= "true" then
        vim.notify("当前目录不在 Git 仓库内，无法进行 Diff 对比", vim.log.levels.WARN)
        return
    end

    -- 优先级：远端 origin/master -> origin/main -> 本地 master -> 本地 main
    local candidates = { "origin/master", "origin/main", "master", "main" }
    local target_base = nil

    for _, branch in ipairs(candidates) do
        local check = vim.fn.system("git rev-parse --verify --quiet " .. branch .. " 2>/dev/null")
        if vim.v.shell_error == 0 and check ~= "" then
            target_base = branch
            break
        end
    end

    if not target_base then
        -- 未找到默认主干，询问用户输入基准分支
        vim.ui.input({ prompt = "未自动匹配到 master/main，请输入基准分支名 > " }, function(input)
            if input and input ~= "" then
                vim.notify("Diffview: 正在与 " .. input .. " 的共同祖先三点对比...", vim.log.levels.INFO)
                vim.cmd("DiffviewOpen " .. input .. "...")
            end
        end)
        return
    end

    vim.notify("Diffview: 正在与 " .. target_base .. " 的共同祖先 (Merge-Base) 进行三点增量对比...", vim.log.levels.INFO)
    -- 三点语法 target_base... 自动寻找共同祖先，且包含工作区未提交修改
    vim.cmd("DiffviewOpen " .. target_base .. "...")
end

-- 全局快捷键注册
local map = vim.keymap.set

-- 1. 查看本地当前未提交修改的 Diff
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git Diff: 查看本地未提交修改 (工作区 vs HEAD)" })

-- 2. 核心神器：智能与 master/main 共同祖先对比 (三点增量 Diff，发 PR / Review 专用)
map("n", "<leader>gm", open_diff_with_master, { desc = "Git Diff: 智能对比 master 共同祖先 (三点增量 Diff)" })

-- 3. 一键退出 Diff 视图，恢复原编辑器布局
map("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Git Diff: 关闭 Diffview 对比视图" })

-- 4. 查看当前文件的完整提交历史与 Diff 追溯
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git Diff: 查看当前文件 Git 提交历史 Diff" })

-- 5. 查看整个工程的全局提交历史
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Git Diff: 查看全工程 Git 提交历史" })

-- 6. 开关 Diff 侧边栏文件面板
map("n", "<leader>gf", "<cmd>DiffviewToggleFiles<cr>", { desc = "Git Diff: 开关文件树侧边栏" })
