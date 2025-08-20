local rest = require("rest-nvim")
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = 'http',
    callback = function(args)
        vim.keymap.set("n", "<leader>r", "<cmd>vertical botright Rest run<CR>",
            { desc = "RestNvim: [R]un Curl Command", buffer = args.buf })
        -- vim.keymap.set("n", "<leader>p", "<cmd>Resatk",
        --     { desc = "RestNvim: [P]review Curl Command", buffer = args.buf })
        vim.keymap.set("n", "<leader>l", "<cmd>Rest last<CR>",
            { desc = "RestNvim: Run [L]ast Curl Command", buffer = args.buf })
        vim.opt_local.expandtab = true
    end
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "json",
    callback = function(ev)
        vim.bo[ev.buf].formatprg = "jq"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "html",
    callback = function(ev)
        vim.bo[ev.buf].formatprg = "tidy -i -q --tidy-mark no --force-output yes --show-errors 0"
    end,
})
--
-- vim.api.nvim_create_autocmd({ "FileType" }, {
--     pattern = "*", -- for some reason pattern
--     callback = function(args)
--         if args.file:match('.+#Headers') then
--             local wins = vim.api.nvim_list_wins()
--             for i, x in pairs(wins) do
--                 P(x)
--                 P(vim.api.nvim_win_get_config(x))
--             end
--
--             local win = vim.fn.bufwinid(args.buf)
--             -- P(args)
--             -- P(win)
--             vim.wo[win + 1].wrap = true
--         end
--     end
-- })
