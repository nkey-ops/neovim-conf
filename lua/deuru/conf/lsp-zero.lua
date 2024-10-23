return function()
    -- local lsp_zero = require('lsp-zero')
    -- lsp_zero.extend_lspconfig()
    --
    -- lsp_zero.on_attach(function(_, bufnr)
    --     lsp_zero.default_keymaps({ buffer = bufnr })
    -- end)

    require('mason-lspconfig').setup({
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
            marksman = require('lspconfig').marksman.setup({}),
            limminx = require("lspconfig").lemminx.setup({}),
            -- jdtls = lsp_zero.noop,
            jdtls = nil,
            jsonls = require('lspconfig').jsonls.setup({}),
            yamlss = require('lspconfig').yamlls.setup({}),
            sqlls = require('lspconfig').sqlls.setup({}),
            html = require('lspconfig').html.setup({}),
            lua_ls = require('lspconfig').lua_ls.setup({}),

            -- lua_ls = function()
            --     local lua_opts = lsp_zero.nvim_lua_ls()
            --
            --     lua_opts.runtime = {
            --         -- Tell the language server which version of Lua you're using
            --         -- (most likely LuaJIT in the case of Neovim)
            --         version = 'LuaJIT',
            --     }
            --     lua_opts.diagnostics = {
            --         globals = { "vim", "it", "describe", "before_each", "after_each" },
            --     }
            --
            --     lua_opts.workspace = {
            --         checkThirdParty = false,
            --         -- library = {
            --         --     vim.env.VIMRUNTIME,
            --         --     "${3rd}/luv/library",
            --         --     "${3rd}/busted/library",
            --         -- },
            --         library = vim.api.nvim_get_runtime_file("", true)
            --     }
            --
            --     require('lspconfig').lua_ls.setup(lua_opts)
            -- end,
        }
    })
end
