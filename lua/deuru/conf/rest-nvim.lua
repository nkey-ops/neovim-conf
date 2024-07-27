return function()
    require("rest-nvim").setup({
        -- Open request results in a horizontal split
        result_split_horizontal = true,
        -- Keep the http file buffer above|left when split horizontal|vertical
        result_split_in_place = true,
        -- Skip SSL verification, useful for unknown certificates
        skip_ssl_verification = false,
        -- Encode URL before making request
        encode_url = false,
        -- Highlight request on ru
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

    -- to inject env vars into raw curl request args add it to
    -- ~.local/share/nvim/lazy/rest.nvim/lua/rest-nvim/init.lua : run_request
    -- local vars = utils.read_variables()
    -- for i, line in ipairs(result.raw) do
    --   result.raw[i] = utils.replace_vars(line, vars)
    -- end

    -- request/init.lua | 403
    -- { regtype = "v", inclusive = false }


    -- /home/local/.local/share/nvim/lazy/rest.nvim/lua/rest-nvim/request/init
    -- get_curl_args
    --
    -- 157
    -- if line_content:find("--{%%") then
    --   line_content = "a"
    -- end
end
