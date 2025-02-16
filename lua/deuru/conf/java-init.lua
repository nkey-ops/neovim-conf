local local_marks = require("extended-marks.local")

local M = {}

local jdtls = require("jdtls")
local mason_registry = require('mason-registry')
local google_java_format_jar =
    vim.fn.glob(
        mason_registry
        .get_package("google-java-format")
        :get_install_path() .. "/google-java-format-*.jar"
    )

local enable_auto_format = false
local java_formats = { "google2", "google4", "intellij", "5pos" }
local java_format = java_formats[2]

local set = vim.keymap.set

local java_path = "/usr/lib/jvm/java-21-openjdk-amd64/bin/java"

require('formatter').setup {
    filetype = {
        java = {
            function()
                local lines = nil
                local mode = vim.api.nvim_get_mode()['mode']

                if mode == 'v' or mode == 'V' or mode == '\22' then
                    local startLine = vim.fn.getpos("v")[2]
                    local endLine = vim.fn.getcurpos()[2]
                    lines = string.format("--lines %s:%s", startLine, endLine)
                    M.exit_visual()
                end

                if java_format:match("google2") then
                    return {
                        exe = java_path,
                        args = { '-jar', google_java_format_jar,
                            lines and lines or "",
                            vim.api.nvim_buf_get_name(0)
                        },
                        stdin = true
                    }
                elseif java_format:match("5pos") then
                    return {
                        exe = java_path,
                        args = {
                            '-jar', google_java_format_jar,
                            "--aosp",
                            "--skip-javadoc-formatting",
                            "--skip-reflowing-long-strings",
                            lines and lines or "",
                            vim.api.nvim_buf_get_name(0)
                        },
                        stdin = true
                    }
                else
                    return {
                        exe = java_path,
                        args = { '-jar', google_java_format_jar, "--aosp",
                            lines and lines or "",
                            vim.api.nvim_buf_get_name(0) },
                        stdin = true
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
                elseif format:match "5pos" then
                    vim.opt.expandtab = false
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


local auto_format = function()
    assert(type(enable_auto_format) == 'boolean', "Should be boolean:", enable_auto_format)
    if enable_auto_format and vim.tbl_isempty(vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }))
    then
        local_marks.update()
        vim.cmd("FormatWrite")
        local_marks.restore()
    end
end

local format = function()
    local_marks.update()

    vim.cmd("FormatWrite")

    local_marks.restore()
end

local extract_var = function()
    local mode = vim.api.nvim_get_mode()['mode']
    if mode == 'v' or mode == 'V' then
        M.exit_visual()
        jdtls.extract_variable({ visual = true })
    else
        jdtls.extract_variable()
    end
end

local extract_meth = function()
    local mode = vim.api.nvim_get_mode()['mode']
    if mode == 'v' or mode == 'V' then
        M.exit_visual()
        jdtls.extract_method({ visual = true })
    else
        jdtls.extract_method()
    end
end
local formats = {}

local create_getter = function()
    M.perform_action("Generate Getter for.*")
end

local create_field = function()
    M.perform_action("Create field .*")
end

local create_method = function()
    M.perform_action("Create method .*")
end

local convert_to_static_import = function()
    M.perform_action("Convert to static import (repl.*")
end

local add_doc = function()
    M.perform_action("Add Javadoc.*")
end

local assign_param_to_new_field = function()
    M.perform_action("Assign parameter to new field")
end

local create_local_var = function()
    M.perform_action("Create local variable.*")
end

local to_string = function()
    M.perform_action("Generate toString.*")
end

local surround_try_catch = function()
    M.perform_action("Surround with try/catch")
end

local add_throws = function()
    M.perform_action("Add throws declaration")
end

local add_unimplemented_methods = function()
    M.perform_action("Add unimplemented methods")
end

local ext = function(opts, extra)
    return vim.tbl_extend('error', opts, extra)
end

local attach_java_configs = function(buf)
    vim.api.nvim_create_autocmd('User', {
        group = vim.api.nvim_create_augroup('JavaLsp', {}),
        desc = "Creats buffer local settings for files with the '*.java' extension",
        -- pattern = 'UserLspConfigAttached',
        buffer = buf,
        once = true,

        callback = function(args)
            if not string.match(vim.api.nvim_buf_get_name(args.buf), '%.java$') then
                return
            end

            local opts = { silent = true, buffer = args.buf }

            set('n', '<leader>o', jdtls.organize_imports, ext(opts, { desc = "Java Import" }))
            set({ 'n', 'v' }, '<leader>f', format, ext(opts, { desc = "Java Format" }))
            set({ 'n', 'v' }, '<leader>ev', extract_var, ext(opts, { desc = "Java [E]xtract [V]ariable" }))
            set({ 'n', 'v' }, '<leader>em', extract_meth, ext(opts, { desc = "Java [E]xtract [M]ethod" }))
            set("n", "<leader>jc", "<cmd>JdtCompile<CR>", ext(opts, { desc = "Java JdtCompile" }))

            set('n', '<leader>jot', function() jdtls.jol("estimates") end, ext(opts, { desc = "Java [Jo]l Es[t]imates" }))
            set('n', '<leader>jof', function() jdtls.jol("footprint") end, ext(opts, { desc = "Java [Jo]l [F]ootprint" }))
            set('n', '<leader>joe', function() jdtls.jol("externals") end, ext(opts, { desc = "Java [Jo]l [E]xternals" }))
            set('n', '<leader>joi', function() jdtls.jol("internals") end, ext(opts, { desc = "Java [Jo]l [I]nternals" }))
            set('n', '<leader>jap', jdtls.javap, ext(opts, { desc = "Java [Ja]va[p]" }))

            set("n", "<leader>tt", jdtls.test_class, ext(opts, { desc = "Java Test Class" }))
            set("n", "<leader>tm", jdtls.test_nearest_method, ext(opts, { desc = "Java [T]est Nearest [M]ethod", }))
            set("n", "<leader>tp", jdtls.pick_test, ext(opts, { desc = "Java [P]ick [T]est" }))
            -- set("n", "<leader>tg", jdtls.generate, ext(opts, { desc = "Java [G]enerate [T]est" }))
            -- set("n", "<leader>tb", jdtls.goto_subjects, ext(opts, { desc = "Java [G]o to subjects" }))
            set("n", "<leader>ud", "<cmd>JdtUpdateDebugConf<CR>", ext(opts, { desc = "Java JdtUpdateDebugConf" }))

            set("n", "<leader>ccg", create_getter, opts)
            set("n", "<leader>ccf", create_field, opts)
            set("n", "<leader>ccm", create_method, opts)
            set("n", "<leader>ccs", convert_to_static_import, opts)
            set("n", "<leader>cd", add_doc, opts)
            set("n", "<leader>cpn", assign_param_to_new_field,
                ext(opts, { desc = "Java: Assgin constructor param to a field" }))
            set("n", "<leader>ccl", create_local_var, opts)
            set("n", "<leader>cts", to_string, opts)
            set("n", "<leader>csc", surround_try_catch, opts)
            set("n", "<leader>cat", add_throws, opts)
            set("n", "<leader>cum", add_unimplemented_methods,
                ext(opts, { desc = "Java Add [U]nimplemented [M]ethods" }))

            -- vim.api.nvim_create_autocmd("BufWritePost", {
            --     pattern = "*.java",
            --     callback = function(args)
            --         if formats[args.buf] == nil then
            --             formats[args.buf] = true
            --             auto_format()
            --         else
            --             formats[args.buf] = nil
            --         end
            --     end
            -- })
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

    callback = function(args)
        attach_java_configs(args.buf)
    end
})

function M.exit_visual()
    local mode = vim.api.nvim_get_mode()['mode']
    if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
        error("Exit_visual(): Can't exit visual mode because it isn't in visual mode")
        return
    end

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "x", false
    )
end

function M.perform_action(action_pattern)
    vim.lsp.buf.code_action({
        apply = true,
        filter = function(action)
            return M.filter(action, action_pattern)
        end
    })
end

function M.filter(action, goal_action)
    assert(action)
    assert(goal_action)

    local title = action.title
    if title and type(title) == 'string'
        and title:match(goal_action) then
        return true
    end

    return false;
end
