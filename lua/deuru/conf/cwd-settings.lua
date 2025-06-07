-- Listen to start app start up
-- check for ".nvim_conf.json"
-- if present set global settings according to it
--
M = {}


vim.api.nvim_create_autocmd("VimEnter", {
    callback = function(args)
        M.load_config()
    end
})

function M.load_config()
    local cwd = vim.fn.getcwd()
    local file, err = io.open(cwd .. '/.nvim_conf.json')
    if not file or err then
        return
    end

    print("Configuration '.nvim_conf.json' was located")

    local config = vim.fn.json_decode(file:read("*a"))
    file:close()
    assert(type(config) == 'table')


    for name, value in pairs(config) do
        vim.api.nvim_set_option_value(name, value, { scope = "global" })
    end
end
