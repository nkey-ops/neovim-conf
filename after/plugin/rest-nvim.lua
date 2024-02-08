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

-- Gets and Sets the found key2 as a context var with the name
_G.gas_key = function(key1, key2, context, name)
  if (key1 == nil or key2 == nil or context == nil or name == nil) then
    print("One of the parameters is nil")
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

  local js = string.sub(line, s, e)
  context.set_env(name, js)
end
