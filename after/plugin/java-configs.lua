-- Close buffers with ".class" extension to free up space
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
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


vim.api.nvim_create_autocmd({ "FileType" }, {
    desc = "Creats buffer local keybind for files with the '*.java' extension",
    pattern = 'java',

    callback = function(args)
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
        vim.keymap.set('n', '<leader>jo',
            function() jdtls.jol() end,
            { desc = "Java [Jo]l", silent = true, buffer = args.buf }
        )
        vim.keymap.set("n", "<leader>df",
            function() jdtls.test_class({}) end,
            { desc = "Java Test Class", silent = true, buffer = args.buf }
        )
        vim.keymap.set("n", "<leader>tn",
            function() jdtls.test_nearest_method({}) end,
            {
                desc = "Java [T]est [N]earest Method",
                silent = true,
                buffer = args.buf
            }
        )

        -- settings
        vim.cmd("setlocal tabstop=2")
        vim.cmd("setlocal softtabstop=2")
        vim.cmd("setlocal shiftwidth=2")
        vim.cmd("setlocal colorcolumn=100")
    end
})
