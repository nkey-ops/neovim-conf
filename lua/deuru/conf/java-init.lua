local local_marks = require("extended-marks.local")

local mason_registry = require('mason-registry')
local google_java_format_jar =
    vim.fn.glob(
        mason_registry
        .get_package("google-java-format")
        :get_install_path() .. "/google-java-format-*.jar"
    )

local enable_auto_format = true
local java_formats = { "google2", "google4", "intellij" }
local java_format = java_formats[2]

require('formatter').setup {
    filetype = {
        java = {
            function()
                if java_format:match("intellij") then
                    return {
                        exe = "idea format",
                        args = { "-allowDefaults" },
                        stdin = false,
                    }
                elseif java_format:match("google2") then
                    return {
                        exe = 'java',
                        args = { '-jar', google_java_format_jar, vim.api.nvim_buf_get_name(0) },
                        stdin = true
                    }
                else
                    return {
                        exe = "google-java-format",
                        args = {
                            "--aosp",
                            vim.api.nvim_buf_get_name(0),
                            "--replace",
                        },
                        stdin = true,
                    }
                end
            end
        }
    }
}


vim.api.nvim_create_user_command("EnableJavaAutoFormat",
    function(opts)
        enable_auto_format = not enable_auto_format
        print(string.format("JavaAutoFormat=%s", enable_auto_format))
    end, {})

vim.api.nvim_create_user_command("SetJavaFormat",
    function(opts)
        local is_matched = false
        for _, format in pairs(java_formats) do
            if string.match(opts.args, format) then
                if format:match("google2") then
                    java_format = "google2"
                elseif format:match "google4" then
                    java_format = "google4"
                end
                is_matched = true
            end
        end

        assert(is_matched, "Format should be one of:" .. vim.inspect(java_formats))
        java_format = opts.args
    end, {
        nargs = 1,
        complete = function() return java_formats end,
    })

local format = function()
    assert(type(enable_auto_format) == 'boolean', "Should be boolean:", enable_auto_format)
    if enable_auto_format and vim.tbl_isempty(vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }))
    then
        local_marks.update()
        vim.cmd("FormatWrite")
        local_marks.restore()
    end
end
local formats = {}

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

            vim.keymap.set('n', '<leader>f',
                function() format() end,
                { desc = "Java Format", silent = true, buffer = args.buf }
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


            vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = "*.java",
                callback = function(args)
                    if formats[args.buf] == nil then
                        formats[args.buf] = true
                        format()
                    else
                        formats[args.buf] = nil
                    end
                end
            })
        end
    })
end

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup('JavaLspSettings', { clear = false }),
    desc = "Sets .class buftype=help",
    pattern = '*.class',
    callback = function(args)
        vim.bo[args.buf].buftype = "help"
        vim.bo[args.buf].buflisted = false
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
