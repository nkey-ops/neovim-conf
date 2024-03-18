local file_path = vim.fn.glob("~/.local/share/nvim") .. "/expaned_marks.json"

local function get_data_file(file_path)
    assert(file_path ~= nil, "File path cannot be nil")

    if not File_exists(file_path) then
        local file = io.open(file_path, "w")
        assert(file ~= nil)
        file:write("{}") -- creating intial JSON object
        file:close()
    end

    return io.open(file_path, "r")
end


local function get_json_decode_data(file_path)
    assert(file_path ~= nil, "File path cannot be nil")
    local file = get_data_file(file_path)
    local string_data = file:read("*a")
    file:close()

    return vim.json.decode(string_data, { object = true, array = true })
end

vim.keymap.set({ 'n' }, 'm', function()
    local ch = vim.fn.getchar()

    if ch < 65 or ch > 90 then
        vim.api.nvim_feedkeys("m" .. string.char(ch), "n", false)
        return
    end

    local working_dir = vim.fn.getcwd()
    local marked_file = vim.api.nvim_buf_get_name(0)
    local data = get_json_decode_data(file_path)

    if data[working_dir] == nil then
        data[working_dir] = {}
    end

    data[working_dir][string.char(ch)] = marked_file
    table.sort(data[working_dir])

    local data_string = vim.json.encode(data)

    local file = io.open(file_path, "w")
    assert(file ~= nil)
    file:write(data_string)
    file:close()
end, {})

vim.keymap.set({ 'n' }, '`', function()
    local ch = vim.fn.getchar()

    -- Is an uppercase latter if not then
    -- behave like a usual '`'?
    if ch < 65 or ch > 90 then
        vim.api.nvim_feedkeys("`" .. string.char(ch), "n", false)
        return
    end

    local decoded_data = get_json_decode_data(file_path)
    local current_dir = vim.fn.getcwd()

    if decoded_data[current_dir] == nil then
        decoded_data[current_dir] = {}
    end

    local marked_file = decoded_data[current_dir][string.char(ch)]
    -- No file was marked with this letter
    if marked_file == nil then
        return
    end

    assert(vim.fn.bufexists(marked_file))
    vim.cmd(vim.fn.bufadd(marked_file) .. "b")
end)

function Marks()
    local decoded_data = get_json_decode_data(file_path)
    local current_dir = vim.fn.getcwd()

    if decoded_data[current_dir] == nil then
        decoded_data[current_dir] = {}
    end

    vim.api.nvim_echo({ { vim.inspect(decoded_data[current_dir]) } },
        false, { verbose = false })
end

function MarksAll()
    vim.api.nvim_echo({ { vim.inspect(get_json_decode_data(file_path)) } },
        false, { verbose = false })
end

vim.api.nvim_create_user_command("Marks", function() Marks() end,
    { desc = "Lists marked files for current dirrectory" })
vim.api.nvim_create_user_command("MarksAll", function() MarksAll() end,
    { desc = "Lists all marked files with their current dirrectories" })
