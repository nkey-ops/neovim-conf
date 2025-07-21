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

-- Gets and Sets the found key2 as a context var with the name
_G.gas_header = function(header_name, header_value_regex, env_var_name, response, client)
    assert(type(header_name) == 'string', "header_name cannot be nil and should be of type 'string'")
    assert(type(env_var_name) == 'string', "env_var_name cannot be nil and should be of type 'string'")
    assert(type(response) == 'table', "env_var_name cannot be nil and should be of type 'table'")
    assert(type(client) == 'table', "env_var_name cannot be nil and should be of type 'table'")
    if header_value_regex then
        assert(type(header_value_regex) == 'string', "header_value_regex should be of type 'string'")
    end


    local header = response.headers[header_name]

    if (header == nil) then
        print("Couldn't find header_name:", header_name)
        return
    end

    local value = nil
    if header_value_regex then
        for _, header_value in pairs(header) do
            local s = string.match(header_value, header_value_regex)
            if s then
                value = s
            end
        end

        if not value then
            print(("Couldn't find '%s'"):format(header_value_regex))
            return
        end
    else
        for _, header_value in pairs(header) do
            value = value .. header_value
        end
    end

    client.global.set(env_var_name, value)
    print(("Set env-var: '%s'='%s'"):format(env_var_name, value))
end


--TODO corner keys for empty tables
_G.gas_json = function(key, env_var_name, response, client)
    assert(key ~= nil and (type(key) == "table" or type(key) == "string"),
        "Key cannot be nil and should be of a type table or string")
    assert(env_var_name ~= nil and type(env_var_name) == "string",
        "env_var_name cannot be nil and should be of a type string")
    assert(response ~= nil, "context cannot be nil")
    assert(client ~= nil, "client cannot be nil")

    if response.body == nil or response.body == "" then
        print("No body was present ")
        return
    end

    local status, body = pcall(vim.json.decode, response.body)
    if not status then
        print("Couldn't convert body to json")
        return
    end

    local full_key = "";
    if type(key) == "string" then
        body = body[key]
        full_key = key
    else
        for _, v in pairs(key) do
            if body == nil or type(body) ~= "table" then
                break
            end

            body = body[v]
            full_key = string.format("%s%s.", full_key, v)
        end

        full_key = string.sub(full_key, 1, string.len(full_key) - 1)
    end

    if body == nil or type(body) == "table" then
        print("Couldn't find key:", full_key)
        return
    end

    client.global.set(env_var_name, body)
    print(("Set env-var: '%s'='%s'"):format(env_var_name, body))
end


_G.gas_body = function(vim_regex, env_var_name, response, client)
    assert(vim_regex ~= nil and (type(vim_regex) == "table" or type(vim_regex) == "string"),
        "Key cannot be nil and should be of a type table or string")
    assert(env_var_name ~= nil and type(env_var_name) == "string",
        "env_var_name cannot be nil and should be of a type string")
    assert(response ~= nil, "context cannot be nil")
    assert(client ~= nil, "client cannot be nil")

    if response.body == nil or response.body == "" then
        print("No body was present ")
        return
    end

    if not type(response.body) == 'string' then
        print("The body was of type", type(response.body))
        return
    end

    local result = vim.fn.matchstr(response.body, vim_regex)
    if not result then
        print(("Couldn't find key: '%s'"):format(vim_regex))
        return
    end

    client.global.set(env_var_name, result)
    print(("Set env-var: '%s'='%s'"):format(env_var_name, result))
end

--- @param command string
_G.cmd = function(command)
    assert(type(command) == 'string', "command should not be nil and should be of type 'string'")
    --
    local cmd = {}
    for m in command:gmatch("%S+") do
        table.insert(cmd, m)
    end
    local result = vim.system(cmd, { text = true }):wait().stdout
    return result:gsub("\n", "")
end
