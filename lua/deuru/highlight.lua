-- Function to highlight text based on regex, color, and filetype
local function highlight_text(regex, color, filetype)
    -- Check if the color exists and is a string
    if type(regex) ~= "string" then
        vim.notify("Regex must be a non-empty string", vim.log.levels.ERROR)
        return
    end

    -- Check if the color exists and is a string
    if type(color) ~= "string" then
        vim.notify("Color must be a non-empty string", vim.log.levels.ERROR)
        return
    end
    -- Check if the filetype exists and is a string
    if type(filetype) ~= "string" then
        vim.notify("Filetype must be a non-empty string", vim.log.levels.ERROR)
        return
    end

    -- TODO escape color
    -- Create highlight group if it doesn't exist
    local highlight_group = "CustomHighlight_" .. regex:gsub("%W", "_")
    print(color)
    vim.cmd(string.format("highlight %s guifg='%s'",
        highlight_group, color))

    -- Define the command to apply the highlight to the specified filetype
    -- if &filetype == "%s"
    -- endif
    local command = string.format(
        [[
        silent! syntax match %s "\v%s"
        silent! highlight default link "%s" guibg="%s"
         ]],
        -- filetype,                                    -- Escape single quotes in filetype for shell
        "CustomHighlight_" .. regex:gsub("%W", "_"), -- Clean and create highlight name
        regex,                                       -- Escape slashes in regex
        "CustomHighlight_" .. regex:gsub("%W", "_"), -- Highlight name
        highlight_group                              -- Highlight Group Name
    )

    -- vim.cmd("autocmd BufWinEnter * " .. command)
    vim.cmd(command)

    vim.notify("Highlight applied to " .. filetype .. " buffers", vim.log.levels.INFO)
end

-- Define the command
vim.api.nvim_create_user_command(
    "HighlightRegex",
    function(opts)
        local args = opts.fargs
        P(args)
        local regex = args[1]
        local color = args[2]
        local filetype = args[3]
        if not regex or not color or not filetype then
            vim.notify("Usage: HighlightRegex <regex> <color> <filetype>", vim.log.levels.ERROR)
            return
        end

        highlight_text(regex, color, filetype)
    end,
    { nargs = "+", desc = "Highlight text in a specified filetype buffer" }
)
