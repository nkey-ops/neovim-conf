vim.g.db_ui_save_location = '~/.config/db_ui'
-- disable folding
vim.api.nvim_create_autocmd("FileType", {
    pattern = "dbout",
    callback = function()
        vim.wo.foldenable = false
    end,
})

vim.g.db_ui_use_nerd_fonts = 1
vim.keymap.set("n", "<leader>du", "<cmd>DBUIToggle<CR>")
