-- Set leader key before loading plugins and keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General options
local opt = vim.opt

-- Tab & Indentation: 4 spaces
opt.tabstop = 4        -- 1 个 Tab 宽度对应 4 个空格
opt.shiftwidth = 4     -- 自动缩进、换行缩进移动 4 个空格
opt.softtabstop = 4    -- 插入模式下按 Backspace 一次删除 4 个空格
opt.expandtab = true   -- 按 Tab 键自动展开为 4 个空格
opt.autoindent = true  -- 继承上一行的缩进
opt.smartindent = true -- 智能代码块缩进

-- Editor behaviors
opt.clipboard = "unnamedplus"   -- Sync with system clipboard
opt.undofile = true             -- Enable persistent undo history
opt.cursorline = true           -- Highlight current line
opt.termguicolors = true        -- True color support
opt.signcolumn = "yes"          -- Always show sign column
opt.updatetime = 250            -- Faster completion and diagnostics
opt.timeoutlen = 600            -- Keymap timeout (毫秒)，给快捷键充足的前缀输入等待时间

require('keymaps')

-- theme
require('plugins.catppuccin-config')

-- Plugins
require('plugins.lualine-config')
require('plugins.nvim-tree-config')
require('plugins.nvim-treesitter-config')
require('plugins.mason-config')
require('plugins.nvim-cmp-config')
require('plugins.commit-config')
require('plugins.autopairs-config')
require('plugins.bufferline-config')
require('plugins.gitsigns-config')
require('plugins.telescope-config')

-- Java JDTLS 手动安全隔离拉起机制
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(ev)
    local java21_bin = "/Library/Java/JavaVirtualMachines/zulu21.46.19-ca-fx-jdk21.0.9-macosx_aarch64/bin/java"
    local equinox_jar = vim.fn.glob(vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"))
    local config_dir = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/config_mac")
    local lombok_jar = vim.fn.glob(vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/lombok.jar"))
    
    local util = require("lspconfig.util")
    local root_dir = util.root_pattern(".git", "pom.xml", "mvnw", "gradlew")(vim.api.nvim_buf_get_name(ev.buf))
      or vim.fn.getcwd()
    local project_name = vim.fs.basename(root_dir) or "default"
    local workspace_dir = vim.fn.expand("~/.local/share/nvim/jdtls-workspace/") .. project_name

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local cmd = {
      java21_bin,
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dfile.encoding=utf8",
      "-XX:+UseParallelGC",
      "-XX:GCTimeRatio=4",
      "-XX:AdaptiveSizePolicyWeight=90",
      "-Dsun.zip.disableMemoryMapping=true",
      "-Xms256m",
      "-Xmx1024m",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "--add-opens", "java.base/sun.nio.fs=ALL-UNNAMED",
      "-jar", equinox_jar,
      "-configuration", config_dir,
      "-data", workspace_dir .. "/data",
    }
    if lombok_jar ~= "" then
      table.insert(cmd, 16, "-javaagent:" .. lombok_jar)
    end

    local handlers = {
      ['$/progress'] = function(_, result, ctx)
        local val = result.value
        if not val or not val.kind then return end
        if val.kind == "begin" or val.kind == "report" then
          local title = val.title or ""
          local msg = val.message and (": " .. val.message) or ""
          local percent = val.percentage and string.format(" %d%%", val.percentage) or ""
          _G.jdtls_progress_msg = string.format("󰑮 [JDTLS] %s%s%s", title, msg, percent)
        elseif val.kind == "end" then
          _G.jdtls_progress_msg = ""
        end
        pcall(vim.cmd, "redrawstatus")
      end
    }

    vim.lsp.start({
      name = "jdtls",
      cmd = cmd,
      root_dir = root_dir,
      capabilities = capabilities,
      handlers = handlers,
      settings = {
        java = {
          autobuild = { enabled = false },
          maxConcurrentBuilds = 1,
          import = {
            generatesMetadataFilesAtProjectRoot = false,
            maven = {
              enabled = true,
              downloadSources = false,
              updateSnapshots = false,
            },
            gradle = { enabled = false },
          },
          references = { includeDecompiledSources = false },
          configuration = {
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = "/Library/Java/JavaVirtualMachines/zulu8.86.0.25-ca-fx-jdk8.0.452-macosx_aarch64/zulu-8.jdk/Contents/Home",
              },
              {
                name = "JavaSE-11",
                path = "/Library/Java/JavaVirtualMachines/zulu11.80.21-ca-fx-jdk11.0.27-macosx_aarch64/zulu-11.jdk/Contents/Home",
              },
              {
                name = "JavaSE-21",
                path = "/Library/Java/JavaVirtualMachines/zulu21.46.19-ca-fx-jdk21.0.9-macosx_aarch64/zulu-21.jdk/Contents/Home",
                default = true,
              },
            },
          },
        },
      },
    })
  end,
})
      name = "jdtls",
      cmd = cmd,
      root_dir = root_dir,
      capabilities = capabilities,
      settings = {
        java = {
          autobuild = { enabled = false },
          maxConcurrentBuilds = 1,
          import = {
            generatesMetadataFilesAtProjectRoot = false,
            maven = {
              enabled = true,
              downloadSources = false,
              updateSnapshots = false,
            },
            gradle = { enabled = false },
          },
          references = { includeDecompiledSources = false },
          configuration = {
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = "/Library/Java/JavaVirtualMachines/zulu8.86.0.25-ca-fx-jdk8.0.452-macosx_aarch64/zulu-8.jdk/Contents/Home",
              },
              {
                name = "JavaSE-11",
                path = "/Library/Java/JavaVirtualMachines/zulu11.80.21-ca-fx-jdk11.0.27-macosx_aarch64/zulu-11.jdk/Contents/Home",
              },
              {
                name = "JavaSE-21",
                path = "/Library/Java/JavaVirtualMachines/zulu21.46.19-ca-fx-jdk21.0.9-macosx_aarch64/zulu-21.jdk/Contents/Home",
                default = true,
              },
            },
          },
        },
      },
    })
  end,
})

local old_notify = vim.notify
vim.notify = function(msg, ...)
  if type(msg) == "string" and msg:match("deprecated") then
    return
  end
  old_notify(msg, ...)
end
