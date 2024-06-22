return function()
    local lsp_zero = require('lsp-zero')
    lsp_zero.extend_lspconfig()

    -- local local_marks = require('extended-marks.local-marks')
    lsp_zero.on_attach(function(_, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr })
    end)

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
            lemminx = require('lspconfig').lemminx.setup(
                {
                    settings = {
                        xml = { catalogs = "/home/local/.config/nvim/addons/Default-xml.xml" }
                    }

                }),
            jdtls = lsp_zero.noop,
            jsonls = require('lspconfig').jsonls.setup({}),
            yamlss = require('lspconfig').yamlls.setup({}),
            sqlls = require('lspconfig').sqlls.setup({}),
            html = require('lspconfig').html.setup({}),

            -- require 'lspconfig'.lua_ls.setup {
            --     on_init = function(client)
            --         local path = client.workspace_folders[1].name
            --         if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            --             return
            --         end
            --
            --         client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            --             runtime = {
            --                 -- Tell the language server which version of Lua you're using
            --                 -- (most likely LuaJIT in the case of Neovim)
            --                 version = 'LuaJIT'
            --             },
            --             -- Make the server aware of Neovim runtime files
            --             workspace = {
            --                 checkThirdParty = false,
            --                 -- library = {
            --                 --     vim.env.VIMRUNTIME,
            --                 --     -- Depending on the usage, you might want to add additional paths here.
            --                 --     -- "${3rd}/luv/library",
            --                 --     "${3rd}/busted/library",
            --                 -- }
            --                 -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            --                 library = vim.api.nvim_get_runtime_file("", true)
            --             }
            --         })
            --     end,
            --     settings = {
            --         Lua = {}
            --     } }
            lua_ls = function()
                local lua_opts = lsp_zero.nvim_lua_ls()

                lua_opts.runtime = {
                    -- Tell the language server which version of Lua you're using
                    -- (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                }
                lua_opts.diagnostics = {
                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                }

                lua_opts.workspace = {
                    checkThirdParty = false,
                    -- library = {
                    --     vim.env.VIMRUNTIME,
                    --     "${3rd}/luv/library",
                    --     "${3rd}/busted/library",
                    -- },
                    library = vim.api.nvim_get_runtime_file("", true)
                }

                require('lspconfig').lua_ls.setup(lua_opts)
            end,
        }
    })

    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
        { desc = "Diagnostic Open Float Window" })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
        { desc = "Diagnostic Go to the Prev Error" })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
        { desc = "Diagnostic Go to the Next Error" })
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
        { desc = "Diagnostic Open Local List of Errors" })

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
            vim.bo[ev.buf].omnifunc = nil

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }

            vim.keymap.set('n', '<leader>dd', vim.diagnostic.disable)
            vim.keymap.set('n', '<leader>ed', vim.diagnostic.enable)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set('n', '<leader>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set({ 'n', 'v' }, '<leader>f',
                function()
                    -- local_marks.update_local_marks()
                    vim.lsp.buf.format()
                    -- local_marks.restore_local_marks()
                end
                , opts)
            --             vim.keymap.set('n', '<leader>lg', vim.lsp.buf.formatting_sync(nil, 1000), opts)

            vim.api.nvim_create_autocmd('User', {
                pattern = 'UserLspConfigAttached',
                command = ''
            })
            vim.cmd('do User UserLspConfigAttached')

            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = ev.buf,
                callback = function()
                    vim.lsp.buf.format()
                end
            })
        end,
    })
end
