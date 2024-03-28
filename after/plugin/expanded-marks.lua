--TODO set local hard cup max key seq
local file_path = vim.fn.glob("~/.local/share/nvim") .. "/expaned_marks.json"
local max_key_seq = 5;

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

local function write_marks(file_path, data)
    assert(file_path ~= nil, "File path cannot be nil")
    assert(data ~= nil, "Data cannot be nil")

    local data_string = vim.json.encode(data)

    local file = io.open(file_path, "w")
    assert(file ~= nil)
    file:write(data_string)
    file:close()
end

-- Removes the values frome the table if the value doesn't starts with the
-- 'string.* and add a "size" key with current size of the values table
local function remove_unmatched_values(string, values)
    assert(string ~= nil or type(string) == "string",
        "Matching string should be of a type string and not nil.",
        "String:", string)
    assert(values ~= nil, "Values canot be nil")

    local size = 0
    for key, value in pairs(values) do
        assert(value ~= nil or type(value) == "string",
            "Value should only contain strings. Value:", value)

        if (not string.match(value, string .. '.*', 1)) then
            values[key] = nil
        else
            size = size + 1;
            values[key] = nil
            table.insert(values, size, value)
        end
    end

    values["size"] = size
    return values
end


--Listens to the pressed keys as long as a new is not a backtick or the total
--number of pressed keys doesn't exceed max_seq_keys
local function get_mark_key(max_key_seq)
    assert(max_key_seq ~= nil
        and type(max_key_seq) == "number"
        and max_key_seq > 0
        and max_key_seq < 50)

    local chars = ""
    local i = 2
    while true do
        local ch = vim.fn.getchar()

        -- If ch is not a capital letter then stop markering
        if (ch < 65 or ch > 90 and ch ~= 96) then
            return
        end
        -- 96 is a backtick sign "`"
        if (ch == 96) then
            break
        end

        chars = chars .. string.char(ch)

        if (i == max_key_seq) then
            break
        end

        i = i + 1
    end
    return chars
end

--Listens to the pressed keys as long as a new char is not a backtick or
--the total number of pressed keys doesn't exceed max_seq_keys
--if only one mark key remains, it'll be returned immediately
local function get_last_mark_key(max_key_seq, mark_keys, first_char)
    assert(max_key_seq ~= nil
        and type(max_key_seq) == "number"
        and max_key_seq > 0
        and max_key_seq < 50)
    assert(mark_keys ~= nil and type(mark_keys) == "table")
    assert(first_char ~= nil
        and type(first_char) == "number"
        and first_char >= 65 and first_char <= 90)


    local mark_key = ""
    local char_index = 1
    while true do
        local char = char_index == 1 and first_char or vim.fn.getchar()

        -- If ch is not a capital letter then stop markering
        if (char < 65 or char > 90 and char ~= 96) then
            return
        end
        -- 96 is a backtick sign "`"
        if (char == 96) then
            break
        end

        mark_key = mark_key .. string.char(char)

        if char_index == max_key_seq then
            break
        end

        mark_keys = remove_unmatched_values(mark_key, mark_keys)
        assert(mark_keys ~= nil, "Mark keys cannot be nil")

        local mark_keys_remains = mark_keys.size
        if mark_keys_remains == 1 then
            local v = table.remove(mark_keys, 1)
            return v
        elseif mark_keys_remains == 0 then
            return ""
        end

        char_index = char_index + 1
    end
    return mark_key
end

vim.keymap.set({ 'n' }, 'm', function()
    local ch = vim.fn.getchar()

    if ch < 65 or ch > 90 then
        vim.api.nvim_feedkeys("m" .. string.char(ch), "n", false)
        return
    end

    local chars = string.char(ch) .. get_mark_key(max_key_seq)

    local working_dir = vim.fn.getcwd()
    local marked_file = vim.api.nvim_buf_get_name(0)
    local data = get_json_decode_data(file_path)

    if data[working_dir] == nil then
        data[working_dir] = {}
    end

    data[working_dir][chars] = marked_file

    write_marks(file_path, data)
    print("Marks:[" .. chars .. "]", file_path)
end, {})

