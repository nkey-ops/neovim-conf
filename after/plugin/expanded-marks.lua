--todo max key seq set is lower by one
-- The mark's location moves to the bottom of the file after formatting
-- marks are'nt saved after closing the buffer
--TODO highlight after the jump?
--TODO set local hard cup max key seq
local M = {
    opts = {
        global_marks_file_path = vim.fn.glob("~/.local/share/nvim") .. "/expaned_marks.json",
        local_marks_file_path = vim.fn.glob("~/.local/share/nvim") .. "/expaned_local_marks.json",
        max_key_seq = 5,
        local_marks_name_space = vim.api.nvim_create_namespace("local_marks")
    }
}

M.get_data_file = function(file_path)
    assert(file_path ~= nil, "File path cannot be nil")
    assert(type(file_path) == "string", "File path should be of a type string")

    if not File_exists(file_path) then
        local file = io.open(file_path, "w")
        assert(file ~= nil)
        file:write("{}") -- creating intial JSON object
        file:close()
    end

    return io.open(file_path, "r")
end

-- @working_dir optional
M.get_json_decode_data = function(file_path, working_dir)
    assert(file_path ~= nil, "File path cannot be nil")
    assert(type(file_path) == "string", "File path should be of a type string")
    assert(string.match(file_path, '%.json$'), "File should of type .json")

    if (working_dir ~= nil) then
        assert(type(working_dir) == "string",
            "Working directory name should be of a type string " .. working_dir)
    end

    local file = M.get_data_file(file_path)
    local string_data = file:read("*a")
    file:close()

    local decoded_file = vim.json.decode(string_data, { object = true, array = true })

    if working_dir ~= nil then
        if decoded_file[working_dir] == nil then
            decoded_file[working_dir] = {}
        end
    end

    return decoded_file
end

M.write_marks = function(file_path, data)
    assert(file_path ~= nil, "File path cannot be nil")
    assert(string.match(file_path, '%.json$'), "File should of type .json")
    assert(data ~= nil, "Data cannot be nil")
    assert(type(data) == "table", "Data should be of type table")

    local encoded_data = vim.json.encode(data)

    local file = io.open(file_path, "w")
    assert(file ~= nil)
    file:write(encoded_data)
    file:close()
end


-- Removes the values from the table if the value doesn't starts with the
-- 'string.* and add a "size" key with current size of the values table
M.remove_unmatched_values = function(pattern, values)
    assert(pattern ~= nil or type(pattern) == "string",
        "Matching string should be of a type string and not nil.",
        "String:", pattern)
    assert(values ~= nil, "Values canot be nil")

    local size = 0
    for key, value in pairs(values) do
        assert(value ~= nil, "Value should not be nil")
        assert(type(value) == "string",
            "Values should only contain strings. Value:", value)

        if (pattern.match(value, '^' .. pattern) == nil) then
            values[key] = nil
        else
            size = size + 1;
            values[key] = nil
            table.insert(values, size, value)
        end
    end
    return size
end

function Test()
    local t = {}
    table.insert(t, "OCR")
    table.insert(t, "A")
    table.insert(t, "P")
    table.insert(t, "C")

    local r = M.remove_unmatched_values("C", t);
    print(vim.inspect(r))
end

--Listens to the pressed keys as long as a new is not a back tick or the total
--number of pressed keys doesn't exceed max_seq_keys
M.get_mark_key = function(max_key_seq, first_char)
    assert(max_key_seq ~= nil
        and type(max_key_seq) == "number"
        and max_key_seq > 0
        and max_key_seq < 50)

    assert(first_char ~= nil, "First Char cannot be nil")
    assert(type(first_char) == "number", "First Char should be of type number")
    assert((first_char >= 65 and first_char <= 90
            or (first_char >= 97 and first_char <= 122)),
        "First Char should be [a-zA-Z] character")


    local chars = string.char(first_char)
    local char_counter = 1
    while true do
        local ch = vim.fn.getchar()
        char_counter = char_counter + 1

        -- If ch is not [a-zA-Z] and not a back tick stop markering
        if ((type(ch) ~= "number" or ch < 65 or (ch > 90 and ch < 97)
                or ch > 122) and ch ~= 96) then
            return nil
        end

        -- 96 is a back tick sign "`"
        if (ch == 96) then
            break
        end

        chars = chars .. string.char(ch)

        if (char_counter == max_key_seq) then
            break
        end
    end
    return chars
