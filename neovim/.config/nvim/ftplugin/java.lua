local status_ok, jdtls = pcall(require, "jdtls")
if not status_ok then
    return
end

local function get_java21_bin()
    local candidates = {
        "/Library/Java/JavaVirtualMachines/zulu21.46.19-ca-fx-jdk21.0.9-macosx_aarch64/bin/java",
        vim.fn.expand("~/.jenv/versions/21/bin/java"),
        vim.fn.expand("~/.jenv/versions/21.0/bin/java"),
        vim.fn.expand("~/.jenv/versions/21.0.9/bin/java"),
        "/opt/homebrew/opt/openjdk@21/bin/java",
    }
    for _, path in ipairs(candidates) do
        if vim.fn.executable(path) == 1 then
            return path
        end
    end
    local globs = vim.fn.glob("/Library/Java/JavaVirtualMachines/*21*/bin/java", false, true)
    if #globs > 0 and vim.fn.executable(globs[1]) == 1 then
        return globs[1]
    end
    local globs_home = vim.fn.glob("/Library/Java/JavaVirtualMachines/*21*/Contents/Home/bin/java", false, true)
    if #globs_home > 0 and vim.fn.executable(globs_home[1]) == 1 then
        return globs_home[1]
    end
    return "java"
end

-- 获取工程根目录（优先基于 .git 定位最外层父工程，确保多模块子工程符号全互通）
local root_dir = require("jdtls.setup").find_root({ ".git" })
if not root_dir then
    root_dir = require("jdtls.setup").find_root({ "mvnw", "gradlew", "pom.xml", "build.gradle" })
end
if not root_dir then
    root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
end

-- 为每个工程建立独立的工作区隔离目录，防止多工程缓存锁冲突
local project_name = vim.fs.basename(root_dir) or "default_project"
local hash = vim.fn.sha256(root_dir):sub(1, 8)
local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspaces/") .. project_name .. "_" .. hash
vim.fn.mkdir(workspace_dir, "p")

-- 读取 Mason 安装的 JDTLS 启动器与依赖
local mason_jdtls = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local lombok_jar = mason_jdtls .. "/lombok.jar"
local launchers = vim.fn.glob(mason_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar", false, true)
local launcher_jar = launchers[1]

local os_config = "config_mac"
if vim.fn.has("mac") == 1 then
    os_config = "config_mac"
elseif vim.fn.has("unix") == 1 then
    os_config = "config_linux"
elseif vim.fn.has("win32") == 1 then
    os_config = "config_win"
end
local config_dir = mason_jdtls .. "/" .. os_config

-- 收集字节码反编译 Bundles (Fernflower)
local bundles = {}
local decompiler_jars = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/vscode-java-decompiler/server/*.jar", false, true)
for _, jar in ipairs(decompiler_jars) do
    table.insert(bundles, jar)
end

-- 扩展客户端能力 (支持 class 文件内容读取与自动导入重构)
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

-- 补全引擎能力
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- 针对大型 Java 工程的 JVM 深度调优启动命令
local cmd = {
    get_java21_bin(),
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.level=WARN",             -- 关键优化：彻底消除 ALL 级别日志轰炸，释放磁盘 I/O 与 CPU
    "-Xms1G",                       -- 初始堆内存 1G
    "-Xmx4G",                       -- 最大堆内存扩充至 4G，彻底杜绝大型项目 Full GC 卡顿与 OOM
    "-XX:+UseG1GC",                 -- 采用 G1GC 垃圾回收器，压低 STW 停顿延迟
    "-XX:+UseStringDeduplication",  -- 开启字符串去重，优化类元数据内存占用
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
}

if vim.fn.filereadable(lombok_jar) == 1 then
    table.insert(cmd, "-javaagent:" .. lombok_jar)
end

if launcher_jar then
    table.insert(cmd, "-jar")
    table.insert(cmd, launcher_jar)
end

if config_dir and vim.fn.isdirectory(config_dir) == 1 then
    table.insert(cmd, "-configuration")
    table.insert(cmd, config_dir)
end

table.insert(cmd, "-data")
table.insert(cmd, workspace_dir)

local config = {
    cmd = cmd,
    root_dir = root_dir,
    capabilities = capabilities,
    init_options = {
        bundles = bundles,
        extendedClientCapabilities = extendedClientCapabilities,
    },
    settings = {
        java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            autobuild = { enabled = false }, -- 关闭保存时激进的 target/classes 写入，消除多进程/多模块锁争用
            maxConcurrentBuilds = 4,
            completion = {
                favoriteStaticMembers = {
                    "org.junit.jupiter.api.Assertions.*",
                    "org.mockito.Mockito.*",
                    "org.assertj.core.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                useBlocks = true,
            },
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-1.8",
                        path = "/Library/Java/JavaVirtualMachines/zulu8.86.0.25-ca-fx-jdk8.0.452-macosx_aarch64",
                        default = true, -- 关键修正：默认指向 Java 1.8，严格匹配 vchat-game / vchat-web 的编译标准
                    },
                    {
                        name = "JavaSE-11",
                        path = "/Library/Java/JavaVirtualMachines/zulu11.80.21-ca-fx-jdk11.0.27-macosx_aarch64",
                    },
                    {
                        name = "JavaSE-21",
                        path = "/Library/Java/JavaVirtualMachines/zulu21.46.19-ca-fx-jdk21.0.9-macosx_aarch64",
                    },
                },
            },
        }
    },
    on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }
        -- Java 专属重构快捷键 (来自 nvim-jdtls 官方能力，整理导包调整为 Space+co，避免与 Space+o 跳转前缀冲突导致停顿等待)
        vim.keymap.set("n", "<leader>co", jdtls.organize_imports, vim.tbl_extend("force", opts, { desc = "Java: Organize Imports (自动导包/清理无用 import)" }))
        vim.keymap.set("n", "<leader>ev", jdtls.extract_variable, vim.tbl_extend("force", opts, { desc = "Java: Extract Variable (提取变量)" }))
        vim.keymap.set("v", "<leader>ev", [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]], vim.tbl_extend("force", opts, { desc = "Java: Extract Variable (选区提取变量)" }))
        vim.keymap.set("n", "<leader>ec", jdtls.extract_constant, vim.tbl_extend("force", opts, { desc = "Java: Extract Constant (提取常量)" }))
        vim.keymap.set("v", "<leader>ec", [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]], vim.tbl_extend("force", opts, { desc = "Java: Extract Constant (选区提取常量)" }))
        vim.keymap.set("v", "<leader>em", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], vim.tbl_extend("force", opts, { desc = "Java: Extract Method (选区提取方法)" }))
    end,
}

-- 启动或附加至 JDTLS 服务
jdtls.start_or_attach(config)
