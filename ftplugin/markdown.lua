vim.cmd("setlocal linebreak")
vim.cmd("setlocal breakindent")
vim.cmd("setlocal breakindentopt=shift:2,list:2")
vim.cmd("setlocal wrap")

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
vim.opt_local.conceallevel = 2
