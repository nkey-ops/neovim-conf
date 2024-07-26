vim.keymap.set({ 'n' }, '<Esc>', function()
    local buffer = vim.fn.win_getid()

    if vim.api.nvim_win_is_valid(buffer) and
        vim.api.nvim_win_get_config(buffer).relative ~= '' then
        vim.api.nvim_win_close(buffer, false)
    end
end, { desc = "Close floating window" })

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = 'markdown',
    callback = function()
        vim.cmd("setlocal linebreak")
        vim.cmd("setlocal breakindent")
        vim.cmd("setlocal breakindentopt=shift:2,list:2")
        vim.cmd("setlocal wrap")
    end
})

vim.lsp.handlers['textDocument/hover'] =
    function(err, result, ctx, config)
        if (result.contents ~= nil
                and result.contents[1] ~= nil
                and result.contents[1].language ~= nil
                and result.contents[1].language:match('java')) then

            result.contents[2] = result.contents[2]:gsub("%[(.-)%]%(.-%%3C(.-)%%28(.-)%.class#.-%)", "[%1](%2.%3)");
            result.contents[2] = result.contents[2]:gsub("%s\\%[", "[");
            result.contents[2] = result.contents[2]:gsub("\\%]", "]");
        end

        local buf_id, win_id =
            vim.lsp.with(vim.lsp.handlers.hover, {})(err, result, ctx, config)

        vim.api.nvim_set_option_value("filetype", "lsp_markdown", { buf = buf_id })

        return buf_id, win_id
    end
