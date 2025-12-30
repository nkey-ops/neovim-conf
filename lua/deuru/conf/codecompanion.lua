local M = {
    input_border_hl = "InputBorder",
    input_edit_hl = "InputEdit",
    chat_border_hl = "ChatBorder"
}

M.switch_win = function()
    local win = vim.api.nvim_get_current_win()
    local adjecent_win = vim.api.nvim_win_get_var(win, "cc_adjecent_win")
    vim.fn.win_gotoid(adjecent_win)
end
M.send_input = function()
    local input_buf = vim.api.nvim_get_current_buf()
    local input_win = vim.api.nvim_get_current_win()
    local chat_win = vim.api.nvim_win_get_var(input_win, "cc_adjecent_win")
    local chat_buf = vim.api.nvim_win_get_buf(chat_win)
    local input_buf_line_counter = vim.api.nvim_buf_line_count(input_buf)
    local chat_buf_line_counter = vim.api.nvim_buf_line_count(chat_buf)
    local input_lines = vim.api.nvim_buf_get_lines(input_buf, 0, input_buf_line_counter, false)
    vim.api.nvim_buf_set_lines(
        chat_buf, chat_buf_line_counter - 1, chat_buf_line_counter, true, input_lines)
    vim.api.nvim_buf_set_lines(
        input_buf, 0, input_buf_line_counter, true, { "" })

    vim.api.nvim_buf_call(chat_buf, function()
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<C-s>", true, false, true),
            "x",
            false
        )
    end)
end

M.open = function()
    vim.cmd("hi NormalFloat guibg=Black")
    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", { clear = false })
    vim.api.nvim_create_autocmd({ "User" }, {
        pattern = { "CodeCompanionChatOpened", "CodeCompanionChatHidden" },
        group = group,
        once = true,
        callback = function(args)
            local wins = vim.fn.win_findbuf(args.data.bufnr)
            for _, win in pairs(wins) do
                -- chat window should only be closed via the
                -- BunWinLeave so its options could be stored
                if not vim.w[win].cc_adjecent_win then
                    vim.api.nvim_win_hide(win)
                end
            end

            if #wins == 1 then
                M.open_with_buf(args.data.bufnr)
            elseif #wins == 2 then
                vim.api.nvim_exec_autocmds("BufWinLeave", {
                    group = group,
                    buffer = args.data.bufnr,
                })
            end
        end,
    })
    vim.cmd("CodeCompanionChat Toggle")
end

--- @return boolean true if the options are nil or have a proper structure
M.is_valid = function(cc_opts)
    if not cc_opts then
        return true
    end

    if not cc_opts.input
        or not cc_opts.input.win_opts
        or not cc_opts.chat
        or not cc_opts.chat.win_opts then
        return false
    end

    return true
end

