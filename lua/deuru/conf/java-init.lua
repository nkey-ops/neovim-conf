-- Close buffers with ".class" extension to free up space
local mason_registry = require('mason-registry')
local google_java_format_jar =
    mason_registry
    .get_package("google-java-format")
    :get_install_path() .. "/google-java-format-*.jar"

require('formatter').setup {
    filetype = {
        java = {
            function()
                return {
                    exe = 'java',
                    args = { '-jar', google_java_format_jar, vim.api.nvim_buf_get_name(0) },
                    stdin = true
                }
            end
        }
    }
}


local attach_java_configs = function()
    vim.api.nvim_create_autocmd('User', {
        group = vim.api.nvim_create_augroup('JavaLsp', {}),
        desc = "Creats buffer local settings for files with the '*.java' extension",
        pattern = 'UserLspConfigAttached',

        callback = function(args)
            if not string.match(vim.api.nvim_buf_get_name(args.buf), '%.java$') then
                return
            end

            local jdtls = require("jdtls")
            -- Keymaps
            vim.keymap.set('n', '<leader>o',
                function() jdtls.organize_imports() end,
                { desc = "Java Import", silent = true, buffer = args.buf }
            )

            vim.keymap.set({ 'n', 'v' }, '<leader>ev', function()
                    local mode = vim.api.nvim_get_mode()['mode']
                    if mode == 'v' or mode == 'V' then
                        Exit_visual()
                        jdtls.extract_variable({ visual = true })
                    else
                        jdtls.extract_variable()
                    end
                end,
                {
                    desc = "Java [E]xtract [V]ariable",
                    silent = true,
                    buffer = args.buf
                }
            )
            vim.keymap.set({ 'n', 'v' }, '<leader>em', function()
                    local mode = vim.api.nvim_get_mode()['mode']
                    if mode == 'v' or mode == 'V' then
                        Exit_visual()
                        jdtls.extract_method({ visual = true })
                    else
                        jdtls.extract_method()
                    end
                end,
                {
                    desc = "Java [E]xtract [M]ethod",
                    silent = true,
                    buffer = args.buf
                }
            )
            vim.keymap.set('n', "<leader>f",
                '<cmd>FormatWrite java<CR>',
                { desc = "Java [F]ormat", buffer = args.buf }
            )

            vim.keymap.set("n", "<leader>jc",
                "<cmd>JdtCompile<CR>",
                { desc = "Java JdtCompile", silent = true, buffer = args.buf }
            )
            vim.keymap.set('n', '<leader>jo',
                function() jdtls.jol() end,
                { desc = "Java [Jo]l", silent = true, buffer = args.buf }
            )
            vim.keymap.set("n", "<leader>tt",
                function() jdtls.test_class({}) end,
                { desc = "Java Test Class", silent = true, buffer = args.buf }
            )
            vim.keymap.set("n", "<leader>tm",
                function() jdtls.test_nearest_method({}) end,
                {
                    desc = "Java [T]est Nearest [M]ethod",
                    silent = true,
                    buffer = args.buf
                }
            )
            vim.keymap.set("n", "<leader>tp",
                function() jdtls.pick_test({}) end,
                { desc = "Java [P]ick [T]est", silent = true, buffer = args.buf }
            )
            vim.keymap.set("n", "<leader>tg",
                function() jdtls.tests.generate({}) end,
                { desc = "Java [G]enerate [T]est", silent = true, buffer = args.buf }
            )
            vim.keymap.set("n", "<leader>tb",
                function() jdtls.tests.goto_subjects() end,
                { desc = "Java [G]o to subjects", silent = true, buffer = args.buf }
            )
            vim.keymap.set("n", "<leader>ud",
                "<cmd>JdtUpdateDebugConf<CR>",
                { desc = "Java JdtUpdateDebugConf", silent = true, buffer = args.buf }
            )

            -- settings
            vim.cmd("setlocal softtabstop=2")
            vim.cmd("setlocal tabstop=2")
            vim.cmd("setlocal shiftwidth=2")
            vim.cmd("setlocal colorcolumn=100")
        end
    })
end

vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
    group = vim.api.nvim_create_augroup('JavaLspSettings', { clear = false }),
    desc = "Closes buffers with the '.class' extension to free up space",
    pattern = '*.class',
    nested = true,
    callback = function(args)
        vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
            once = true,
            callback = function(args2)
                if not vim.api.nvim_buf_is_valid(args.buf) then
                    print("[Autocmd]:", args2.id, "Can't find buffer with id", args.buf)
                    return
                end

                vim.api.nvim_buf_delete(args.buf, {})
            end
        })
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    group = vim.api.nvim_create_augroup('JavaLspSettings', { clear = false }),
    once = true,

    callback = function()
        attach_java_configs()
    end
})
