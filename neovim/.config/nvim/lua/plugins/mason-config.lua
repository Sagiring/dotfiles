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
                local java21_bin = "/Library/Java/JavaVirtualMachines/zulu21.46.19-ca-fx-jdk21.0.9-macosx_aarch64/bin/java"

                lspconfig.jdtls.setup {
                        capabilities = capabilities,
                        cmd = {
                                "jdtls",
                                "--java-executable", java21_bin,
                                "--jvm-arg=-Xms256m",
                                "--jvm-arg=-Xmx1024m",
                        },
                        root_dir = util.root_pattern(".git", "pom.xml", "mvnw", "gradlew"),
                        settings = {
                                java = {
                                        -- 限制并发构建，关闭后台自动频繁全量构建，防止高负载打满 CPU/内存
                                        autobuild = { enabled = false },
                                        maxConcurrentBuilds = 1,
                                        -- 彻底禁止在项目物理源码根目录下生成 .project / .classpath / .factorypath / .settings/
                                        -- 所有元数据与编译索引全部隔离在外部的 workspace_dir 中
                                        import = {
                                                generatesMetadataFilesAtProjectRoot = false,
                                                maven = {
                                                        enabled = true,
                                                        downloadSources = false,
                                                        updateSnapshots = false,
                                                },
                                                gradle = {
                                                        enabled = false,
                                                },
                                        },
                                        references = {
                                                includeDecompiledSources = false,
                                        },
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
                                                }
                                        },
                                        completion = {
                                                favoriteStaticMembers = {
                                                        "org.junit.Assert.*",
                                                        "org.junit.Assume.*",
                                                        "org.junit.jupiter.api.Assertions.*",
                                                        "org.junit.jupiter.api.Assumptions.*",
                                                        "org.mockito.Mockito.*",
                                                        "org.mockito.ArgumentMatchers.*",
                                                },
                                        },
                                }
                        }
                }
        end,
}

require("mason-lspconfig").setup({
        ensure_installed = {
                'pylsp',
                'lua_ls',
                'bashls',
                'jsonls',
                'yamlls',
                'jdtls',
        },
        handlers = handlers
})