end

--Listens to the pressed keys as long as a new char is not a back tick or
--the total number of pressed keys doesn't exceed max_seq_keys
--if only one mark key remains, it'll be returned immediately
--if zero mark keys remains, a nil will be returned
M.get_last_mark_key = function(max_key_seq, mark_keys, first_char)
    assert(max_key_seq ~= nil
        and type(max_key_seq) == "number"
        and max_key_seq > 0
        and max_key_seq < 50)
    assert(mark_keys ~= nil and type(mark_keys) == "table")
    assert(first_char ~= nil
        and type(first_char) == "number"
        and (first_char >= 65 and first_char <= 90
            or (first_char >= 97 and first_char <= 122))) -- [a-zA-Z]


    local mark_key = ""
    local char_counter = 0
    while true do
        local char = char_counter == 0 and first_char or vim.fn.getchar()
        char_counter = char_counter + 1

        -- If ch is not [a-zA-Z] then stop markering
        if (type(char) ~= "number"
            or (char < 65 or (char > 90 and char < 97) or char > 122)
                and char ~= 96) then
            return
        end
        -- 96 is a back tick sign "`"
        if (char == 96) then
            break
        end

        mark_key = mark_key .. string.char(char)

        if char_counter == max_key_seq then
            break
        end

        local mark_keys_remains = M.remove_unmatched_values(mark_key, mark_keys)
        assert(mark_keys ~= nil, "Mark keys cannot be nil")

        if mark_keys_remains == 1 then
            return table.remove(mark_keys, 1)
        elseif mark_keys_remains == 0 then
            return nil
        end
    end
    return mark_key
end

-- @start_char
--TODO don't create new marks but edit old ones
M.set_local_mark = function(first_char)
    assert(first_char ~= nil, "start_char cannot be nil")
    assert(type(first_char) == "number", "start_char should be of type number")
    assert(first_char >= 97 and first_char <= 122,
        "start_char should be a lowercase ascii character[a-z]")

    local mark_key = M.get_mark_key(M.opts.max_key_seq, first_char)
    if (mark_key == nil) then return end

    local local_buffer = vim.api.nvim_buf_get_name(0)
    local local_buffer_id = vim.api.nvim_get_current_buf()
    local buffers = M.get_json_decode_data(M.opts.local_marks_file_path, local_buffer)

    local extmark_opts = { sign_text = string.sub(mark_key, 1, 2) }
    if buffers[local_buffer][mark_key] ~= nil then
        extmark_opts.id = buffers[local_buffer][mark_key][1]
    end

    local pos = vim.api.nvim_win_get_cursor(0)
    local marked_line = vim.api.nvim_buf_get_lines(
        local_buffer_id, pos[1] - 1, pos[1], false)[1]

    extmark_opts.end_col = string.len(marked_line)

    local mark_id = vim.api.nvim_buf_set_extmark(
        local_buffer_id, M.opts.local_marks_name_space, pos[1] - 1, 0,
        extmark_opts)


    buffers[local_buffer][mark_key] = { mark_id, pos[1] - 1, 0 }

    M.write_marks(M.opts.local_marks_file_path, buffers)

    print(string.format("Marks:[%s:%s] \"%s\"", mark_key, pos[1], marked_line))
end

