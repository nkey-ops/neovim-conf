require("rest-nvim").setup({
  client = "curl",
  env_file = ".env",
  env_pattern = "\\.env$",
  env_edit_command = "tabedit",
  encode_url = true,
  skip_ssl_verification = false,
  custom_dynamic_variables = {},
  logs = {
    level = "info",
    save = true,
  },
  result = {
    split = {
      horizontal = true,
      in_place = true,
      stay_in_current_window_after_split = true,
    },
    behavior = {
      decode_url = true,
      show_info = {
        url = true,
        headers = true,
        http_info = true,
        curl_command = true,
      },
      statistics = {
        enable = true,
        ---@see https://curl.se/libcurl/c/curl_easy_getinfo.html
        stats = {
          { "total_time", title = "Time taken:" },
          { "size_download_t", title = "Download size:" },
        },
      },
      formatters = {
        json = "jq",
        vnd = "jq",
        html = function(body)
          if vim.fn.executable("tidy") == 0 then
            return body, { found = false, name = "tidy" }
          end
          local fmt_body = vim.fn.system({
            "tidy",
            "-i",
            "-q",
            "--tidy-mark",      "no",
            "--show-body-only", "auto",
            "--show-errors",    "0",
            "--show-warnings",  "0",
            "-",
          }, body):gsub("\n$", "")

          return fmt_body, { found = true, name = "tidy" }
        end,
      },
    },
  },
  highlight = {
    enable = true,
    timeout = 150,
  },
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = 'http',
    callback = function(args)
        vim.keymap.set("n", "<leader>r", "<cmd>Rest run<CR>",
            { desc = "RestNvim: [R]un Curl Command", buffer = args.buf })
        vim.keymap.set("n", "<leader>p", "<cmd>Rest result prev<CR>",
            { desc = "RestNvim: [P]review Curl Command", buffer = args.buf })
        vim.keymap.set("n", "<leader>l", "<cmd>Rest last<CR>",
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


_G.gas_json = function(key1, context, name)
    if (key1 == nil or context == nil or name == nil) then
        print("One of the parameters is nil:", key1, context, name)
        return
    end

    local value = context.json_decode(context.result.body)[key1]
    if (value == nil) then
        print("Couldn't find key1:", key1)
        return
    end

    context.set_env(name, value)

    print("Set env-var:", name, value)
end