M.open_with_buf = function(buf)
    assert(type(buf) == "number", "buf should be of type number")
    assert(vim.api.nvim_buf_is_valid(buf), "buf: ", buf, " is not valid")

    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", { clear = false })

    local chat_buf = buf
    local cc_opts = vim.b[chat_buf].cc_opts
    if not M.is_valid(cc_opts) then
        cc_opts = nil
    end

    local input_buf = nil
    local chat_win_opts
    local input_win_opts

    if cc_opts then
        input_buf = cc_opts.input.buf
        chat_win_opts = cc_opts.chat.win_opts
        input_win_opts = cc_opts.input.win_opts
    else
        local width_1 = math.floor(0.5 * vim.o.columns)
        local height_1 = math.floor(0.6 * vim.o.lines)
        local width_2 = math.floor(0.5 * vim.o.columns)
        local height_2 = math.floor(0.1 * vim.o.lines)

        chat_win_opts = {
            relative = "editor",
            -- centering based on the remain space vertically and horizontally
            col = math.floor((vim.o.columns - width_1) / 2),
            -- height_* + 2 - account for horizontal height of the borders
            row = math.floor((vim.o.lines - (height_1 + 2 + height_2 + 2)) / 2),
            width = width_1,
            height = height_1,
            zindex = 60
        }

        input_win_opts = {
            relative = "editor",
            -- centering based on the remain space vertically and horizontally
            col = math.floor((vim.o.columns - width_2) / 2),
            -- height_* + 2 - account for horizontal height of the borders
            row = math.floor((vim.o.lines - (height_1 + 2 + height_2 + 2)) / 2) + height_1 + 2,
            width = width_2,
            height = height_2,
            zindex = 61
        }

        input_buf = vim.api.nvim_create_buf(true, true)
    end

    local chat_win = vim.api.nvim_open_win(chat_buf, false, chat_win_opts)
    local input_win = vim.api.nvim_open_win(input_buf, true, input_win_opts)

    vim.api.nvim_win_set_var(chat_win, "cc_adjecent_win", input_win)
    vim.api.nvim_win_set_var(input_win, "cc_adjecent_win", chat_win)
    vim.api.nvim_buf_set_var(chat_buf, "cc_input_buf", input_buf)
    vim.bo[input_buf].filetype = "markdown"
    vim.wo[chat_win].number = false
    vim.wo[input_win].number = false
    vim.wo[chat_win].relativenumber = false
    vim.wo[input_win].relativenumber = false
    vim.wo[chat_win].signcolumn = "no"
    vim.wo[input_win].signcolumn = "no"
    vim.wo[chat_win].colorcolumn = ""
    vim.wo[input_win].colorcolumn = ""
    vim.wo[chat_win].cursorline = false
    vim.wo[input_win].cursorline = false
    vim.wo[chat_win].cursorcolumn = false
    vim.wo[input_win].cursorcolumn = false
    vim.wo[chat_win].list = false
    vim.wo[input_win].list = false

    local chat_wins
    local chat_glob
    local input_wins
    if cc_opts then
        chat_wins = cc_opts.chat.wins
        chat_glob = cc_opts.chat.glob
        input_wins = cc_opts.input.wins
    end

    local ui_wins = {
        chat = M.generate_chat_ui(chat_win_opts, chat_wins, chat_glob),
        input = M.generate_input_ui(input_win_opts, input_wins)
    }

    local cleanup = function(buf)
        local cc_opts = {
            chat = { buf = chat_buf },
            input = { buf = input_buf }
        }
        if vim.api.nvim_win_is_valid(chat_win) then
            cc_opts.chat.win_opts = vim.api.nvim_win_get_config(chat_win)
            vim.api.nvim_win_hide(chat_win)
        end

        if vim.api.nvim_win_is_valid(input_win) then
            cc_opts.input.win_opts = vim.api.nvim_win_get_config(input_win)
            vim.api.nvim_win_hide(input_win)
        end

        cc_opts.chat.wins = ui_wins.chat.wins
        cc_opts.chat.glob = ui_wins.chat.glob
        cc_opts.input.wins = ui_wins.input.wins
        local wins = {
            ui_wins.chat.wins.top,
            ui_wins.chat.wins.bot,
            ui_wins.chat.wins.left,
            ui_wins.chat.wins.right,
            ui_wins.input.wins.top,
            ui_wins.input.wins.bot,
            ui_wins.input.wins.left,
            ui_wins.input.wins.right,
        }
        for _, win in ipairs(wins) do
            if vim.api.nvim_win_is_valid(win.id) then
                vim.api.nvim_win_hide(win.id)
            end
        end

        vim.api.nvim_buf_set_var(chat_buf, "cc_opts", cc_opts)
        vim.api.nvim_del_augroup_by_id(group)
    end

    vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
        group = group,
        buffer = chat_buf,
        once = true,
        callback = function(args)
            cleanup(args.buf)
        end
    })
    vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
        group = group,
        buffer = input_buf,
        once = true,
        callback = function(args)
            cleanup(args.buf)
        end
    })

    vim.keymap.set("n", "<C-w><C-w>", M.switch_win, { buffer = chat_buf })
    vim.keymap.set("n", "<C-w><C-w>", M.switch_win, { buffer = input_buf })
    vim.keymap.set("n", "<C-s>", M.send_input, { buffer = input_buf })

    -- if true then
    --     return
    -- end
    --
    vim.api.nvim_create_autocmd({ 'WinResized' }, {
        group = group,
        buffer = input_buf,
        callback = function(args)
            -- TODO: limit the input and chat window resize to -1 of the max to fit ui wins
            local resize = function()
                if not vim.api.nvim_win_is_valid(input_win) then
                    return
                end

                --
                -- wipe input wins and redo creation of them
                local wins = {
                    ui_wins.input.wins.top,
                    ui_wins.input.wins.bot,
                    ui_wins.input.wins.left,
                    ui_wins.input.wins.right,
                }
                for _, win in ipairs(wins) do
                    if vim.api.nvim_win_is_valid(win.id) then
                        vim.api.nvim_win_hide(win.id)
                    end
                end
                -- clear buffers
                vim.api.nvim_buf_set_lines(ui_wins.input.wins.top.buf, 0, -1, true, {})
                vim.api.nvim_buf_set_lines(ui_wins.input.wins.bot.buf, 0, -1, true, {})
                vim.api.nvim_buf_set_lines(ui_wins.input.wins.left.buf, 0, -1, true, {})
                vim.api.nvim_buf_set_lines(ui_wins.input.wins.right.buf, 0, -1, true, {})

                -- normalize the area of the input win to fit input ui wins
                -- TODO: account for tab line, cmdline height, left side columsn any right side columns
                local win_pos = vim.api.nvim_win_get_position(input_win)

                local limit_input_win = function()
                    input_win_opts.row = math.min(math.max(win_pos[1], 1), vim.o.lines - 3)
                    input_win_opts.col = math.min(math.max(win_pos[2], 3), vim.o.columns - 3)
                    input_win_opts.height = vim.api.nvim_win_get_height(input_win)
                    input_win_opts.width = vim.api.nvim_win_get_width(input_win)

                    if input_win_opts.col + input_win_opts.width - 1 > vim.o.columns - 3 then
                        input_win_opts.width = vim.o.columns - 3 - input_win_opts.col
                    end

                    if input_win_opts.row + input_win_opts.height - 1 > vim.o.lines - 3 then
                        input_win_opts.height = vim.o.lines - 3 - input_win_opts.row
                    end
                end

                limit_input_win()
                vim.api.nvim_win_set_config(input_win, input_win_opts)
                -- TODO: not let overlap chat

                ui_wins.input = M.generate_input_ui(input_win_opts, {
                    top = { buf = ui_wins.input.wins.top.buf },
                    bot = { buf = ui_wins.input.wins.bot.buf },
                    right = { buf = ui_wins.input.wins.right.buf },
                    left = { buf = ui_wins.input.wins.left.buf }
                })
            end

            -- change of window position will only occur on the next tick
            vim.schedule(function() resize() end)
        end
    })

    vim.api.nvim_create_autocmd({ 'WinResized' }, {
        group = group,
        buffer = chat_buf,
        callback = function(args)
            -- TODO: limit the chat and chat window resize to -1 of the max to fit ui wins
            local resize = function()
                if not vim.api.nvim_win_is_valid(chat_win) then
                    return
                end

                --
                -- wipe chat wins and redo creation of them
                local wins = {
                    ui_wins.chat.wins.top,
                    ui_wins.chat.wins.bot,
                    ui_wins.chat.wins.left,
                    ui_wins.chat.wins.right,
                }
                for _, win in ipairs(wins) do
                    if vim.api.nvim_win_is_valid(win.id) then
                        vim.api.nvim_win_hide(win.id)
                    end
                end

                -- clear buffers
                vim.api.nvim_buf_set_lines(ui_wins.chat.wins.top.buf, 0, -1, true, {})
                vim.api.nvim_buf_set_lines(ui_wins.chat.wins.bot.buf, 0, -1, true, {})
                vim.api.nvim_buf_set_lines(ui_wins.chat.wins.left.buf, 0, -1, true, {})
                vim.api.nvim_buf_set_lines(ui_wins.chat.wins.right.buf, 0, -1, true, {})

                -- normalize the area of the chat win to fit chat ui wins
                -- TODO: account for tab line, cmdline height, left side columsn any right side columns
                local win_pos = vim.api.nvim_win_get_position(chat_win)

                local limit_chat_win = function()
                    chat_win_opts.row = math.min(math.max(win_pos[1], 1), vim.o.lines - 3)
                    chat_win_opts.col = math.min(math.max(win_pos[2], 3), vim.o.columns - 3)
                    chat_win_opts.height = vim.api.nvim_win_get_height(chat_win)
                    chat_win_opts.width = vim.api.nvim_win_get_width(chat_win)

                    if chat_win_opts.col + chat_win_opts.width - 1 > vim.o.columns - 3 then
                        chat_win_opts.width = vim.o.columns - 3 - chat_win_opts.col
                    end

                    if chat_win_opts.row + chat_win_opts.height - 1 > vim.o.lines - 3 then
                        chat_win_opts.height = vim.o.lines - 3 - chat_win_opts.row
                    end
                end

                limit_chat_win()
                vim.api.nvim_win_set_config(chat_win, chat_win_opts)
                -- TODO: not let overlap chat

                ui_wins.chat = M.generate_chat_ui(chat_win_opts, {
                    top = { buf = ui_wins.chat.wins.top.buf },
                    bot = { buf = ui_wins.chat.wins.bot.buf },
                    right = { buf = ui_wins.chat.wins.right.buf },
                    left = { buf = ui_wins.chat.wins.left.buf }
                })
            end

            -- change of window position will only occur on the next tick
            vim.schedule(function() resize() end)
        end
    })