M.jump_to_local_mark = function(start_char)
    assert(start_char ~= nil, "start_char cannot be nil")
    assert(type(start_char) == "number", "start_char should be of type number")
    assert(start_char >= 97 and start_char <= 122,
        "start_char should be a lowercase ascii character[a-z]")

    local local_buffer_name = vim.api.nvim_buf_get_name(0)
    local local_marks = M.get_json_decode_data(M.opts.local_marks_file_path, local_buffer_name)
        [local_buffer_name]

    local mark_key =
        M.get_last_mark_key(M.opts.max_key_seq,
            Copy_keys(local_marks), start_char)

    if mark_key == nil then return end -- key wasn't
    local mark_id = local_marks[mark_key][1]

    local position = vim.api.nvim_buf_get_extmark_by_id(
        0, M.opts.local_marks_name_space, mark_id, {})

    position[1] = position[1] + 1; --api`s line positon is zero-based
    vim.api.nvim_win_set_cursor(0, position)
end

M.set_global_mark = function(first_char)
    local mark_key = M.get_mark_key(M.opts.max_key_seq, first_char)
    if (mark_key == nil) then return end

    local working_dir = vim.fn.getcwd()
    local marked_file = vim.api.nvim_buf_get_name(0)
    local data = M.get_json_decode_data(M.opts.global_marks_file_path, working_dir)

    data[working_dir][mark_key] = marked_file

    M.write_marks(M.opts.global_marks_file_path, data)
    print("Marks:[" .. mark_key .. "]", marked_file)
end

M.open_global_mark = function(first_char)
    assert(first_char ~= nil and type(first_char) == "number",
        "First mark key character value should not be nil and be of a type number")
    assert(first_char >= 65 and first_char <= 90, "First mark key character value should be [A-Z]")

    local working_dir = vim.fn.getcwd()
    local marks = M.get_json_decode_data(M.opts.global_marks_file_path, working_dir)

    local mark_key =
        M.get_last_mark_key(
            M.opts.max_key_seq, Copy_keys(marks[working_dir]), first_char)

    if mark_key == nil then return end

    local marked_file = marks[working_dir][mark_key]
    -- No file was marked with this key
    if marked_file == nil then
        return
    end

    assert(vim.fn.bufexists(marked_file))
    vim.cmd(vim.fn.bufadd(marked_file) .. "b")
end

-- Global Functions

function Marks_global()
    local working_dir = vim.fn.getcwd()
    local marks = M.get_json_decode_data(
        M.opts.global_marks_file_path, working_dir)[working_dir]

    table.sort(marks)
    vim.api.nvim_echo({ { vim.inspect(marks) } },
        false, { verbose = false })
end

function Marks_global_all()
    local marks = M.get_json_decode_data(M.opts.global_marks_file_path)
    table.sort(marks)

    vim.api.nvim_echo({ { vim.inspect(marks) } },
        false, { verbose = false })
end

function Marks_local()
    local local_buffer_name = vim.api.nvim_buf_get_name(0)
    local local_buffer_id = vim.api.nvim_get_current_buf()
    local marks = M.get_json_decode_data(
        M.opts.local_marks_file_path, local_buffer_name)[local_buffer_name]

    table.sort(marks)
    for mark_key, mark in pairs(marks) do
        local pair =
            vim.api.nvim_buf_get_extmark_by_id(
                local_buffer_id, M.opts.local_marks_name_space, mark[1], {})

        assert(pair ~= nil and pair[1] ~= nil)

        marks[mark_key] =
            vim.api.nvim_buf_get_lines(
                local_buffer_id, pair[1], pair[1] + 1, true)[1]
    end

    vim.api.nvim_echo({ { vim.inspect(marks) } },
        false, { verbose = false })
end

-- Shows raw raw data for performance reasons
function Marks_local_all()
    local local_buffer_name = vim.api.nvim_buf_get_name(0)
    local marks = M.get_json_decode_data(
        M.opts.local_marks_file_path, local_buffer_name)

    table.sort(marks)

    vim.api.nvim_echo({ { vim.inspect(marks) } },
        false, { verbose = false })
end

function Marks_global_delete(mark_key)
    assert(mark_key ~= nil, "mark_key cannot be nil")
    assert(string.len(mark_key) < 10, "mark_key is too long")

    local working_dir = vim.fn.getcwd()
    local data = M.get_json_decode_data(M.opts.global_marks_file_path)

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

    M.write_marks(M.opts.global_marks_file_path, data)

    print("MarksDelete:[" .. mark_key .. "] was removed")
end

function Marks_local_delete(mark_key)
    assert(mark_key ~= nil, "mark_key cannot be nil")
    assert(type(mark_key) == "string", "mark_key should be of type strin")
    assert(string.len(mark_key) < 10, "mark_key is too long")

    local current_buffer_name = vim.api.nvim_buf_get_name(0)
    local marks = M.get_json_decode_data(M.opts.local_marks_file_path, current_buffer_name)

    local mark = marks[current_buffer_name][mark_key]
    if (mark == nil) then
        print("Marks:[" .. mark_key .. "] wasn't found")
        return
    end

    vim.api.nvim_buf_del_extmark(0, M.opts.local_marks_name_space, mark[1])
    marks[current_buffer_name][mark_key] = nil

    M.write_marks(M.opts.local_marks_file_path, marks)

    print("Marks:[" .. mark_key .. "] was removed")
end

function Marks_set_max_key_seq(max_seq)
    assert(max_seq ~= nil)

    if (type(max_seq) == "string") then
        max_seq = tonumber(max_seq)
    end

    assert(type(max_seq) == "number" and max_seq > 0 and max_seq < 50)

    M.opts.max_key_seq = max_seq
end

function Update_local_marks()
    local local_buffer_id = vim.api.nvim_get_current_buf()
    local local_buffer_name = vim.api.nvim_buf_get_name(local_buffer_id)
    local marks = M.get_json_decode_data(
        M.opts.local_marks_file_path, local_buffer_name)

    for mark_key, mark in pairs(marks[local_buffer_name]) do
        local pair =
            vim.api.nvim_buf_get_extmark_by_id(
                local_buffer_id, M.opts.local_marks_name_space, mark[1], {})

        assert(pair ~= nil and pair[1] ~= nil and pair[2] ~= nil )

        marks[local_buffer_name][mark_key] = { mark[1], pair[1], pair[2] }
    end

    M.write_marks(M.opts.local_marks_file_path, marks)
end

-- TIME Coplexity: O(N+M)
-- where N is then number of source marks and
-- M is the number of parks that a present in the buffer's name space
function Restore_local_marks()
    local current_buffer_id = vim.api.nvim_get_current_buf()
    local current_buffer_name = vim.api.nvim_buf_get_name(current_buffer_id)
    local local_marks = M.get_json_decode_data(
        M.opts.local_marks_file_path, current_buffer_name)[current_buffer_name]
    local name_space_marks =
        vim.api.nvim_buf_get_extmarks(
            current_buffer_id, M.opts.local_marks_name_space, 0, -1, {})
    local max_lines = vim.api.nvim_buf_line_count(current_buffer_id)

    for mark_key, mark in pairs(local_marks) do
        local was_found = false

        --TODO assert that n_space mark doesn't contain marks
        --that aren't present in the source
        -- reseting the mark that has a position that is out of bounds
        for n_key, n_mark in pairs(name_space_marks) do
            if mark[1] == n_mark[1] then -- found the mark
                was_found = true
                name_space_marks[n_key] = nil
                if n_mark[2] == max_lines then -- then mark is out of the bounds
                    --TODO what if mark[1] id isn't in asceeding order and overlaps with
                    --a newly created one
                    vim.api.nvim_buf_set_extmark(current_buffer_id,
                        M.opts.local_marks_name_space, mark[2], mark[3], {
                            id = mark[1],
                            sign_text = string.sub(mark_key, 1, 2)
                        })
                    break
                end
            end
        end

        -- adding a new mark
        if not was_found then
            vim.api.nvim_buf_set_extmark(current_buffer_id,
                M.opts.local_marks_name_space, mark[2], mark[3],
                { id = mark[1], sign_text = string.sub(mark_key, 1, 2)
                })
        end
    end
end

-- Key-binds

vim.keymap.set({ 'n' }, 'm', function()
    local ch = vim.fn.getchar()

    if (ch >= 97 and ch <= 122) then --[a-z]
        -- vim.api.nvim_feedkeys("m" .. string.char(ch), "n", false)
        M.set_local_mark(ch)
        return
    elseif ch >= 65 and ch <= 90 then --[A-Z]
        M.set_global_mark(ch)
        return
    else
        return
    end
end, {})

vim.keymap.set({ 'n' }, '`', function()
    local ch = vim.fn.getchar()

    if (ch >= 97 and ch <= 122) then --[a-z]
        M.jump_to_local_mark(ch)
        return
    elseif ch >= 65 and ch <= 90 then --[A-Z]
        M.open_global_mark(ch)
        return
    else
        return
    end
