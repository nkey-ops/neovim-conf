vim.keymap.set({ 'n' }, '<Esc>', function()
    local buffer = vim.fn.win_getid()

    if vim.api.nvim_win_is_valid(buffer) and
        vim.api.nvim_win_get_config(buffer).relative ~= '' then
        vim.api.nvim_win_close(buffer, false)
    end
end, { desc = "Close floating window" })

-- Note: it's not done through FileType because of the issues with lsp.hanlers
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = '*.md',
    callback = function()
        vim.cmd("setlocal linebreak")
        vim.cmd("setlocal breakindent")
        vim.cmd("setlocal breakindentopt=shift:2,list:2")
        vim.cmd("setlocal wrap")
    end
})

local stripP = function(string)
    assert(string ~= nil and type(string) == "string")

    string = string:gsub("%[(.-)%]%(.-%%3C(.-)%%28(.-)%.class#.-%)", "[%1](%2.%3)");
    string = string:gsub("%s\\%[", "[");
    string = string:gsub("\\%]", "]");
    return string
end

vim.lsp.handlers['textDocument/hover'] =
    function(err, result, ctx, config)
        local is_java = false
        if (result ~= nil
                and result.contents ~= nil
                and result.contents[1] ~= nil
                and result.contents[1].language ~= nil
                and result.contents[1].language:match('java')) then
            result.contents[2] = stripP(result.contents[2]);
            is_java = true
        end

        local buf, win_id =
            vim.lsp.with(vim.lsp.handlers.hover, {})(err, result, ctx, config)

        if is_java and buf ~= nil and vim.api.nvim_buf_is_valid(buf) and
            string.match(
                vim.api.nvim_get_option_value("filetype", { buf = buf }), "markdown") then
            vim.api.nvim_set_option_value("filetype", "lsp_markdown", { buf = buf })
        end

        return buf, win_id
    end
