local telescope = require("telescope.builtin")

local builtin = require('telescope.builtin')
local local_marks = require('extended-marks.local')

local M = {}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
    { desc = "Diagnostic Open Float Window" })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end,
    { desc = "Diagnostic Go to the Prev Error" })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end,
    { desc = "Diagnostic Go to the Next Error" })
vim.keymap.set('n', '[e', function() vim.diagnostic.jump({ count = -1, severity = "ERROR" }) end,
    { desc = "Diagnostic Go to the Prev Error" })
vim.keymap.set('n', ']e', function() vim.diagnostic.jump({ count = 1, severity = "ERROR" }) end,
    { desc = "Diagnostic Go to the Next Error" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
    { desc = "Diagnostic Open Local List of Errors" })


local references = function() telescope.lsp_references({}) end
local implementations = function() telescope.lsp_implementations({}) end
local definitions = function() telescope.lsp_type_definitions({}) end
local lsp_all_symbols = function()
    builtin.lsp_document_symbols({ show_line = true })
end
local lsp_fields = function()
    builtin.lsp_document_symbols({
        symbols = { "field", "constant" },
        symbol_type_width = 0,
        show_line = true
    })
end
local lsp_methods = function()
    builtin.lsp_document_symbols(
        {
            symbols = { "method", "function" },
            symbol_type_width = 0,
            show_line = true
        })
end
local lsp_classes = function()
    builtin.lsp_document_symbols(
        {
            symbols = { "class" },
            symbol_type_width = 0,
            show_line = true
        })
end
local lsp_constructors = function()
    builtin.lsp_document_symbols(
        {
            symbols = { "constructor" },
            symbol_type_width = 0,
            show_line = true
        })
end

local lsp_dynamic_classes = function()
    builtin.lsp_dynamic_workspace_symbols(
        {
            fname_width = 80,
            symbol_width = 40,
            show_line = true
        })
end

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

        vim.keymap.set('n', '<leader>dd', function() vim.diagnostic.enable(false) end)
        vim.keymap.set('n', '<leader>ed', vim.diagnostic.enable)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
        vim.keymap.set('n', 'K', function() M.hover(nil, function(content) M.strip(content) end) end, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<leader>gd', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gi', implementations, opts)
        vim.keymap.set('n', 'gr', references, opts)

        vim.keymap.set('n', '<A-s>a', lsp_all_symbols, { desc = "Telescope: List [A]ll [S]ymbols" })
        vim.keymap.set('n', '<A-s>f', lsp_fields, { desc = "Telescope: List [F]ields" })
        vim.keymap.set('n', '<A-s>m', lsp_methods, { desc = "Telescope: List [M]ethods" })
        vim.keymap.set('n', '<A-s>c', lsp_classes, { desc = "Telescope: List [C]lasses" })
        vim.keymap.set('n', '<A-s>t', lsp_constructors, { desc = "Telescope: List Cons[t]ructors" })
        vim.keymap.set('n', "<A-w>", lsp_dynamic_classes, { desc = "Telescope: Search Dynamically [W]orkspace Symbols" })

        vim.api.nvim_create_autocmd('User', {
            pattern = 'UserLspConfigAttached',
            command = ''
        })
        vim.cmd('do User UserLspConfigAttached')

        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = ev.buf,
            callback = function(args)
                if (not args.match:match('*.java')) then
                    local_marks.update()
                    vim.lsp.buf.format()
                    local_marks.restore()
                end
            end
        })
    end,
})


--- @param params? table
--- @return fun(client: vim.lsp.Client): lsp.TextDocumentPositionParams
M.client_positional_params = function(params)
    local win = vim.api.nvim_get_current_win()
    return function(client)
        local ret = vim.lsp.util.make_position_params(win, client.offset_encoding)
        if params then
            ret = vim.tbl_extend('force', ret, params)
        end
        return ret
    end
end

function M.hover(config, handle_content)
    config = config or {}
    config.focus_id = "textDocument/hover"

    vim.lsp.buf_request_all(0, "textDocument/hover", M.client_positional_params(), function(results, ctx)
        if vim.api.nvim_get_current_buf() ~= ctx.bufnr then
            -- Ignore result since buffer changed. This happens for slow language servers.
            return
        end

        -- Filter errors from results
        local results1 = {} --- @type table<integer,lsp.Hover>

        for client_id, resp in pairs(results) do
            local err, result = resp.err, resp.result
            if err then
                vim.lsp.log.error(err.code, err.message)
            elseif result then
                results1[client_id] = result
            end
        end

        if #results1 == 0 then
            if config.silent ~= true then
                vim.notify('No information available')
            end
            return
        end

        local contents = {} --- @type string[]

        local nresults = #vim.tbl_keys(results1)

        local format = 'markdown'

        for client_id, result in pairs(results1) do
            if nresults > 1 then
                -- Show client name if there are multiple clients
                contents[#contents + 1] = string.format('# %s', vim.lsp.get_client_by_id(client_id).name)
            end
            if type(result.contents) == 'table' and result.contents.kind == 'plaintext' then
                if #results1 == 1 then
                    format = 'plaintext'
                    contents = vim.split(result.contents.value or '', '\n', { trimempty = true })
                else
                    -- Surround plaintext with ``` to get correct formatting
                    contents[#contents + 1] = '```'
                    vim.list_extend(
                        contents,
                        vim.split(result.contents.value or '', '\n', { trimempty = true })
                    )
                    contents[#contents + 1] = '```'
                end
            else
                vim.list_extend(contents, vim.lsp.util.convert_input_to_markdown_lines(result.contents))
            end
            contents[#contents + 1] = '---'
        end

        -- Remove last linebreak ('---')
        contents[#contents] = nil

        if vim.tbl_isempty(contents) then
            if config.silent ~= true then
                vim.notify('No information available')
            end
            return
        end

        if handle_content then
            handle_content(contents)
        end

        vim.lsp.util.open_floating_preview(contents, format, config)
    end)
end

-- Logic responsible for fixing symbolic references to classes
-- in java docs when using hover
M.strip = function(contents)
    assert(contents ~= nil and type(contents) == "table")

    if not vim.bo['filetype']:match("java") then
        return
    end

    for i, content in pairs(contents) do
        content = content:gsub("%[(.-)%]%(.-%%3C(.-)%%28(.-)%.class#.-%)", "[%1](%2.%3)");
        content = content:gsub("%s\\%[", "[");
        content = content:gsub("\\%]", "]");

        contents[i] = content
    end
end
