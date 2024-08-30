-- see if the file exists
function File_exists(file_name)
    local f = io.open(file_name, "rb")
    if f then f:close() end
    return f ~= nil
end

--
-- print all line numbers and their contents
local function add_dynamic_java_ali(file_name, root_dir)
    if file_name == nil or root_dir == nil then
        error("[Add_dynamic_java_ali] File name or root dir is null")
    end
    if (not File_exists(root_dir .. "/target")) then
        error("[Add_dynamic_java_ali] /target directory wasn't found in " .. root_dir)
    end
    local f = io.open(file_name, "w+")
    if (f == nil) then
        error("[Add_dynamic_java_ali] File wasn't found" .. file_name)
        return
    end

    print("[Add_dynamic_java_ali] Bin alias added in file " .. file_name)

    --adding /bin path
    f:write("target=\"", root_dir, "/target/classes\"", "\n");
    f:write("alias ja=\"java -cp $target\"", "\n")

    io.close(f)
end

---- tests the functions above
---- adds alies to /home/deuru/.bash_aliases_dyn'
---- by REPLACING ALL ITS CONTENTS
----
function Add_java_alies()
    local file_name = vim.fn.glob("~/.bash_aliases_dyn")
    local root_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h')

    if (root_dir == nil or not File_exists(root_dir .. '/target')) then
        return
    end

    add_dynamic_java_ali(file_name, root_dir)
    print("Added alies to ", file_name)
end

function Exit_visual()
    local mode = vim.api.nvim_get_mode()['mode']
    if mode ~= 'v' and mode ~= 'V' then
        error("Exit_visual(): Can't exit visual mode because it isn't in visual mode")
        return
    end

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "x", false
    )
end

function Copy_keys(table)
    assert(table ~= nil and type(table) == "table")

    local keys = {}
    local i = 1
    for key, _ in pairs(table) do
        keys[i] = key
        i = i + 1
    end

    return keys
end
