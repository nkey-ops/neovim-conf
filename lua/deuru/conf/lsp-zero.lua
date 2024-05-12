return function()
    local lsp_zero = require('lsp-zero')
    lsp_zero.extend_lspconfig()

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
            yamlss = require('lspconfig').yamlls.setup({}),
            lemminx = require('lspconfig').lemminx.setup({}),
            markdown = require('lspconfig').marksman.setup({}),
            jdtls = lsp_zero.noop,
            lua_ls = function()
                local lua_opts = lsp_zero.nvim_lua_ls()
                lua_opts.diagnostics = {
                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                }

                require('lspconfig').lua_ls.setup(lua_opts)
            end,
        }
    })


-- lsp_zero.defaults.cmp_mappings({
--     ['<Tab>'] = vim.NIL,
--     ['<CR>'] = vim.NIL
-- })

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
                -- Update_local_marks()
                vim.lsp.buf.format()
                -- Restore_local_marks()
            end, opts)
        --             vim.keymap.set('n', '<leader>lg', vim.lsp.buf.formatting_sync(nil, 1000), opts)
    end,
})
end
