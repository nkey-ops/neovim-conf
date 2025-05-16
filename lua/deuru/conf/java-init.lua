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

                -- use the contents of the buffer not the file, so
                -- you don't have to write into the file to make formatting
                local tmp  = os.tmpname() .. ".java"
                local file = assert(io.open(tmp, "w"))

                local data = vim.fn.getline(1, "$")
                if (type(data) == 'string') then
                    file:write(data)
                else
                    for _, x in pairs(data) do
                        file:write(x, '\n')
                    end
                end
                file:close()

                if java_format:match("google2") then
                    return {
                        exe = java_path,
                        args = { '-jar', google_java_format_jar,
                            lines and lines or "",
                            tmp
                        },
                        stdin = true
                    }
                else
                    return {
                        exe = java_path,
                        args = { '-jar', google_java_format_jar, "--aosp",
                            lines and lines or "",
                            tmp
                        },
                        stdin = true
                    }
                end
            end
        }
    }
}


vim.api.nvim_create_user_command("JavaAutoFormat",
    function()
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
                    vim.opt.expandtab = true
                elseif format:match "google4" then
                    java_format = "google4"
                    vim.opt.expandtab = true
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


local format = function()
    local_marks.update()
    vim.cmd("Format")
    local_marks.restore()
end

local auto_format = function()
    assert(type(enable_auto_format) == 'boolean', "Should be boolean:", enable_auto_format)
    if enable_auto_format and
        vim.tbl_isempty(
            vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }))
    then
        format()
    end
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

-- CREATE
local create_field = function()
    M.perform_action("Create field .*")
end

local create_local_var = function()
    M.perform_action("Create local variable.*")
end

local create_param = function()
    M.perform_action("Create parameter .*")
end

local create_method = function()
    M.perform_action("Create method .*")
end

local create_getter = function()
    M.perform_action("Generate Getter for.*")
end

local create_constructor = function()
    M.perform_action("Create constructor.*")
end


local add_unimp_methods = function()
    M.perform_action("Add unimplemented methods")
end

local to_static_import = function()
    M.perform_action("Convert to static import (repl.*")
end

local create_doc = function()
    M.perform_action("Add Javadoc.*")
end

local assign_const_param = function()
    M.perform_action("Assign parameter to new field")
end

local add_param_to_constr = function()
    M.perform_action("Change constructor .-: Add parameter.*")
end

local change_constructor = function()
    M.perform_action("Change constructor.*: Add param.*")
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

local add_all_missing_imp = function()
    M.perform_action("Add all missing imports")
end

local change_all_to_final = function()
    M.perform_action("Change modifiers to final where possible")
end


local ext = function(opts, desc, extra)
    assert(opts)
    assert(type(opts) == 'table')

    if (desc) then
        assert(type(desc) == 'string')
        opts = vim.tbl_extend('error', opts, { desc = desc })
    end

    if (extra) then
        opts = vim.tbl_extend('error', opts, extra)
    end

    return opts
end


vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('JavaLspSettings', { clear = false }),
    pattern = 'UserLspConfigAttached',
    desc = "Creats buffer local settings for files with the '*.java' extension",

    callback = function(args)
        if (not vim.bo[args.buf].filetype:match("java")) then
            return
        end

        P("loaded")
        local opts = { silent = true, buffer = args.buf }

        set('n', '<leader>o', add_all_missing_imp, ext(opts, "Java Import"))
        set({ 'n', 'v' }, '<leader>f', format, ext(opts, "Java Format"))
        set({ 'n', 'v' }, '<leader>ev', extract_var, ext(opts, "Java [E]xtract [V]ariable"))
        set({ 'n', 'v' }, '<leader>em', extract_meth, ext(opts, "Java [E]xtract [M]ethod"))
        set("n", "<leader>jc", "<cmd>JdtCompile<CR>", ext(opts, "Java JdtCompile"))

        set('n', '<leader>jot', function() jdtls.jol("estimates") end, ext(opts, "Java [Jo]l Es[t]imates"))
        set('n', '<leader>jof', function() jdtls.jol("footprint") end, ext(opts, "Java [Jo]l [F]ootprint"))
        set('n', '<leader>joe', function() jdtls.jol("externals") end, ext(opts, "Java [Jo]l [E]xternals"))
        set('n', '<leader>joi', function() jdtls.jol("internals") end, ext(opts, "Java [Jo]l [I]nternals"))
        set('n', '<leader>jap', jdtls.javap, ext(opts, "Java [Ja]va[p]"))

        set("n", "<leader>tt", jdtls.test_class, ext(opts, "Java Test Class"))
        set("n", "<leader>tm", jdtls.test_nearest_method, ext(opts, "Java [T]est Nearest [M]ethod"))
        set("n", "<leader>tp", jdtls.pick_test, ext(opts, "Java [P]ick [T]est"))
        -- set("n", "<leader>tg", jdtls.generate, ext(opts, "Java [G]enerate [T]est" ))
        -- set("n", "<leader>tb", jdtls.goto_subjects, ext(opts, "Java [G]o to subjects" ))
        set("n", "<leader>ud", "<cmd>JdtUpdateDebugConf<CR>", ext(opts, "Java JdtUpdateDebugConf"))

        -- Code Actions
        -- CREATE
        set("n", "<leader>ccf", create_field, --[[-------]] ext(opts, "Java: CA: [C]reate [F]ield"))
        set("n", "<leader>ccl", create_local_var, --[[---]] ext(opts, "Java: CA: [C]reate [L]ocal Var"))
        set("n", "<leader>ccp", create_param, --[[-------]] ext(opts, "Java: CA: [C]reate [P]aram"))
        set("n", "<leader>ccm", create_method, --[[------]] ext(opts, "Java: CA: [C]reate [M]ethod"))
        set("n", "<leader>ccg", create_getter, --[[------]] ext(opts, "Java: CA: [C]reate [G]etter"))
        set("n", "<leader>ccc", create_constructor, --[[-]] ext(opts, "Java: CA: [C]reate [C]onstructor"))

        -- set("n", "<leader>cum", change_method, --[[------]] ext(opts, "Java: CA: [C]reate [M]ethod"))
        set("n", "<leader>cuc", change_constructor, --[[-]] ext(opts, "Java: CA: [C]hange [C]onstructor - Add Param"))
        set("n", "<leader>cad", create_doc, --[[---------]] ext(opts, "Java: CA: [C]reate Java [D]oc"))
        set("n", "<leader>ccs", to_static_import, --[[---]] ext(opts, "Java: CA: Convert to Static Import"))
        set("n", "<leader>cpn", assign_const_param, --[[-]] ext(opts, "Java: CA: Assign Constructor Param"))
        set("n", "<leader>cap", add_param_to_constr, --[[]] ext(opts, "Java: CA: Add Param To Constr"))
        set("n", "<leader>cts", to_string, --[[----------]] ext(opts, "Java: CA: Create ToString Method"))
        set("n", "<leader>csc", surround_try_catch, --[[-]] ext(opts, "Java: CA: [S]urround with Try [C]atch"))
        set("n", "<leader>cat", add_throws, --[[---------]] ext(opts, "Java: CA: Add Throws"))
        set("n", "<leader>cum", add_unimp_methods, --[[--]] ext(opts, "Java: CA: Add [U]nimp [M]ethods"))
        set("n", "<leader>ctf", change_all_to_final, --[[]] ext(opts, "Java: CA: Change All Modifiers [T]o [F]inal"))
    end
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "java",
    callback = function(args)
        auto_format()
    end
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup('JavaLspSettings', { clear = false }),
    desc = "Sets .class buftype=help",
    pattern = '*.class',
    callback = function(args)
        vim.bo[args.buf].buftype = "help"
        vim.bo[args.buf].buflisted = false
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

--- @param action_pattern string
function M.perform_action(action_pattern)
    assert(action_pattern)
    assert(type(action_pattern) == 'string')

    vim.lsp.buf.code_action({
        apply = true,
        filter = function(action)
            return M.filter(action, action_pattern)
        end
    })
end

--- @param action_patterns table<string>
function M.perform_actions(action_patterns)
    assert(action_patterns)
    assert(type(action_patterns) == 'table')

    vim.lsp.buf.code_action({
        apply = true,
        filter = function(action)
            for _, action_pattern in pairs(action_patterns) do
                if M.filter(action, action_pattern) then
                    return true
                end
            end

            return false
        end
    })
end

--- @param action lsp.CodeAction|lsp.Command
--- @param goal_action_pattern string
function M.filter(action, goal_action_pattern)
    assert(action)
    assert(type(action) == "table")
    assert(goal_action_pattern)
    assert(type(goal_action_pattern) == "string")

    local title = action.title
    if title and type(title) == 'string'
        and title:match(goal_action_pattern) then
        return true
    end

    return false;
end
