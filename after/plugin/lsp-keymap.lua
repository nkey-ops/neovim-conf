local vim = vim;

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float,
    { desc = "Diagnostic Open Float Window" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
    { desc = "Diagnostic Go to the Prev Error" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
    { desc = "Diagnostic Go to the Next Error" })
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist,
    { desc = "Diagnostic Open Local List of Errors" })


-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }

        vim.keymap.set('n', '<space>dd', vim.diagnostic.disable)
        vim.keymap.set('n', '<space>ed', vim.diagnostic.enable)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition)

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>f',
            function()
                Update_local_marks()
                vim.lsp.buf.format()
                Restore_local_marks()
            end, opts)
        --             vim.keymap.set('n', '<leader>lg', vim.lsp.buf.formatting_sync(nil, 1000), opts)
    end,
})
