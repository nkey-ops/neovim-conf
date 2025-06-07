local sql_formatter = vim.fn.glob(
    "~/.local/share/nvim/mason/packages/sql-formatter/node_modules/sql-formatter/bin/sql-formatter-cli.cjs")

local format = function()
    local file_path = vim.api.nvim_buf_get_name(0)
    vim.cmd('silent !' .. sql_formatter .. ' ' .. file_path .. ' -o ' .. file_path)
end

vim.keymap.set("n", "<leader>f", format, { buffer = 0, desc = "SQL: [F]ormat" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "mysql", "sql", "psql" },
    callback = function(args)
        vim.keymap.set("n", "<leader>f", format, { buffer = args.buf, desc = "SQL: [F]ormat" })

        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2

        vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = args.buf,
            callback = function()
                format()
            end
        })
    end
})
