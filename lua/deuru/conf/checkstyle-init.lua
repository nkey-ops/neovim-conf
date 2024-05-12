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
                    "-c",
                    vim.fn.glob('~/.config/nvim') .. '/addons/google_checks.xml',
                    params.bufname,
                }
            end,

            -- extra_args = { "-c",
            --      mason_pack .. "/checkstyle/google_checks.xml" },
            -- -- or "/sun_checks.xml" or path to self written rules
        }),
    }
})


local _, _ = pcall(vim.lsp.codelens.refresh)
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*.java" },
    callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
    end,
})
