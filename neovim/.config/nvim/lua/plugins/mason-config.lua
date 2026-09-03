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
                -- 由 ftplugin/java.lua 与 nvim-jdtls 专有插件接管，避免重复启动与双实例竞态
        end,
}

require("mason-lspconfig").setup({
        -- 禁用 automatic_enable，防止 mason-lspconfig 与 lspconfig.setup 重复启动两套服务导致【jdtls, jdtls】双实例严重耗尽内存
        automatic_enable = false,
        ensure_installed = {
                'pylsp',
                'intelephense',
                'lua_ls',
                'bashls',
                'jsonls',
                'yamlls',
                'jdtls',
        },
})

-- 显式遍历并执行各语言服务的配置 setup（兼容新版 mason-lspconfig 移除 handlers 参数并适配 Neovim 0.11）
local default_handler = handlers[1]
local installed_servers = require("mason-lspconfig").get_installed_servers()
for _, server in ipairs(installed_servers) do
        if handlers[server] then
                handlers[server]()
        elseif default_handler then
                default_handler(server)
        end
end
