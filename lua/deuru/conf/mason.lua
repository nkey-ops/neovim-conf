local mason_registry = require("mason-registry")
local Package = require("mason-core.package")

local packages =
{
    "checkstyle",
    "google-java-format",
    "sql-formatter",
    "java-debug-adapter",
    "java-test",
    -- "trivy",
}

for _, package_name in ipairs(packages) do
    if not mason_registry.is_installed(package_name) then
        print("Not Installed", package_name)
        local package = mason_registry.get_package(package_name)
        Package.install(package, {})
        print("Added to Installentiou queue", package_name)
    end
end

local lspconfig = require("lspconfig")
require('mason-lspconfig').setup(
    {
        automatic_installation = true,
        ensure_installed = {
            "marksman",
            "lemminx",
            "jdtls",
            "jsonls",
            "lua_ls",
            "yamlls",
            "sqlls",
            "html",
        },
        handlers = {
            marksman = lspconfig.marksman.setup({}),
            limminx = lspconfig.lemminx.setup({
                -- eclipse-lemminx/lemminx.git
                cmd = { 'java', '-jar', vim.fn.glob('~/.config/dotfiles/nvim/addons/org.eclipse.lemminx-uber.jar') },
            }),
            jdtls = nil,
            -- jdtls = require("lspconfig").jdtls.setup({}),
            jsonls = lspconfig.jsonls.setup({}),
            yamlss = lspconfig.yamlls.setup({}),
            sqlls = lspconfig.sqlls.setup({}),
            html = lspconfig.html.setup({}),
            lua_ls =
                lspconfig.lua_ls.setup {
                    on_init = function(client)
                        if client.workspace_folders then
                            local path = client.workspace_folders[1].name
                            if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
                                return
                            end
                        end

                        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                            runtime = {
                                -- Tell the language server which version of Lua you're using
                                -- (most likely LuaJIT in the case of Neovim)
                                version = 'LuaJIT'
                            },
                            -- Make the server aware of Neovim runtime files
                            workspace = {
                                checkThirdParty = false,
                                -- library = {
                                --     vim.env.VIMRUNTIME,
                                --     -- Depending on the usage, you might want to add additional paths here.
                                --     "${3rd}/luv/library",
                                --     "${3rd}/busted/library",
                                --     "/home/local/.local/share/nvim/lazy/mason-lspconfig.nvim",
                                --     "/home/local/table/extended-marks.nvim/"
                                -- },
                                -- -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
                                library = vim.api.nvim_get_runtime_file("", true)
                            },
                        })
                    end,
                    settings = {
                        Lua = {}
                    }
                }
        }
    })
