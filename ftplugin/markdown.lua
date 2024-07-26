vim.keymap.set("n", "<C-p>", vim.cmd["MarkdownPreview"], {
    buffer = 0,
    desc = "MarkdownPreview"
})
vim.keymap.set("n", "<C-t>", vim.cmd["MarkdownPreviewToggle"], {
    buffer = 0,
    desc = "MarkdownPreviewToggle"
})
vim.keymap.set("n", "<C-s>", vim.cmd["MarkdownPreviewStop"], {
    buffer = 0,
    desc = "MarkdownPreviewStop"
})