vim.keymap.set({ 'n' }, '`', function()
    local ch = vim.fn.getchar()

    -- If ch is not an uppercase letter behave like a usual '`'
    if ch < 65 or ch > 90 then
        vim.api.nvim_feedkeys('`' .. string.char(ch), "n", false)
        return
    end

    local marks = get_json_decode_data(file_path)
    local current_dir = vim.fn.getcwd()


    if marks[current_dir] == nil then
        marks[current_dir] = {}
    end


    local mark_key =
        get_last_mark_key(max_key_seq, Copy_keys(marks[current_dir]), ch)

    local marked_file = marks[current_dir][mark_key]
    -- No file was marked with this key
    if marked_file == nil then
        return
    end

    assert(vim.fn.bufexists(marked_file))
    vim.cmd(vim.fn.bufadd(marked_file) .. "b")
end)

function Marks()
    local marks = get_json_decode_data(file_path)
    local current_dir = vim.fn.getcwd()

    if marks[current_dir] == nil then
        marks[current_dir] = {}
    end

    table.sort(marks[current_dir])
    vim.api.nvim_echo({ { vim.inspect(marks[current_dir]) } },
        false, { verbose = false })
end

function MarksAll()
    local marks = get_json_decode_data(file_path)
    table.sort(marks)
    vim.api.nvim_echo({ { vim.inspect(marks) } },
        false, { verbose = false })
end

function Marks_delete(mark_key)
    assert(mark_key ~= nil, "mark_key cannot be nil")
    assert(string.len(mark_key) < 10, "mark_key is too long")

    local data = get_json_decode_data(file_path)
    local working_dir = vim.fn.getcwd()

    if data[working_dir] == nil then
        data[working_dir] = {}
        return
    end

    local mark = data[working_dir][mark_key]
    if (mark == nil) then
        print("MarksDelete:[" .. mark_key .. "] wasn't found")
        return
    end

    data[working_dir][mark_key] = nil

    table.sort(data[working_dir])
    write_marks(file_path, data)

    print("MarksDelete:[" .. mark_key .. "] was removed")
end

function Marks_set_max_key_seq(max_seq)
    assert(max_seq ~= nil)

    if (type(max_seq) == "string") then
        max_seq = tonumber(max_seq)
    end

    assert(type(max_seq) == "number" and max_seq > 0 and max_seq < 50)

    max_key_seq = max_seq
end

local marks_delete_completion = function(arg_lead, cmd_line, cursor_pos)
    local data = get_json_decode_data(file_path)
    local working_dir = vim.fn.getcwd()

    if data[working_dir] == nil then
        data[working_dir] = {}
        return
    end

    local mark_keys = {}
    local i = 1;
    for key, _ in pairs(data[working_dir]) do
        mark_keys[i] = key
        i = i + 1
    end

    return mark_keys
end

local mark_delete_user_command_opts =
{
    nargs = 1,
    complete = marks_delete_completion,
    desc = "Deletes a mark using the mark key"
}

vim.api.nvim_create_user_command("Marks", function() Marks() end,
    { desc = "Lists marked files for current dirrectory" })
vim.api.nvim_create_user_command("Mar", function() Marks() end,
    { desc = "Lists marked files for current dirrectory" })

vim.api.nvim_create_user_command("MarksAll", function() MarksAll() end,
    { desc = "Lists all marked files with their current dirrectories" })
vim.api.nvim_create_user_command("Marl", function() MarksAll() end,
    { desc = "Lists all marked files with their current dirrectories" })

vim.api.nvim_create_user_command("MarksMaxKeySeq",
    function(opts) Marks_set_max_key_seq(opts.args) end,
    { desc = "Sets a max sequens of characters of the mark-key", nargs = 1 })

vim.api.nvim_create_user_command("MarksDelete",
    function(opts) Marks_delete(opts.args) end,
    mark_delete_user_command_opts)
vim.api.nvim_create_user_command("Mard",
    function(opts) Marks_delete(opts.args) end,
    mark_delete_user_command_opts)
