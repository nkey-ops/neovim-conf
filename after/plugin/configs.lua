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
