require("rest-nvim").setup({
    -- Open request results in a horizontal split
    result_split_horizontal = true,
    -- Keep the http file buffer above|left when split horizontal|vertical
    result_split_in_place = true,
    -- Skip SSL verification, useful for unknown certificates
    skip_ssl_verification = false,
    -- Encode URL before making request
    encode_url = false,
    -- Highlight request on run
    highlight = {
        enabled = true,
        timeout = 150,
    },
    result = {
        -- toggle showing URL, HTTP info, headers at top the of result window
        show_url = true,
        -- show the generated curl command in case you want to launch
        -- the same request via the terminal (can be verbose)
        show_curl_command = true,
        show_http_info = true,
        show_headers = true,
        -- table of curl `--write-out` variables or false if disabled
        -- for more granular control see Statistics Spec
        show_statistics = false,
        -- executables or functions for formatting response body [optional]
        -- set them to false if you want to disable them
        formatters = {
            json = "jq",
            vnd = "jq",
            html = function(body)
                return vim.fn.system({ "tidy", "-i", "-q" }, body)
            end
        },
    },
    -- Jump to request line on run
    jump_to_request = false,
    env_file = '.env',
    custom_dynamic_variables = {},
    yank_dry_run = true,
})

--to remove redirects (-L) go to
--~/.local/share/nvim/site/pack/packer/start/plenary.nvim/lua/plenary/curl.lua
--parse.request()

local rest = require("rest-nvim")
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = 'http',
    callback = function(args)
        vim.keymap.set("n", "<leader>r", "<Plug>RestNvim",
            { desc = "RestNvim: [R]un Curl Command", buffer = args.buf })
        vim.keymap.set("n", "<leader>p", "<Plug>RestNvimPreview",
            { desc = "RestNvim: [P]review Curl Command", buffer = args.buf })
        vim.keymap.set("n", "<leader>l", "<Plug>RestNvimLast",
            { desc = "RestNvim: Run [L]ast Curl Command", buffer = args.buf })
    end
})


-- Gets and Sets the found key2 as a context var with the name
_G.gas_header = function(key1, key2, context, name)
    if (key1 == nil or key2 == nil or context == nil or name == nil) then
        print("One of the parameters is nil:", key1, key2, context, name)
        return
    end

    local line = context.result.headers[key1]

    if (line == nil) then
        print("Couldn't find key1:", key1)
        return
    end

    local s, e = string.find(line, key2)

    if (s == nil) then
        print("Couldn't find key2:", key2)
        return
    end

    local st = string.sub(line, s, e)
    context.set_env(name, st)

    print("Set env-var:", name, st)
end

local is_correct = function(value)
end

--TODO corner keys for empty tables
_G.gas_json = function(key, context, env_var_name)
    assert(key ~= nil and (type(key) == "table" or type(key) == "string"),
        "Key cannot be nil and should be of a type table or string")
    assert(context ~= nil, "context cannot be nil")
    assert(env_var_name ~= nil and type(env_var_name) == "string",
        "env_var_name cannot be nil and should be of a type string")

    if context.result.body == nil or context.result.body == "" then
        print("No body was present ")
        return
    end

    local body = context.json_decode(context.result.body)

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

    context.set_env(env_var_name, body)
end
