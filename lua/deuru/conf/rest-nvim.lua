local Scripts = {}
Scripts = {
    set = function(key, value)
        assert(type(key) == 'string', "key should be of type 'string'")
        assert(type(value) == 'string', "value should be of type 'string'")

        vim.env[key] = value
    end,

    yank = function(value)
        vim.fn.setreg("+", value)
    end,

    ---@param fun function(rest.Request)
    pre_script = function(fun)
        assert(type(fun) == "function")
        vim.api.nvim_create_autocmd("User", {
            pattern = "RestRequestPre",
            once = true,
            callback = function()
                fun(_G.rest_request)
            end,
        })
    end,
    ---@param response rest.Response
    gas_header = function(response)
        return function(header_name, vim_regex, env_name)
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
        end
    end,
    ---@param response rest.Response
    gas_json = function(response)
        return function(key, env_name)
            assert(key ~= nil and (type(key) == "table" or type(key) == "string"),
                "The 'key' cannot be nil and should be of the type 'table' or 'string'")
            assert(env_name ~= nil and type(env_name) == "string",
                "The 'env_name' cannot be nil and should be of the type 'string'")

            if response.body == nil or response.body == "" then
                print("No body was present")
                return
            end

            local status, body = pcall(vim.json.decode, response.body)
            if not status then
                print("Couldn't convert the body to json")
                return
            end

            local full_key = "";
            if type(key) == "string" then
                body = body[key]
                full_key = key
            else
                for _, sub_key in pairs(key) do
                    if body == nil or type(body) ~= "table" then
                        break
                    end

                    body = body[sub_key]
                    full_key = string.format("%s%s.", full_key, sub_key)
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
        end
    end,

    ---@param response rest.Response
    gas_body = function(response)
        return function(vim_regex, env_name)
            assert(vim_regex ~= nil and (type(vim_regex) == "table" or type(vim_regex) == "string"),
                "Key cannot be nil and should be of a type table or string")
            assert(env_name ~= nil and type(env_name) == "string",
                "env_var_name cannot be nil and should be of a type string")

            if response.body == nil or response.body == "" then
                print("No body was present")
                return
            end

            if not type(response.body) == 'string' then
                print("The 'body' was not of the type 'string' but of", type(response.body))
                return
            end

            local result = vim.fn.matchstr(response.body, vim_regex)
            if not result then
                print(("Couldn't find key: '%s'"):format(vim_regex))
                return
            end

            vim.env[env_name] = result
            print(("Set env-var: '%s'='%s'"):format(env_name, result))
        end
    end,

    pipe_cmd = function(pipe_text, command)
        assert(type(pipe_text) == 'string', "pipe_text should be of type 'string'")
        assert(type(command) == 'string', "command should be of type 'string'")
        local tmp_path = os.tmpname()
        local tmp_file, err = io.open(tmp_path, 'w')
        assert(tmp_file, string.format(
            "Coldn't open temporary file with the path '%s' due to '%s'",
            tmp_path, err))

        tmp_file:write(pipe_text)
        tmp_file:close()

        local cmd
        local args = {}
        for x in string.gmatch(command, "%S+") do
            if not cmd then
                cmd = x
            else
                table.insert(args, x)
            end
        end
        table.insert(args, tmp_path)
        local res = require("plenary.job")
            :new(
                {
                    command = cmd,
                    args = args,
                    cwd = "."
                })
            :sync()

        assert(res, string.format(
            "Couldn't pipe text to the command, the result is 'nil'",
            tmp_path, err))
        assert(type(res) == "table", string.format("No data were converted, the data is empty"))

        local data = ''
        for _, v in pairs(res) do
            data = data .. v
        end
        return data
    end,
    --- TODO, is ever nil?
    ---@parm str string the string to encode or decode
    ---@parm decode? boolean default: false | Whether to decode the string
    ---@return string the encoded or decoded string
    base64 = function(str, decode)
        assert(type(str) == 'string',
            "the 'str' arg should be of the type 'string'")
        if decode then
            assert(type(decode) == 'boolean',
                "the 'decode' arg should of the type 'boolean'")
        end

        local tmp_path = os.tmpname()
        local tmp_file, err = io.open(tmp_path, 'w')
        assert(tmp_file, string.format(
            "Coldn't open temporary file with the path '%s' due to '%s'",
            tmp_path, err))

        tmp_file:write(str)
        tmp_file:close()

        local args = { tmp_path }
        if decode then
            table.insert(args, 1, "--decode")
        end

        local res = require("plenary.job")
            :new(
                {
                    command = "base64",
                    args = args,
                    cwd = "."
                })
            :sync()

        assert(res, string.format(
            "Couldn't convert to base64, base64 job returned 'nil'",
            tmp_path, err))
        assert(type(res) == "table" and res[1], string.format(
            "No data were converted data is empty"))
        -- assert(#res[1] >= 1, string.format(
        --     "The converted text doesn't have a length of 1 or more, "
        --     .. "the length is '%s', the text is '%s'", #res, res[1]))

        local data = ''
        for _, v in pairs(res) do
            data = data .. v
        end
        return data
    end,

    ---@parm str string
    ---@return string
    sha256 = function(str)
        assert(type(str) == 'string', "str should be of type 'string'")
        local tmp_path = os.tmpname()
        local tmp_file, err = io.open(tmp_path, 'w')
        assert(tmp_file, string.format(
            "Coldn't open temporary file with the path '%s' due to '%s'",
            tmp_path, err))

        tmp_file:write(str)
        tmp_file:close()

        local res = require("plenary.job")
            :new(
                {
                    command = "sha256sum",
                    args = { tmp_path },
                    cwd = "."
                })
            :sync()

        assert(res, string.format(
            "Couldn't convert to sha256, sha256sum job returned 'nil'",
            tmp_path, err))
        assert(type(res) == "table" and res[1], string.format(
            "No data were converted data is empty"))
        assert(#res[1] >= 64, string.format(
            "The converted text doesn't have a length of 64 or more, "
            .. "the length is '%s', the text is '%s'", #res, res[1]))

        return res[1]:sub(1, 64)
    end,

    ---@param ctx rest.Context
    csup_auth = function(ctx)
        return function()
            Scripts.pre_script(function(req)
                assert(type(ctx.vars["csup_id"]) == 'string',
                    "the 'csup_id' env. var. should be present and of the type 'string'")
                assert(type(ctx.vars["csup_secret_key"]) == 'string',
                    "the 'csup_secret_key' env. var. should be present and of the type 'string'")
                assert(type(ctx.vars["csup_key"]) == 'string',
                    "the 'csup_key' env. var. should be present and of the type 'string'")

                local merchant_id = ctx.vars["csup_id"]
                local secret_key = ctx.vars["csup_secret_key"]
                local key = ctx.vars["csup_key"]

                local _, _, host, uri = req.url:find(".+//(.-)(/.-)/?$")
                assert(host, "couldn't find the host of the request: " .. req.url)
                assert(uri, "couldn't find the uri of the request: " .. req.url)

                local is_get = req.method:lower() == "get"
                req.headers["host"] = { host }
                req.headers["v-c-date"] = { os.date("!%a,%e %b %Y %H:%M:%S GMT") }
                req.headers["v-c-merchant-id"] = { merchant_id }

                local signature = string.format(
                    "host: " .. host
                    .. "\nv-c-date: " .. req.headers["v-c-date"][1]
                    .. "\nrequest-target: " .. req.method:lower() .. " " .. uri
                    .. "\nv-c-merchant-id: " .. merchant_id
                )

                if not is_get then
                    req.headers.digest = {
                        "SHA-256=" ..
                        Scripts.base64(
                            Scripts.pipe_cmd(
                                req.body.data, "openssl dgst -sha256 -binary"))
                    }

                    signature = signature .. "\ndigest: " .. req.headers.digest[1]
                end

                signature =
                    Scripts.base64(
                        Scripts.pipe_cmd(signature,
                            string.format(
                                "openssl dgst -sha256 -binary -hmac %s",
                                Scripts.base64(secret_key, true)
                            )))

                req.headers.signature = {
                    string.format("%s, %s, %s, %s",
                        string.format("keyid=\"%s\"", key),
                        "algorithm=\"HmacSHA256\"",
                        string.format("headers=\"host v-c-date request-target v-c-merchant-id%s\"",
                            not is_get and " digest" or ""),
                        string.format("signature=\"%s\"", signature)
                    ) }
            end)
        end
    end,

    cmd = function(command)
        assert(type(command) == 'string', "command should not be nil and should be of type 'string'")
        --
        local cmd = {}
        for m in command:gmatch("%S+") do
            table.insert(cmd, m)
        end
        local result = vim.system(cmd, { text = true }):wait().stdout

        if result then
            return result:gsub("\n", "")
        end
    end,
}

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

    custom_pre_scripts = {
        lua = function(ctx)
            return {
                set = Scripts.set,
                pre_script = Scripts.pre_script,
                sha256 = Scripts.sha256,
                base64 = Scripts.base64,
                pipe_cmd = Scripts.pipe_cmd,
                csup_auth = Scripts.csup_auth(ctx),
                yank = Scripts.yank,
            }
        end
    },
    custom_post_scripts = {
        lua = function(ctx, response)
            return {
                gas_json = Scripts.gas_json(response),
                gas_body = Scripts.gas_body(response),
                gas_header = Scripts.gas_header(response),
                sha256 = Scripts.sha256,
                base64 = Scripts.base64,
                yank = Scripts.yank,
                cmd = Scripts.cmd,
            }
        end
    },
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
--
--
--
