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
    callback = function(args)
        require("cmp").setup.buffer {
            sources = {
                { name = "vim-dadbod-completion" }
            }
        }
        vim.keymap.set('n', '<leader>r', ':normal vip<CR><PLUG>(DBUI_ExecuteQuery)',
            { buffer = args.buf })
    end,
})
vim.g.db_ui_use_nerd_fonts = 1
vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<CR>")
vim.g.db_ui_execute_on_save            = 0
vim.g.db_ui_disable_info_notifications = 1
