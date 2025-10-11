local M = {}
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
        pcall(M.set_layout)
    end
})
vim.api.nvim_create_user_command("SwitchLayout", function()
    pcall(M.set_layout)
end, {})
M.set_layout = function()
    local handle, err = io.popen("xset -q")
    if not handle then
        print("Couldn't verify the key layout with error:", err)
        return
    end
    local result = handle:read("*a")
    handle:close()

    local _, _, layout = string.find(result, "LED mask:  (%d-)\n")
    if layout == nil then
        print("Couldn't match the patter to find the LED mask string:", layout)
        return
    else
    end

    if layout:match("00001000") then -- cz
        local opts = { noremap = true }
        vim.keymap.set("n", "ů", ";", opts)
        vim.keymap.set("n", "\"", ":", opts)

        vim.keymap.set("n", "§", "'", opts)
        vim.keymap.set("n", "!", "\"", opts)

        -- vim.keymap.set("n", ",", ",", opts)
        vim.keymap.set("n", "?", "<", opts)
        -- vim.keymap.set("n", ".", ".", opts)
        vim.keymap.set("n", ":", ">", opts)

        vim.keymap.set("n", "-", "/", opts)
        vim.keymap.set("n", "_", "?", opts)

        vim.keymap.set("n", ";", "`", opts)
        vim.keymap.set("n", "1", "!", opts)
        vim.keymap.set("n", "2", "@", opts)
        vim.keymap.set("n", "3", "#", opts)
        vim.keymap.set("n", "4", "$", opts)
        vim.keymap.set("n", "5", "%", opts)
        vim.keymap.set("n", "6", "^", opts)
        vim.keymap.set("n", "7", "&", opts)
        vim.keymap.set("n", "8", "*", opts)
        vim.keymap.set("n", "9", "(", opts)
        vim.keymap.set("n", "0", ")", opts)
        vim.keymap.set("n", "=", "-", opts)
        vim.keymap.set("n", "z", "y")
        vim.keymap.set("n", "zz", "yy", opts)

        print("CZ Layout was set")
    elseif layout:match("00000000") then -- us
        vim.keymap.del("n", "ů")
        vim.keymap.del("n", "\"")

        vim.keymap.del("n", "§")
        vim.keymap.del("n", "!")

        vim.keymap.del("n", "?")
        vim.keymap.del("n", ":")

        vim.keymap.del("n", "-")
        vim.keymap.del("n", "_")

        vim.keymap.del("n", ";")
        vim.keymap.del("n", "1")
        vim.keymap.del("n", "2")
        vim.keymap.del("n", "3")
        vim.keymap.del("n", "4")
        vim.keymap.del("n", "5")
        vim.keymap.del("n", "6")
        vim.keymap.del("n", "7")
        vim.keymap.del("n", "8")
        vim.keymap.del("n", "9")
        vim.keymap.del("n", "0")
        vim.keymap.del("n", "=")
        vim.keymap.del("n", "z")
        vim.keymap.del("n", "zz")
        print("US Layout was set")
    end
end
