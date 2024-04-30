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

local handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
                require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                }
        end,
        ["pylsp"] = function ()
                local lspconfig = require("lspconfig")
                lspconfig.pylsp.setup {
                        capabilities = capabilities,
                        settings = {
                                pylsp = {
                                        plugins = {
                                                pyflakes={
                                                        enabled=true
                                                },
                                                pylint = {
                                                        args = {'--ignore=E501,E231', '-'}, enabled=false, debounce=200
                                                },
                                                pylsp_mypy={
                                                        enabled=false
                                                },
                                                pycodestyle={
                                                        enabled=false,
                                                        ignore={'E501', 'E231'},
                                                        maxLineLength=120},
                                        }
                                }
                        }
                }

        end,
        ["lua_ls"] = function ()
                local lspconfig = require("lspconfig")
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
}


require("mason-lspconfig").setup({
        handlers = handlers
})





