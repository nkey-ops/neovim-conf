local sql_formatter = vim.fn.glob(
    "~/.local/share/nvim/mason/packages/sql-formatter/node_modules/sql-formatter/bin/sql-formatter-cli.cjs")

local format = function()
    local file_path = vim.api.nvim_buf_get_name(0)
    local buf = vim.api.nvim_get_current_buf()

    local config_path = "/tmp/sql-formatter-config.json"
    local config = {
        language = vim.bo[buf].filetype,
        keywordCase = "upper",
        linesBetweenQueries = 2,
        tabWidth = 4,
        -- indentStyle = "tabularLeft"
    }

    local config_file = assert(io.open(config_path, "w"))
    local encoded_config = vim.json.encode(config)
    config_file:write(encoded_config)
    config_file:close()

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    local placeholder = "/*__MYSQL_G_MARKER__*/;"
    local masked_content = content:gsub("\\G;?", placeholder)

    local data_path = "/tmp/sql-formatter-data"
    local data_file = assert(io.open(data_path, "w"))
    data_file:write(masked_content)
    data_file:close()

    vim.cmd('silent !' .. sql_formatter ..
        ' -c ' .. config_path ..
        ' -o ' .. data_path ..
        ' ' .. data_path)

    data_file = assert(io.open(data_path, "r"))
    content = data_file:read("*a")
    content = content:gsub("/%*__MYSQL_G_MARKER__%*/;", "\\G;")
    content = content:gsub("%sON%s", "\n    ON ")
    content = content:gsub("%sAND%s", "     AND ")
    content = content:gsub("%sOR%s", "     OR ")
    data_file:close()

    data_file = assert(io.open(file_path, "w"))
    data_file:write(content)
    data_file:close()
end

vim.keymap.set("n", "<leader>f", format, { buffer = 0, desc = "SQL: [F]ormat" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "mysql", "sql", "psql" },
    callback = function(args)
        vim.keymap.set("n", "<leader>f", format, { buffer = args.buf, desc = "SQL: [F]ormat" })

        -- vim.opt_local.tabstop = 2
        -- vim.opt_local.shiftwidth = 2
        -- vim.opt_local.softtabstop = 2

        vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = args.buf,
            callback = function()
                format()
            end
        })
    end
})
