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

-- ==============================================================================
-- 🎨 核心优化：彻底移除左侧孤立的 M/A 状态列与空白占位，直接顶格排版
-- ==============================================================================
do
    local hl = require("diffview.hl")
    local utils = require("diffview.utils")
    local config = require("diffview.config")
    local pl = utils.path

    local function render_file(comp, show_path, depth)
        local file = comp.context

        -- 彻底移除左侧的 file.status .. " " 字符列！不再有悬空的字母与白带
        if depth then
            comp:add_text(string.rep(" ", depth * 2))
        end

        local icon, icon_hl = hl.get_file_icon(file.basename, file.extension)
        comp:add_text(icon, icon_hl)

        -- 文件名字体颜色继承 Git 状态高亮 (新增为绿色，修改为蓝色/黄色)，直观辨识且零浪费空间
        local name_hl = file.active and "DiffviewFilePanelSelected" or hl.get_git_hl(file.status)
        comp:add_text(file.basename, name_hl)

        if file.stats then
            if file.stats.additions then
                comp:add_text(" " .. file.stats.additions, "DiffviewFilePanelInsertions")
                comp:add_text(", ")
                comp:add_text(tostring(file.stats.deletions), "DiffviewFilePanelDeletions")
            elseif file.stats.conflicts then
                local has_conflicts = file.stats.conflicts > 0
                comp:add_text(
                    " " .. (has_conflicts and file.stats.conflicts or config.get_config().signs.done),
                    has_conflicts and "DiffviewFilePanelConflicts" or "DiffviewFilePanelInsertions"
                )
            end
        end

        if file.kind == "conflicting" and not (file.stats and file.stats.conflicts) then
            comp:add_text(" !", "DiffviewFilePanelConflicts")
        end

        if show_path then
            comp:add_text(" " .. file.parent_path, "DiffviewFilePanelPath")
        end

        comp:ln()
    end

    local function render_file_list(comp)
        for _, file_comp in ipairs(comp.components) do
            render_file(file_comp, true)
        end
    end

    local function render_file_tree_recurse(depth, comp)
        local conf = config.get_config()

        if comp.name == "file" then
            render_file(comp, false, depth)
            return
        end

        if comp.name ~= "directory" then return end

        local dir = comp.components[1]
        local items = comp.components[2]
        local ctx = comp.context

        -- 彻底移除目录最前端的状态空白占位，从顶格/层级缩进直接开始！
        dir:add_text(string.rep(" ", depth * 2))
        dir:add_text(ctx.collapsed and conf.signs.fold_closed or conf.signs.fold_open, "DiffviewNonText")

        if conf.use_icons then
            dir:add_text(
                " " .. (ctx.collapsed and conf.icons.folder_closed or conf.icons.folder_open) .. " ",
                "DiffviewFolderSign"
            )
        end

        dir:add_text(ctx.name, "DiffviewFolderName")
        dir:ln()

        if not ctx.collapsed then
            for _, item in ipairs(items.components) do
                render_file_tree_recurse(depth + 1, item)
            end
        end
    end

    local function render_file_tree(comp)
        for _, c in ipairs(comp.components) do
            render_file_tree_recurse(0, c)
        end
    end

    local function render_files(listing_style, comp)
        if listing_style == "list" then
            return render_file_list(comp)
        end
        render_file_tree(comp)
    end

    -- 优雅替换默认的 FilePanel 渲染器 (伴随 dotfiles，永不被插件更新覆盖)
    package.loaded["diffview.scene.views.diff.render"] = function(panel)
        if not panel.render_data then
            return
        end

        panel.render_data:clear()
        local conf = config.get_config()
        local width = panel:infer_width()

        local comp = panel.components.path.comp

        comp:add_line(
            pl:truncate(pl:vim_fnamemodify(panel.adapter.ctx.toplevel, ":~"), width - 6),
            "DiffviewFilePanelRootPath"
        )

        if conf.show_help_hints and panel.help_mapping then
            comp:add_text("Help: ", "DiffviewFilePanelPath")
            comp:add_line(panel.help_mapping, "DiffviewFilePanelCounter")
            comp:add_line()
        end

        if #panel.files.conflicting > 0 then
            comp = panel.components.conflicting.title.comp
            comp:add_text("Conflicts ", "DiffviewFilePanelTitle")
            comp:add_text("(" .. #panel.files.conflicting .. ")", "DiffviewFilePanelCounter")
            comp:ln()

            render_files(panel.listing_style, panel.components.conflicting.files.comp)
            panel.components.conflicting.margin.comp:add_line()
        end

        local has_other_files = #panel.files.conflicting > 0 or #panel.files.staged > 0

        if #panel.files.working > 0 or not has_other_files then
            comp = panel.components.working.title.comp
            comp:add_text("Changes ", "DiffviewFilePanelTitle")
            comp:add_text("(" .. #panel.files.working .. ")", "DiffviewFilePanelCounter")
            comp:ln()

            render_files(panel.listing_style, panel.components.working.files.comp)
            panel.components.working.margin.comp:add_line()
        end

        if #panel.files.staged > 0 then
            comp = panel.components.staged.title.comp
            comp:add_text("Staged changes ", "DiffviewFilePanelTitle")
            comp:add_text("(" .. #panel.files.staged .. ")", "DiffviewFilePanelCounter")
            comp:ln()

            render_files(panel.listing_style, panel.components.staged.files.comp)
            panel.components.staged.margin.comp:add_line()
        end

        if panel.rev_pretty_name or (panel.path_args and #panel.path_args > 0) then
            local extra_info = utils.vec_join({ panel.rev_pretty_name }, panel.path_args or {})
            comp = panel.components.info.title.comp
            comp:add_line("Showing changes for:", "DiffviewFilePanelTitle")

            comp = panel.components.info.entries.comp
            for _, arg in ipairs(extra_info) do
                local relpath = pl:relative(arg, panel.adapter.ctx.toplevel)
                if relpath == "" then relpath = "." end
                comp:add_line(pl:truncate(relpath, width - 5), "DiffviewFilePanelPath")
            end
        end
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
        listing_style = "tree",             -- 目录树展示，按 i 可随时在 tree 与 list 之间秒切
        tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
        },
        win_config = {
            position = "left",
            width = 40,                     -- 适度加宽至 40，让 Java 文件名彻底不再被截断
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
            { "n", "i", actions.listing_style, { desc = "切换 树形(tree) / 列表(list) 视图" } },
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
