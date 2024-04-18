-- local lsp = require('lsp-zero').preset({})
local lsp = require('lsp-zero')
local mason = require('mason').setup({})
local mason_lspconfig = require('mason-lspconfig')

-- TOFIX double call
dofile("/home/deuru/.config/nvim/after/plugin/mason.lua")

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
end)


-- (Optional) Configure lua language server for neovim
--require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local handlers = {
    -- ['jdtls'] = require('lsp-zero').noop,
    ['jdtls'] = function()
        require('lspconfig').jdtls.setup { autostart = false }
    end,
    ['lua_ls'] = function()
        require('lspconfig')['lua_ls'].setup {
            filetypes = { 'lua' },
            capabilities = {},
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using
                        -- (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = {
                            'vim',
                            'require'
                        },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {
                        enable = false,
                    },
                }
            }
        }
    end
}

mason_lspconfig.setup({
    handlers = handlers,
})

lsp.setup()
