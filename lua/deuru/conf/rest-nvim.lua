---rest.nvim default configuration
---@type rest.Opts
vim.g.rest_nvim =
{
    ---@type table<string, fun():string> Table of custom dynamic variables
    custom_dynamic_variables = {},
    ---@class rest.Config.Request
    request = {
        ---@type boolean Skip SSL verification, useful for unknown certificates
        skip_ssl_verification = true,
        ---Default request hooks
        ---@class rest.Config.Request.Hooks
        hooks = {
            ---@type boolean Encode URL before making request
            encode_url = true,
            ---@type string Set `User-Agent` header when it is empty
            user_agent = "rest.nvim v" .. require("rest-nvim.api").VERSION,
            ---@type boolean Set `Content-Type` header when it is empty and body is provided
            set_content_type = true,
        },
    },
    ---@class rest.Config.Response
    response = {
        ---Default response hooks
        ---@class rest.Config.Response.Hooks
        hooks = {
            ---@type boolean Decode the request URL segments on response UI to improve readability
            decode_url = true,
            ---@type boolean Format the response body using `gq` command
            format = true,
        },
    },
    ---@class rest.Config.Clients
    clients = {
        ---@class rest.Config.Clients.Curl
        curl = {
            ---Statistics to be shown, takes cURL's `--write-out` flag variables
            ---See `man curl` for `--write-out` flag
            ---@type RestStatisticsStyle[]
            statistics = {
                { id = "time_total",    winbar = "take", title = "Time taken" },
                { id = "size_download", winbar = "size", title = "Download size" },
            },
            ---Curl-secific request/response hooks
            ---@class rest.Config.Clients.Curl.Opts
            opts = {
                ---@type boolean Add `--compressed` argument when `Accept-Encoding` header includes
                ---`gzip`
                set_compressed = false,
                ---@type table<string, Certificate> Table containing certificates for each domains
                certificates = {},
            },
        },
    },
    ---@class rest.Config.Cookies
    cookies = {
        ---@type boolean Whether enable cookies support or not
        enable = false,
        ---@type string Cookies file path
        path = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "rest-nvim.cookies"),
    },
    ---@class rest.Config.Env
    env = {
        ---@type boolean
        enable = true,
        ---@type string
        pattern = ".*%.env.*",
        ---@type fun():string[]
        find = function()
            local config = require("rest-nvim.config")
            return vim.fs.find(function(name, _)
                return name:match(config.env.pattern)
            end, {
                path = vim.fn.getcwd(),
                type = "file",
                limit = math.huge,
            })
        end,
    },
    ---@class rest.Config.UI
    ui = {
        ---@type boolean Whether to set winbar to result panes
        winbar = true,
        ---@class rest.Config.UI.Keybinds
        keybinds = {
            ---@type string Mapping for cycle to previous result pane
            prev = "H",
            ---@type string Mapping for cycle to next result pane
            next = "L",
        },
    },
    ---@class rest.Config.Highlight
    highlight = {
        ---@type boolean Whether current request highlighting is enabled or not
        enable = true,
        ---@type number Duration time of the request highlighting in milliseconds
        timeout = 750,
    },
    ---@see vim.log.levels
    ---@type integer log level
    _log_level = vim.log.levels.WARN,

    ---@param ctx rest.Context
    ---@return table
    custom_requests = function(ctx, response)
        return {
            lua = {
                gas_json = function(key, env_name)
                    assert(key ~= nil and (type(key) == "table" or type(key) == "string"),
                        "Key cannot be nil and should be of a type table or string")
                    assert(env_name ~= nil and type(env_name) == "string",
                        "env_var_name cannot be nil and should be of a type string")

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

                    vim.env[env_name] = body
                    print(("Set env-var: '%s'='%s'"):format(env_name, body))
                    return body
                end,

                gas_body = function(vim_regex, env_name)
                    assert(vim_regex ~= nil and (type(vim_regex) == "table" or type(vim_regex) == "string"),
                        "Key cannot be nil and should be of a type table or string")
                    assert(env_name ~= nil and type(env_name) == "string",
                        "env_var_name cannot be nil and should be of a type string")

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

                    vim.env[env_name] = result
                    print(("Set env-var: '%s'='%s'"):format(env_name, result))
                end,

                -- Gets and Sets the found key2 as a context var with the name
                gas_header = function(header_name, vim_regex, env_name)
                    assert(type(header_name) == 'string', "header_name cannot be nil and should be of type 'string'")
                    assert(type(env_name) == 'string', "env_var_name cannot be nil and should be of type 'string'")

                    if vim_regex then
                        assert(type(vim_regex) == 'string', "header_value_regex should be of type 'string'")
                    end

                    local header = response.headers[header_name:lower()]

                    if (header == nil) then
                        print("Couldn't find header_name:", header_name)
                        return
                    end

                    local value = ""
                    if vim_regex then
                        for _, header_value in pairs(header) do
                            local s = vim.fn.matchstr(header_value, vim_regex)
                            if s then
                                if value ~= "" then
                                    value = value .. '; '
                                end
                                value = value .. s
                            end
                        end

                        if not value then
                            print(("Couldn't find '%s'"):format(vim_regex))
                            return
                        end
                    else
                        for _, header_value in pairs(header) do
                            value = value .. header_value
                        end
                    end

                    vim.env[env_name] = value
                    print(("Set env-var: '%s'='%s'"):format(env_name, value))
                    return value
                end,
                yank = function(value)
                    vim.fn.setreg("+", value)
                end,
                cmd = function(command)
                    assert(type(command) == 'string', "command should not be nil and should be of type 'string'")
                    --
                    local cmd = {}
                    for m in command:gmatch("%S+") do
                        table.insert(cmd, m)
                    end
                    local result = vim.system(cmd, { text = true }):wait().stdout
                    return result:gsub("\n", "")
                end

            }
        }
    end
}

-- update scripts/lua.lua
--
-- if vim.g.rest_nvim.custom_requests
--     and type(vim.g.rest_nvim.custom_requests) == 'function' then
--     -- and vim.g.rest_nvim.custom_requests.lua
--     -- and type(vim.g.rest_nvim.custom_requests.lua) == 'table' then
--
--     local custom_requests = vim.g.rest_nvim.custom_requests(ctx, res)
--
--     if custom_requests.lua and
--         type(custom_requests.lua) == 'table' then
--         env = vim.tbl_extend("force", env, custom_requests.lua)
--     end
-- end