end)


local marks_global_delete_completion = function(arg_lead, cmd_line, cursor_pos)
    local working_dir = vim.fn.getcwd()
    local marks = M.get_json_decode_data(M.opts.global_marks_file_path)

    table.sort(marks[working_dir])

    local mark_keys = {}
    local i = 1;
    for key, _ in pairs(marks[working_dir]) do
        mark_keys[i] = key
        i = i + 1
    end

    return mark_keys
end

local marks_local_delete_completion = function(arg_lead, cmd_line, cursor_pos)
    local current_buffer = vim.api.nvim_buf_get_name(0)
    local marks = M.get_json_decode_data(M.opts.local_marks_file_path, current_buffer)

    table.sort(marks[current_buffer])

    local mark_keys = {}
    local i = 1;
    for key, _ in pairs(marks[current_buffer]) do
        mark_keys[i] = key
        i = i + 1
    end

    return mark_keys
end



vim.api.nvim_create_user_command("MarksGlobal", function() Marks_global() end,
    { desc = "Lists marked files for current dirrectory" })
vim.api.nvim_create_user_command("MarksLocal", function() Marks_local() end,
    { desc = "Lists buffer local marks" })

vim.api.nvim_create_user_command("MarksGlobalAll", function() Marks_global_all() end,
    { desc = "Lists all marked files with their current dirrectories" })
