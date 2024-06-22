vim.g.db_ui_save_location = '~/.config/db_ui'
vim.g.db_ui_use_nerd_fonts = 1

-- disable folding
vim.api.nvim_create_autocmd("FileType", {
    pattern = "dbout",
    callback = function()
        vim.wo.foldenable = false
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "sql",
        "mysql",
        "plsql",
    },
    callback = function()
        require("cmp").setup.buffer {
            sources = {
                { name = "vim-dadbod-completion" }
            }
        }
    end,
})
vim.g.db_ui_use_nerd_fonts = 1
vim.keymap.set("n", "<leader>du", "<cmd>DBUIToggle<CR>")
