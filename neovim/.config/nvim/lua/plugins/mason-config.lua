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
local handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
                require("lspconfig")[server_name].setup {
                        capabilities = capabilities,
                }
        end,
        -- ["ast_grep"] = function()
        --         require'lspconfig'.ast_grep.setup{
        --                 cmd = { "ast-grep", "lsp" },
        --                 filetypes = { "c", "cpp", "rust", "go", "java", "python", "javascript", "typescript", "html", "css", "kotlin", "dart", "lua" },
        --                 root_dir = vim.loop.cwd,
        --         }
        -- end,
        ["pylsp"] = function ()
                lspconfig.pylsp.setup {
                        capabilities = capabilities,
                        root_dir = vim.loop.cwd,
                        settings = {
                                pylsp = {
                                        plugins = {
                                                pyflakes={enabled=true},
        
                                                pylint = {enabled=false, debounce=200,args = {'--ignore=E501,E231', '-'}},
        
                                                pylsp_mypy={enabled=false},
        
                                                pycodestyle={enabled=false,ignore={'E501', 'E231'},maxLineLength=120},
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
        -- ["java_language_server"] = function ()
        --         lspconfig.java_language_server.setup {
        --                 filetypes = {"java"},
        --                 root_dir = vim.loop.cwd,
        --
        --         }
        -- end,
        ["bashls"] = function ()
                lspconfig.bashls.setup {
                        capabilities = capabilities,
                        cmd =  { "bash-language-server", "start" },
                        filetypes = { "sh" },
                        settings = {
                                bashIde = {
                                        globPattern = "*@(.sh|.inc|.bash|.command)"
                                }
                        },
                        single_file_support = true,
                        root_dir = vim.loop.cwd,

                }

        end,

}


require("mason-lspconfig").setup({
        ensure_installed = {'pylsp','lua_ls','bashls'},
        handlers = handlers
})





