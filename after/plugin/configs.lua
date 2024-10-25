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
