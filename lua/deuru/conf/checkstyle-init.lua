local null_ls = require('null-ls')
null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.checkstyle.with({
            timeout = 20000,
            filetypes = { "java" },
            args = function(params)
                return {
                    "-f",
                    "sarif",
                    "--tabWidth",
                    "4",
                    "-c",
                    "/google_checks.xml",
                    params.bufname,
                }
            end,
        }),
    }
})


-- local _, _ = pcall(vim.lsp.codelens.refresh)
-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--     pattern = { "*.java" },
--     callback = function()
--         local _, _ = pcall(vim.lsp.codelens.refresh)
--     end,
-- })
