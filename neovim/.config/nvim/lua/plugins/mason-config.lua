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
}

require("mason-lspconfig").setup({
        ensure_installed = {
                'pylsp',
                'lua_ls',
                'bashls',
                'jsonls',
                'yamlls',
        },
        handlers = handlers
})