vim.api.nvim_create_user_command("MarksLocalAll", function() Marks_local_all() end,
    { desc = "Lists all local marks with their buffer names" })

vim.api.nvim_create_user_command("MarksGlobalDelete",
    function(opts) Marks_global_delete(opts.args) end, {
        nargs = 1,
        complete = marks_global_delete_completion,
        desc = "Deletes a global mark using the mark's key"
    })
vim.api.nvim_create_user_command("MarksLocalDelete",
    function(opts) Marks_local_delete(opts.args) end, {
        nargs = 1,
        complete = marks_local_delete_completion,
        desc = "Deletes a local mark using the mark's key"
    })

vim.api.nvim_create_user_command("MarksMaxKeySequence",
    function(opts) Marks_set_max_key_seq(opts.args) end,
    { desc = "Sets a max sequens of characters of the mark-key", nargs = 1 })


vim.api.nvim_create_user_command("Mark",
    function(opts)
        print(
            vim.inspect(
                vim.api.nvim_buf_get_extmarks(
                    0, M.opts.local_marks_name_space, 0, -1, {})
            )
        )
    end, {})


-- Autocmds
vim.api.nvim_create_autocmd({ "BufWrite" }, {
    pattern = "*",
    callback = function()
        Update_local_marks()
    end
})

--TODO fix
vim.api.nvim_create_autocmd({ "BufNew" }, {
    pattern = "*",
    callback = function()
        Restore_local_marks()
    end
})






