vim.api.nvim_create_autocmd('FileType', {
    desc = "Preview for markdown",
    pattern = { 'markdown', 'md' },

    callback = function(args)
        print("hell")
        vim.keymap.set("n", "<leader>mp", vim.cmd["MarkdownPreview"], {
            buffer = args.buf,
            desc = "MarkdownPreview"
        })
        vim.keymap.set("n", "<leader>mt", vim.cmd["MarkdownPreviewToggle"], {
            buffer = args.buf,
            desc = "MarkdownPreviewToggle"
        })
        vim.keymap.set("n", "<leader>ms", vim.cmd["MarkdownPreviewStop"], {
            buffer = args.buf,
            desc = "MarkdownPreviewStop"
        })
    end
})
