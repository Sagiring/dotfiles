require("mason").setup({
        ui = {
                icons = {
                        package_installed = "󰄳",
                        package_pending = "",
                        package_uninstalled = ""
                },
        },
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

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

local function get_jdtls_paths()
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

        return {
                java_bin = get_java21_bin(),
                lombok_jar = lombok_jar,
                launcher_jar = launcher_jar,
                config_dir = config_dir,
        }
end

local handlers = {
        function (server_name)
                require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                }
        end,
        ["pylsp"] = function ()
                lspconfig.pylsp.setup {
                        capabilities = capabilities,
                        settings = {
                                pylsp = {
                                        plugins = {
                                                pyflakes = { enabled = true },
                                                pylint = { enabled = false, debounce = 200, args = { '--ignore=E501,E231', '-' } },
                                                pylsp_mypy = { enabled = false },
                                                pycodestyle = { enabled = false, ignore = { 'E501', 'E231' }, maxLineLength = 120 },
                                        }
                                }
                        }
                }
        end,
        ["intelephense"] = function ()
                lspconfig.intelephense.setup {
                        capabilities = capabilities,
                        settings = {
                                intelephense = {
                                        files = {
                                                maxSize = 5000000,
                                        },
                                }
                        }
                }
        end,
        ["lua_ls"] = function ()
                lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                                Lua = {
                                        diagnostics = {
                                                globals = { "vim" }
                                        }
                                }
                        }
                }
        end,
        ["bashls"] = function ()
                lspconfig.bashls.setup {
                        capabilities = capabilities,
                        cmd = { "bash-language-server", "start" },
                        filetypes = { "sh" },
                        settings = {
                                bashIde = {
                                        globPattern = "*@(.sh|.inc|.bash|.command)"
                                }
                        },
                        single_file_support = true,
                }
        end,
        ["jsonls"] = function ()
                lspconfig.jsonls.setup {
                        capabilities = capabilities,
                        settings = {
                                json = {
                                        validate = { enable = true },
                                }
                        }
                }
        end,
        ["yamlls"] = function ()
                lspconfig.yamlls.setup {
                        capabilities = capabilities,
                        settings = {
                                yaml = {
                                        schemaStore = { enable = true }
                                }
                        }
                }
        end,
        ["jdtls"] = function ()
                local jdtls_paths = get_jdtls_paths()
                local java_runtimes = {
                        {
                                name = "JavaSE-1.8",
                                path = "/Library/Java/JavaVirtualMachines/zulu8.86.0.25-ca-fx-jdk8.0.452-macosx_aarch64",
                        },
                        {
                                name = "JavaSE-11",
                                path = "/Library/Java/JavaVirtualMachines/zulu11.80.21-ca-fx-jdk11.0.27-macosx_aarch64",
                        },
                        {
                                name = "JavaSE-21",
                                path = "/Library/Java/JavaVirtualMachines/zulu21.46.19-ca-fx-jdk21.0.9-macosx_aarch64",
                                default = true,
                        },
                }

                local valid_runtimes = {}
                for _, rt in ipairs(java_runtimes) do
                        if vim.fn.isdirectory(rt.path) == 1 then
                                table.insert(valid_runtimes, rt)
                        end
                end

                lspconfig.jdtls.setup {
                        capabilities = capabilities,
                        filetypes = { "java" },
                        root_dir = function(fname)
                                return util.root_pattern(".git", "mvnw", "gradlew", "pom.xml", "build.gradle")(fname)
                                        or vim.fs.dirname(fname)
                        end,
                        on_new_config = function(new_config, new_root_dir)
                                local project_name = vim.fs.basename(new_root_dir) or "default_project"
                                local hash = vim.fn.sha256(new_root_dir):sub(1, 8)
                                local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspaces/") .. project_name .. "_" .. hash
                                vim.fn.mkdir(workspace_dir, "p")

                                local cmd = {
                                        jdtls_paths.java_bin,
                                        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                                        "-Dosgi.bundles.defaultStartLevel=4",
                                        "-Declipse.product=org.eclipse.jdt.ls.core.product",
                                        "-Dlog.protocol=true",
                                        "-Dlog.level=ALL",
                                        "-Xms512m",
                                        "-Xmx2G",
                                        "--add-modules=ALL-SYSTEM",
                                        "--add-opens", "java.base/java.util=ALL-UNNAMED",
                                        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                                }

                                if vim.fn.filereadable(jdtls_paths.lombok_jar) == 1 then
                                        table.insert(cmd, "-javaagent:" .. jdtls_paths.lombok_jar)
                                end

                                if jdtls_paths.launcher_jar then
                                        table.insert(cmd, "-jar")
                                        table.insert(cmd, jdtls_paths.launcher_jar)
                                end

                                if jdtls_paths.config_dir and vim.fn.isdirectory(jdtls_paths.config_dir) == 1 then
                                        table.insert(cmd, "-configuration")
                                        table.insert(cmd, jdtls_paths.config_dir)
                                end

                                table.insert(cmd, "-data")
                                table.insert(cmd, workspace_dir)

                                new_config.cmd = cmd
                        end,
                        settings = {
                                java = {
                                        signatureHelp = { enabled = true },
                                        contentProvider = { preferred = "fernflower" },
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
                                                runtimes = valid_runtimes,
                                        },
                                }
                        }
                }
        end,
}

require("mason-lspconfig").setup({
        ensure_installed = {
                'pylsp',
                'intelephense',
                'lua_ls',
                'bashls',
                'jsonls',
                'yamlls',
                'jdtls',
        },
        handlers = handlers
})
