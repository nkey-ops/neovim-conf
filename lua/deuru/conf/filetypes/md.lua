vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "md" },
    callback = function(args)
        vim.cmd("set spell")
    end
})