end

vim.keymap.set("n", "<Leader>b", M.open)


local function lerp(a, b, t)
    return a + (b - a) * t
end

local function generate_gradient(start_color, end_color, steps)
    local colors = {}
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        local r = math.floor(lerp(start_color.r, end_color.r, t))
        local g = math.floor(lerp(start_color.g, end_color.g, t))
        local b = math.floor(lerp(start_color.b, end_color.b, t))

        table.insert(colors, string.format("#%02x%02x%02x", r, g, b))
    end
    return colors
end


M.generate_input_ui = function(input_win_opts, used_wins)
    local ns = vim.api.nvim_create_namespace("animated_ui")

    local top_win_opts = M.generate_top_input_ui(
        input_win_opts, ns,
        used_wins and used_wins.top or nil)
    local left_win_opts = M.generate_left_input_ui(
        input_win_opts, ns,
        used_wins and used_wins.left or nil)
    local right_win_opts = M.generate_right_input_ui(
        input_win_opts, ns,
        used_wins and used_wins.right or nil)
    local bot_win_opts = M.generate_bot_input_ui(
        input_win_opts, ns,
        used_wins and used_wins.bot or nil)
    --
    --
    -- local timer = assert(vim.loop.new_timer())
    -- local i = 0
    -- timer:start(0, 1000, vim.schedule_wrap(function()
    --     if not vim.api.nvim_buf_is_valid(top_win_opts.buf)
    --         or not vim.api.nvim_buf_is_valid(bot_win_opts.buf)
    --         or not vim.api.nvim_buf_is_valid(left_win_opts.buf)
    --         or not vim.api.nvim_buf_is_valid(right_win_opts.buf) then
    --         timer:stop()
    --         timer:close()
    --         return
    --     end
    --
    --     assert(left_win_opts.height == right_win_opts.height)
    --
    --     vim.api.nvim_buf_set_lines(left_win_opts.buf,
    --         i == 0 and left_win_opts.height - 1 or i - 1,
    --         i == 0 and left_win_opts.height or i, true,
    --         { "| " })
    --     vim.api.nvim_buf_set_lines(right_win_opts.buf,
    --         i == 0 and right_win_opts.height - 1 or i - 1,
    --         i == 0 and right_win_opts.height or i, true,
    --         { " |" })
    --     vim.api.nvim_buf_set_lines(left_win_opts.buf, i, i + 1, true, { "▼ " })
    --     vim.api.nvim_buf_set_lines(right_win_opts.buf, i, i + 1, true, { " ▼" })
    --
    --
    --     i = (i == (left_win_opts.height - 1)) and 0 or i + 1
    -- end))
    --
    -- P(top_win_opts)

    return {
        wins = {
            top = top_win_opts,
            left = left_win_opts,
            right = right_win_opts,
            bot = bot_win_opts
        }
    }
