-- Function to highlight text based on regex, color, and filetype
local default_colors = {
    "Red", "LightRed", "DarkRed",
    "Green", "LightGreen", "DarkGreen", "SeaGreen",
    "Blue", "LightBlue", "DarkBlue", "SlateBlue",
    "Cyan", "LightCyan", "DarkCyan",
    "Magenta", "	LightMagenta", "DarkMagenta",
    "Yellow", "LightYellow", "Brown", "DarkYellow",
    "Gray", "LightGray", "DarkGray",
    "Black", "White",
    "Orange", "Purple", "Violet"
}

--- @class HiReg
--- @field color string
--- @field regex string
--- @field highlight_group string

--- @type {[string]: HiReg}
local memory = {}

local function highlight_text(regex, color, filetype)
    -- Check if the color exists and is a string
    if type(regex) ~= "string" then
        vim.notify("Regex must be a non-empty string", vim.log.levels.ERROR)
        return
    end

    -- Check if the color exists and is a string
    -- TODO asign the color that was not used
    -- TODO check if the color exists
    if color then
        assert(type(color) ~= "string", "color should be of a type 'string'")
    else
        color = default_colors[math.random(#default_colors)]
    end

    -- Check if the filetype exists and is a string
    -- TODO apply to any filetype
    if filetype then
        assert(type(filetype) ~= "string", "filetype should be of a type 'string'")
    else
        filetype = vim.bo.filetype
    end

    -- TODO escape color
    -- Create highlight group if it doesn't exist
    -- TODO deal with conflicts when gsub will
    -- replace from different pattersn characters and turn them into the same group
    local highlight_group = "HiReg_" .. regex:gsub("%W", "_")
    vim.cmd(string.format("highlight %s guifg='%s'", highlight_group, color))


    -- Define the command to apply the highlight to the specified filetype
    -- if &filetype == "%s"
    -- endif
    local command = string.format(
        [[
        silent! syntax match %s "\v%s"
         ]],
        highlight_group, -- Highlight Group Name
        regex            -- Escape slashes in regex
    )

    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetype,
        callback = function() vim.cmd(command) end
    })
    if vim.bo.filetype == filetype then
        vim.cmd(command)
    end

    memory[regex] = {
        regex = regex,
        color = color,
        highlight_group = highlight_group
    }

    vim.notify("Highlight applied to " .. filetype .. " buffers", vim.log.levels.INFO)
end
-- highlight for any file type
-- hightlight for a specific file type
-- highlight for a current buffer
--
-- random color
--
-- when custom highlight updates, save it
-- support quotes for regex and colors
--
-- Define the command
vim.api.nvim_create_user_command(
    "HiReg",
    function(opts)
        local args = opts.fargs
        local regex = args[1]
        local color = args[2]
        local filetype = args[3]
        if not regex then
            vim.notify("Usage: HighlightRegex <regex> [color] [filetype]", vim.log.levels.ERROR)
            return
        end

        highlight_text(regex, color, filetype)
    end,
    { nargs = "+", desc = "Highlight text in a specified filetype buffer" }
)
