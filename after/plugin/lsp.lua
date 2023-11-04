--require'cmp'.setup {
--  sources = {
--    { name = 'nvim_lsp' }
--  }
--}
--require('cmp_nvim_lsp')

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
end)


-- (Optional) Configure lua language server for neovim
--require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local handlers = {
    ['lua_ls'] = function()
        require('lspconfig')['lua_ls'].setup {
            --   filetypes = {'lua'},
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

require('mason').setup({})
require('mason-lspconfig').setup({ handlers = handlers })




lsp.setup()