end


M.generate_top_input_ui = function(input_win_opts, ns, used_win)
    local buf
    local win_opts = {}

    -- restore
    if used_win then
        -- restore
        if used_win.buf then
            buf = used_win.buf
        end
        -- restore
        if used_win.relative then
            win_opts = {
                relative = used_win.relative,
                row = used_win.row,
                col = used_win.col,
                width = used_win.width,
                height = 1,
                style = "minimal",
                zindex = 61,
                focusable = false,
            }
        end
    end

    -- create
    if not buf then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
    end


    -- create, update
    if not win_opts.relative then
        local row_min = 0               -- 0-indexed, inclusive
        local row_max = vim.o.lines - 2 -- 0-indexed, exclusive
        local col_min = 0               -- 0-indexed, inclusive
        local col_max = vim.o.columns   -- 0-indexed, exclusive

        assert(input_win_opts.row >= row_min + 1)
        assert(input_win_opts.row < row_max - 1)
        assert(input_win_opts.col >= col_min + 2)
        assert(input_win_opts.col < col_max - 2)

        win_opts = {
            relative = "editor",
            row = input_win_opts.row - 1,
            col = input_win_opts.col - 2,
            width = input_win_opts.width + 4,
            height = 1,
            style = "minimal",
            zindex = 61,
            focusable = false
        }

        if win_opts.col + win_opts.width > vim.o.columns then
            win_opts.width = win_opts.width - (win_opts.col + win_opts.width - vim.o.columns)
        end

        local title = "╣ INPUT ╠"
        local space = string.rep("═", (win_opts.width - vim.fn.strchars(title)) / 2 - 1)
        local row = space .. title .. space

        if vim.fn.strchars(row) < win_opts.width - 2 then
            row = row .. "═"
        end
        row = "╔" .. row .. "╗"

        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { row })
        vim.hl.range(buf, ns, M.input_border_hl,
            { 0, 0 },
            { 0, #row }
        )
    end

    win_opts.id = vim.api.nvim_open_win(buf, false, win_opts)
    win_opts.buf = buf
    return win_opts
end

M.generate_bot_input_ui = function(input_win_opts, ns, used_win)
    local buf
    local win_opts = {}

    -- restore
    if used_win then
        -- restore
        if used_win.buf then
            buf = used_win.buf
        end
        -- restore
        if used_win.relative then
            win_opts = {
                relative = used_win.relative,
                row = used_win.row,
                col = used_win.col,
                width = used_win.width,
                height = 1,
                style = "minimal",
                zindex = 61,
                focusable = false,
            }
        end
    end

    -- create
    if not buf then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
    end

    -- create, update
    if not win_opts.relative then
        local row_min = 1               -- 0-indexed, inclusive
        local row_max = vim.o.lines - 1 -- 0-indexed, exclusive
        local col_min = 0               -- 0-indexed, inclusive
        local col_max = vim.o.columns   -- 0-indexed, exclusive

        assert(input_win_opts.row >= row_min - 1)
        assert(input_win_opts.row < row_max)
        assert(input_win_opts.col >= col_min + 2)
        assert(input_win_opts.col < col_max - 2)

        win_opts = {
            relative = "editor",
            row = input_win_opts.row + input_win_opts.height,
            col = input_win_opts.col - 2,
            width = input_win_opts.width + 4,
            height = 1,
            style = "minimal",
            zindex = 61,
            focusable = false
        }

        local row = "╚" .. string.rep("═", win_opts.width - 2) .. "╝"

        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { row })
        vim.hl.range(buf, ns, M.input_border_hl,
            { 0, 0 },
            { 1, #row })
    end

    win_opts.id = vim.api.nvim_open_win(buf, false, win_opts)
    win_opts.buf = buf
    return win_opts
end


M.generate_left_input_ui = function(input_win_opts, ns, used_win)
    local buf
    local win_opts = {}

    -- restore
    if used_win then
        -- restore
        if used_win.buf then
            buf = used_win.buf
        end
        -- restore
        if used_win.relative then
            win_opts = {
                relative = used_win.relative,
                row = used_win.row,
                col = used_win.col,
                width = 2,
                height = used_win.height,
                style = "minimal",
                zindex = 61,
                focusable = false,
            }
        end
    end

    -- create
    if not buf then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
    end

    -- create, update
    if not win_opts.relative then
        local row_min = 1                 -- 0-indexed, inclusive
        local row_max = vim.o.lines - 2   -- 0-indexed, exclusive
        local col_min = 0                 -- 0-indexed, inclusive
        -- -1 for 0-index, -2 for right bar, -1 for buf, -1 to fit the width of 2
        local col_max = vim.o.columns - 5 -- 0-indexed, exclusive

        assert(input_win_opts.row >= row_min)
        assert(input_win_opts.row + input_win_opts.height - 1 < row_max)
        assert(input_win_opts.col - 2 >= col_min)
        assert(input_win_opts.col - 2 < col_max)

        win_opts = {
            relative = "editor",
            row = input_win_opts.row,
            col = input_win_opts.col - 2,
            width = 2,
            height = input_win_opts.height,
            style = "minimal",
            zindex = 61,
            focusable = true
        }
    end

    local row = "║ "
    local replacement = {}
    for _ = 1, win_opts.height do
        table.insert(replacement, row)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, true,
        replacement)
    vim.hl.range(buf, ns, M.input_border_hl,
        { 0, 0 },
        { win_opts.height, #row })

    win_opts.id = vim.api.nvim_open_win(buf, false, win_opts)
    win_opts.buf = buf
    return win_opts
end

M.generate_right_input_ui = function(input_win_opts, ns, used_win)
    local buf
    local win_opts = {}

    -- restore
    if used_win then
        -- restore
        if used_win.buf then
            buf = used_win.buf
        end
        -- restore
        if used_win.relative then
            win_opts = {
                relative = used_win.relative,
                row = used_win.row,
                col = used_win.col,
                width = 2,
                height = used_win.height,
                style = "minimal",
                zindex = 61,
                focusable = false,
            }
        end
    end

    -- create
    if not buf then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
    end


    -- create, update
    if not win_opts.relative then
        local row_min = 1               -- 0-indexed, inclusive
        local row_max = vim.o.lines - 2 -- 0-indexed, exclusive
        -- +2 for the left bar, +1 for buf
        local col_min = 3               -- 0-indexed, inclusive
        local col_max = vim.o.columns   -- 0-indexed, exclusive

        assert(input_win_opts.row >= row_min)
        assert(input_win_opts.row + input_win_opts.height - 1 < row_max)
        assert(input_win_opts.col + 1 >= col_min)
        assert(input_win_opts.col + 2 < col_max)

        win_opts = {
            relative = "editor",
            row = input_win_opts.row,
            col = input_win_opts.col + input_win_opts.width,
            width = 2,
            height = input_win_opts.height,
            style = "minimal",
            zindex = 61,
            focusable = false
        }

        local row = " ║"
        local replacement = {}
        for _ = 1, win_opts.height do
            table.insert(replacement, row)
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, true, replacement)
        vim.hl.range(buf, ns, M.input_border_hl, { 0, 0 }, { win_opts.height, win_opts.width })
    end

    if vim.o.lines == win_opts.row + win_opts.height then
        win_opts.height = win_opts.height - 1
    end

    win_opts.id  = vim.api.nvim_open_win(buf, false, win_opts)
    win_opts.buf = buf
    return win_opts
end

M.generate_chat_ui = function(input_win_opts, used_wins, chat_glob)
    local ns = vim.api.nvim_create_namespace("animated_ui")

    local top_win_opts = M.generate_top_chat_ui(
        input_win_opts, ns,
        used_wins and used_wins.top or nil)
    local bot_win_opts = M.generate_bot_chat_ui(
        input_win_opts, ns,
        used_wins and used_wins.bot or nil)
    local left_win_opts = M.generate_left_chat_ui(
        input_win_opts, ns,
        used_wins and used_wins.left or nil)
    local right_win_opts = M.generate_right_chat_ui(
        input_win_opts, ns,
        used_wins and used_wins.right or nil)

    -- P(top_win_opts)
    -- P(bot_win_opts)
    -- P(left_win_opts)
    -- P(right_win_opts)
    assert(top_win_opts.width == bot_win_opts.width)
    assert(top_win_opts.height == bot_win_opts.height)
    assert(left_win_opts.height == right_win_opts.height)
    assert(left_win_opts.width == right_win_opts.width)
    assert(left_win_opts.row == right_win_opts.row)
    assert(top_win_opts.col == left_win_opts.col and left_win_opts.col == bot_win_opts.col)
    assert(right_win_opts.col == top_win_opts.col + top_win_opts.width - right_win_opts.width)

    local verticies = {
        lt = {
            col = top_win_opts.col,
            row = top_win_opts.row
        },
        lb = {
            col = bot_win_opts.col,
            row = bot_win_opts.row + bot_win_opts.height - 1
        },
        rt = {
            col = right_win_opts.col + right_win_opts.width - 1,
            row = top_win_opts.row
        },
        rb = {
            col = right_win_opts.col + right_win_opts.width - 1,
            row = bot_win_opts.row + bot_win_opts.height - 1
        },
    }

    local length = top_win_opts.width * 2 + left_win_opts.height * 2
    local snake_length = math.floor(length * 0.3)
    local hls = M.get_hls(snake_length)

    local stored = chat_glob and chat_glob.get_cached() or nil
    local cur_cell = stored and stored.cur_tail or verticies.lt
    local dcol = stored and stored.dcol or 0
    local drow = stored and stored.drow or 0

    local get_cached = function()
        return { cur_tail = cur_cell, dcol = dcol, drow = drow }
    end

    local t = 1;
    local timer = assert(vim.loop.new_timer())
    timer:start(0, 250, vim.schedule_wrap(function()
        if (t > 10000
                or not vim.api.nvim_win_is_valid(top_win_opts.id)
                or not vim.api.nvim_win_is_valid(bot_win_opts.id)
                or not vim.api.nvim_win_is_valid(left_win_opts.id)
                or not vim.api.nvim_win_is_valid(right_win_opts.id))
            and not timer:is_closing()
        then
            timer:stop()
            timer:close()
            return
        end

        local first_next_cell = cur_cell
        local initial_dcol, initial_drow

        for i = 1, snake_length do
            -- step forward
            dcol, drow = M.direct(cur_cell, verticies, dcol, drow)
            local next_cell = { row = cur_cell.row + drow, col = cur_cell.col + dcol }

            if next_cell.row == top_win_opts.row and next_cell.col == top_win_opts.chat_s then
                next_cell.col = top_win_opts.chat_e
            end

            M.update(cur_cell, next_cell, i, hls,
                { top_win_opts, bot_win_opts, left_win_opts, right_win_opts }, ns)

            if i == 1 then
                first_next_cell = next_cell
                initial_dcol = dcol
                initial_drow = drow
            end

            cur_cell = next_cell
        end

        cur_cell = first_next_cell
        dcol = initial_dcol
        drow = initial_drow

        -- vim.api.nvim_buf_set_lines(left_win_opts.buf,
        --     i == 0 and left_win_opts.height - 1 or i - 1,
        --     i == 0 and left_win_opts.height or i, true,
        --     { "| " })
        -- vim.api.nvim_buf_set_lines(right_win_opts.buf,
        --     i == 0 and right_win_opts.height - 1 or i - 1,
        --     i == 0 and right_win_opts.height or i, true,
        --     { " |" })
        -- vim.api.nvim_buf_set_lines(left_win_opts.buf, i, i + 1, true, { "▼ " })
        -- vim.api.nvim_buf_set_lines(right_win_opts.buf, i, i + 1, true, { " ▼" })
        --
        -- local col_start = i % win_opts
        t = t + 1
    end))

    return {
        wins = {
            top = top_win_opts,
            left = left_win_opts,
            right = right_win_opts,
            bot = bot_win_opts,
        },
        glob = {
            get_cached = get_cached
        }
    }
end

M.get_hls = function(snake_length)
    local colors = {}
    if #vim.api.nvim_get_hl(0, { name = "Gradient1" }) == 0 then
        local gradient = generate_gradient(
            { r = 250, g = 0, b = 0 },
            { r = 0, g = 0, b = 250 },
            snake_length)

        for i, c in pairs(gradient) do
            local hl = "Gradient" .. i
            vim.api.nvim_set_hl(0, hl,
                {
                    fg = c,
                    bg = vim.api.nvim_get_hl(0, { name = M.chat_border_hl }).bg
                })
            table.insert(colors, i, hl)
        end
    else
        for i in snake_length do
            table.insert(colors, "Gradient" .. i)
        end
    end
    return colors
end

--- @return number, number column and row direction
M.direct = function(cur_cell, verticies, drow, dcol)
    if cur_cell.row == verticies.lt.row
        and cur_cell.col == verticies.lt.col then
        return 1, 0
    elseif cur_cell.row == verticies.rt.row
        and cur_cell.col == verticies.rt.col then
        return 0, 1
    elseif cur_cell.row == verticies.rb.row
        and cur_cell.col == verticies.rb.col then
        return -1, 0
    elseif cur_cell.row == verticies.lb.row
        and cur_cell.col == verticies.lb.col then
        return 0, -1
    else
        return drow, dcol
    end
end

M.update = function(cur_cell, next_cell, color_index, colors, wins, ns)
    local win
    for _, c_win in ipairs(wins) do
        local s_row = c_win.row
        local s_col = c_win.col -- only choose the outermost part of the window
        local e_row = c_win.row + c_win.height - 1
        local e_col = c_win.col + c_win.width - 1

        if c_win.type == "r" then
            s_col = s_col + c_win.width - 1
        end
        if c_win.type == "l" then
            e_col = c_win.col
        end

        local delta_col = s_col - e_col
        local delta_row = s_row - e_row

        -- vertical line, handle separately because the slope is undefined
        if delta_col == 0 then
            if next_cell.col == s_col then
                -- print("s_row", s_row, "s_col", s_col, "e_row", e_row, "e_col", e_col, "n_row", next_cell.row, "n_col",
                --     next_cell.col)
                win = c_win
                break
            end
            goto continue
        end
        local m = math.floor(delta_row / delta_col)
        local b = math.floor(s_row - m * s_col)
        if next_cell.row == m * next_cell.col + b then
            -- print("s_row", s_row, "s_col", s_col, "e_row", e_row, "e_col", e_col, "m", m, "b", b, "n_row", next_cell.row,
            --     "n_col", next_cell.col)
            win = c_win
            break
        end

        ::continue::
    end
    assert(win)

    -- remove the extmarks from all other windows
    for _, c_win in ipairs(wins) do
        vim.api.nvim_buf_del_extmark(c_win.buf, ns, color_index)
    end

    local nr = next_cell.row - win.row
    local nc_s = next_cell.col - win.col

    local nc_e = next_cell.col - win.col + 1

    if win.type == "r" then
        nc_s = next_cell.col - win.col - 1
    end

    if win.type == "l" then
        nc_e = next_cell.col - win.col + 2
    end

    -- account for different characters' byte lengths
    -- TODO: check if the line is too short
    local line = vim.api.nvim_buf_get_lines(win.buf, nr, nr + 1, true);
    local char_s = vim.str_byteindex(line[1], "utf-16", nc_s);
    local char_e = vim.str_byteindex(line[1], "utf-16", nc_e);

    vim.api.nvim_buf_set_extmark(win.buf, ns, nr, char_s,
        {
            id = color_index,
            end_row = nr,
            end_col = char_e,
            hl_group = colors[color_index]
        })
end

-- create: new buf, new win opts
-- restore: old buf, old win opts
-- update: old buf, new win opts
M.generate_top_chat_ui = function(input_win_opts, ns, used_win)
    local buf
    local win_opts = {}
    local chat_s
    local chat_e

    -- restore
    if used_win then
        -- restore
        if used_win.buf then
            buf = used_win.buf
        end
        -- restore
        if used_win.relative then
            win_opts = {
                relative = used_win.relative,
                row = used_win.row,
                col = used_win.col,
                width = used_win.width,
                height = 1,
                style = "minimal",
                zindex = 60,
                focusable = false,
            }
            chat_s = used_win.chat_s
            chat_e = used_win.chat_e
        end
    end

    -- create
    if not buf then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
    end


    -- create, update
    if not win_opts.relative then
        local row_min = 0               -- 0-indexed, inclusive
        local row_max = vim.o.lines - 2 -- 0-indexed, exclusive
        local col_min = 0               -- 0-indexed, inclusive
        local col_max = vim.o.columns   -- 0-indexed, exclusive

        assert(input_win_opts.row >= row_min + 1)
        assert(input_win_opts.row < row_max - 1)
        assert(input_win_opts.col >= col_min + 2)
        assert(input_win_opts.col < col_max - 2)

        win_opts = {
            relative = "editor",
            row = input_win_opts.row - 1,
            col = input_win_opts.col - 2,
            width = input_win_opts.width + 4,
            height = 1,
            style = "minimal",
            zindex = 60,
            focusable = false,
        }

        local title = "╣ CHAT ╠"
        local space = string.rep("═", (win_opts.width - vim.fn.strchars(title)) / 2 - 1)
        local row = space .. title .. space
        if vim.fn.strchars(row) < win_opts.width - 2 then
            row = row .. "═"
        end
        row = "╔" .. row .. "╗"

        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { row })
        vim.hl.range(buf, ns, M.chat_border_hl,
            { 0, 0 },
            { 0, #row }
        )

        chat_s = win_opts.col + vim.fn.strchars(space) + 2
        chat_e = chat_s + vim.fn.strchars(title) - 2
    end

    win_opts.id = vim.api.nvim_open_win(buf, false, win_opts)
    win_opts.chat_s = chat_s
    win_opts.chat_e = chat_e
    win_opts.buf = buf
    win_opts.type = "t"
    return win_opts
end

M.generate_bot_chat_ui = function(input_win_opts, ns, used_win)
    local buf
    local win_opts = {}

    -- restore
    if used_win then
        -- restore
        if used_win.buf then
            buf = used_win.buf
        end
        -- restore
        if used_win.relative then
            win_opts = {
                relative = used_win.relative,
                row = used_win.row,
                col = used_win.col,
                width = used_win.width,
                height = 1,
                style = "minimal",
                zindex = 61,
                focusable = false,
            }
        end
    end

    -- create
    if not buf then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
    end


    -- create, update
    if not win_opts.relative then
        local row_min = 1               -- 0-indexed, inclusive
        local row_max = vim.o.lines - 1 -- 0-indexed, exclusive
        local col_min = 0               -- 0-indexed, inclusive
        local col_max = vim.o.columns   -- 0-indexed, exclusive

        assert(input_win_opts.row >= row_min - 1)
        assert(input_win_opts.row < row_max)
        assert(input_win_opts.col >= col_min + 2)
        assert(input_win_opts.col < col_max - 2)


        win_opts = {
            relative = "editor",
            row = input_win_opts.row + input_win_opts.height,
            col = input_win_opts.col - 2,
            width = input_win_opts.width + 4,
            height = 1,
            style = "minimal",
            zindex = 60,
            focusable = false,
        }
    end

    local row = "╚" .. string.rep("═", win_opts.width - 2) .. "╝"

    vim.api.nvim_buf_set_lines(buf, 0, -1, true,
        { row })
    vim.hl.range(buf, ns, M.chat_border_hl,
        { 0, 0 },
        { 1, #row })

    win_opts.id = vim.api.nvim_open_win(buf, false, win_opts)
    win_opts.buf = buf
    win_opts.type = "b"
    return win_opts
end


M.generate_left_chat_ui = function(input_win_opts, ns, used_win)
    local buf
    local win_opts = {}

    -- restore
    if used_win then
        -- restore
        if used_win.buf then
            buf = used_win.buf
        end
        -- restore
        if used_win.relative then
            win_opts = {
                relative = used_win.relative,
                row = used_win.row,
                col = used_win.col,
                width = 2,
                height = used_win.height,
                style = "minimal",
                zindex = 61,
                focusable = false,
            }
        end
    end

    -- create
    if not buf then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
    end

    -- create, update
    if not win_opts.relative then
        local row_min = 1                 -- 0-indexed, inclusive
        local row_max = vim.o.lines - 2   -- 0-indexed, exclusive
        local col_min = 0                 -- 0-indexed, inclusive
        -- -1 for 0-index, -2 for right bar, -1 for buf, -1 to fit the width of 2
        local col_max = vim.o.columns - 5 -- 0-indexed, exclusive

        assert(input_win_opts.row >= row_min)
        assert(input_win_opts.row + input_win_opts.height - 1 < row_max)
        assert(input_win_opts.col - 2 >= col_min)
        assert(input_win_opts.col - 2 < col_max)

        win_opts = {
            relative = "editor",
            row = input_win_opts.row,
            col = input_win_opts.col - 2,
            width = 2,
            height = input_win_opts.height,
            style = "minimal",
            zindex = 60,
            focusable = false,
        }
    end

    local row = "║ "
    local replacement = {}
    for _ = 1, win_opts.height do
        table.insert(replacement, row)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, true,
        replacement)
    vim.hl.range(buf, ns, M.chat_border_hl,
        { 0, 0 },
        { win_opts.height, #row })

    win_opts.id = vim.api.nvim_open_win(buf, false, win_opts)
    win_opts.buf = buf
    win_opts.type = "l"
    return win_opts
end

M.generate_right_chat_ui = function(input_win_opts, ns, used_win)
    local buf
    local win_opts = {}

    -- restore
    if used_win then
        -- restore
        if used_win.buf then
            buf = used_win.buf
        end
        -- restore
        if used_win.relative then
            win_opts = {
                relative = used_win.relative,
                row = used_win.row,
                col = used_win.col,
                width = 2,
                height = used_win.height,
                style = "minimal",
                zindex = 61,
                focusable = false,
            }
        end
    end

    -- create
    if not buf then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
    end


    -- create, update
    if not win_opts.relative then
        local row_min = 1               -- 0-indexed, inclusive
        local row_max = vim.o.lines - 2 -- 0-indexed, exclusive
        -- +2 for the left bar, +1 for buf
        local col_min = 3               -- 0-indexed, inclusive
        local col_max = vim.o.columns   -- 0-indexed, exclusive

        assert(input_win_opts.row >= row_min)
        assert(input_win_opts.row + input_win_opts.height - 1 < row_max)
        assert(input_win_opts.col + 1 >= col_min)
        assert(input_win_opts.col + 2 < col_max)

        win_opts = {
            relative = "editor",
            row = input_win_opts.row,
            col = input_win_opts.col + input_win_opts.width,
            width = 2,
            height = input_win_opts.height,
            style = "minimal",
            zindex = 60,
            focusable = false,
        }
    end

    local row = " ║"
    local replacement = {}
    for i = 1, win_opts.height do
        table.insert(replacement, i, row)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, true, replacement)
    vim.hl.range(buf, ns, M.chat_border_hl,
        { 0, 0 },
        { win_opts.height, #row })

    win_opts.id   = vim.api.nvim_open_win(buf, false, win_opts)
    win_opts.buf  = buf
    win_opts.type = "r"
    return win_opts
end
