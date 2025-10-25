local local_marks = require('extended-marks.local')

local telescope = require("telescope.builtin")
local builtin = require('telescope.builtin')

local references = function() telescope.lsp_references({}) end
local implementations = function() telescope.lsp_implementations({}) end
local definitions = function() telescope.lsp_type_definitions({}) end
local lsp_all_symbols = function()
    builtin.lsp_document_symbols({ show_line = true })
end

vim.diagnostic.config({ virtual_text = true })
local M = {}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions

local diag_prev = function() vim.diagnostic.jump({ count = -1 }) end
local diag_next = function() vim.diagnostic.jump({ count = 1 }) end
local diag_error_prev = function() vim.diagnostic.jump({ count = -1, severity = "ERROR" }) end
local diag_error_next = function() vim.diagnostic.jump({ count = 1, severity = "ERROR" }) end

local set = vim.keymap.set

set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Diagnostic Open Float Window" })
set('n', '[dd', diag_prev, { desc = "Diagnostic Go to the Prev Diagnostic" })
set('n', ']dd', diag_next, { desc = "Diagnostic Go to the Next Diagnostic" })
set('n', '[de', diag_error_prev, { desc = "Diagnostic Go to the Prev Diagnostic Error" })
set('n', ']de', diag_error_next, { desc = "Diagnostic Go to the Next Diagnostic Error" })
set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Diagnostic Open Local List of Errors" })


local toggle_diagnos = function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end
local hover = function()
    M.hover(
        {
            width = 80,
            height = 20,
            title = "[Documentation]",
            achor_bias = "above",
            relative = "win",
            border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" }
        }
        , function(content) M.strip(content) end)
end
local print_workspace = function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end

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
            symbols = { "class", "interface", "enummeration" },
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
    -- looking for lua and java clients, if only one is
    -- found then we can open dynamic workspace with it from any bufferr
    -- otherwise open the workspace related to the current buffer

    local clients = vim.lsp.get_clients({ name = "lua_ls" })
    local java_clients = vim.lsp.get_clients({ name = "jdtls" })
    for _, v in ipairs(java_clients) do table.insert(clients, v) end

    local bufnr = nil
    if #clients == 1 then
        bufnr = vim.lsp.get_buffers_by_client_id(clients[1].id)[1]
    end

    builtin.lsp_dynamic_workspace_symbols(
        {
            bufnr = bufnr,
            fname_width = 80,
            symbol_width = 40,
            show_line = true
        })
end

local enable_auto_format = true
vim.api.nvim_create_user_command("AutoFormat",
    function()
        enable_auto_format = not enable_auto_format
        print(string.format("AutoFormat=%s", enable_auto_format))
    end, {})


vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        local opts = { buffer = ev.buf }

        set('n', '<leader>dd', toggle_diagnos, opts)
        set('n', 'gD', vim.lsp.buf.declaration, opts)
        set('n', 'gd', vim.lsp.buf.definition)
        set('n', 'K', hover, opts)
        set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        set({ 'n', 'v' }, '<leader-f>', vim.lsp.buf.format, opts)

        set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        set('n', '<leader>wl', print_workspace, opts)
        set('n', '<leader>gd', vim.lsp.buf.type_definition, opts)
        set('n', '<leader>rn', vim.lsp.buf.rename, opts)

        set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        set('n', 'gi', implementations, opts)
        set('n', 'gr', references, opts)

        set('n', '<A-s>a', lsp_all_symbols, { desc = "Telescope: List [A]ll [S]ymbols" })
        set('n', '<A-s>f', lsp_fields, { desc = "Telescope: List [F]ields" })
        set('n', '<A-s>m', lsp_methods, { desc = "Telescope: List [M]ethods" })
        set('n', '<A-s>c', lsp_classes, { desc = "Telescope: List [C]lasses" })
        set('n', '<A-s>t', lsp_constructors, { desc = "Telescope: List Cons[t]ructors" })
        set('n', "<A-w>", lsp_dynamic_classes, { desc = "Telescope: Search Dynamically [W]orkspace Symbols" })

        vim.api.nvim_create_autocmd('User', {
            pattern = 'UserLspConfigAttached',
            command = ''
        })
        vim.cmd('do User UserLspConfigAttached')


        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = ev.buf,
            callback = function(args)
                if (not vim.bo[args.buf].filetype:match("java")
                        and not vim.bo[args.buf].filetype:match("markdown")
                        and enable_auto_format) then
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

        local buf = vim.lsp.util.open_floating_preview(contents, format, config)
        vim.api.nvim_buf_set_name(buf, "float.md")
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
