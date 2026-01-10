local M = {}
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- vim.keymap.set("n", "<leader>vwm", function()
--     require("vim-with-me").StartVimWithMe()
-- end)
-- vim.keymap.set("n", "<leader>svwm", function()
--     require("vim-with-me").StopVimWithMe()
-- end)
-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("x", "<Esc>", [["_dP]])

-- next greatest remap ever : asbjornHaland
-- vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- vim.keymap.set("n", "<leader>Y", [["+Y]])

-- vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- vim.keymap.set("n", "<l<ader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)



vim.keymap.set("n", "<M-h>h", function()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.col = math.max(win_pos[2] - 5, 0)

    vim.api.nvim_win_set_config(win, win_config)
    vim.api.nvim_exec_autocmds("WinResized", {
        buffer = vim.api.nvim_win_get_buf(win)
    })
end, { desc = "Move Win Left" })
vim.keymap.set("n", "<M-l>l", function()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.col = math.max(win_pos[2] + 5, 0)

    vim.api.nvim_win_set_config(win, win_config)
    vim.api.nvim_exec_autocmds("WinResized", {
        buffer = vim.api.nvim_win_get_buf(win)
    })
end, { desc = "Move Win Right" })
vim.keymap.set("n", "<M-k>k", function()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.row = math.max(win_pos[1] - 2, 0)

    vim.api.nvim_win_set_config(win, win_config)
    vim.api.nvim_exec_autocmds("WinResized", {
        buffer = vim.api.nvim_win_get_buf(win)
    })
end, { desc = "Move Win Up" })
vim.keymap.set("n", "<M-j>j", function()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.row = win_pos[1] + 2

    vim.api.nvim_win_set_config(win, win_config)
    vim.api.nvim_exec_autocmds("WinResized", {
        buffer = vim.api.nvim_win_get_buf(win)
    })
end, { desc = "Move Win Down" })

vim.keymap.set("n", "<M-h><M-h>", function()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_config = vim.api.nvim_win_get_config(win)

    if win_config.relative ~= "" then
        win_config.col = math.max(win_pos[2] - 5, 0)
        win_config.width = win_config.width + 5
        vim.api.nvim_win_set_config(win, win_config)
    else
        M.shift_other_win(win, win_pos, win_config, "left")
    end
end, { desc = "Expand Left" })

vim.keymap.set("n", "<M-h><M-l>", function()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.col = math.max(win_pos[2] + 5, 0)
    win_config.width = math.max(win_config.width - 5, 1)
    vim.api.nvim_win_set_config(win, win_config)
end)

vim.keymap.set("n", "<M-l><M-l>", function()
    local win = vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.width = win_config.width + 5
    vim.api.nvim_win_set_config(win, win_config)
end, { desc = "Expand Right" })

vim.keymap.set("n", "<M-l><M-h>>", function()
    local win = vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.width = math.max(win_config.width - 5, 1)
    vim.api.nvim_win_set_config(win, win_config)
end)

vim.keymap.set("n", "<M-k><M-k>", function()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_config = vim.api.nvim_win_get_config(win)

    if win_config.relative ~= "" then
        win_config.row = math.max(win_pos[1] - 2, 0)
        win_config.height = win_config.height + 2
        vim.api.nvim_win_set_config(win, win_config)
    else
        M.shift_other_win(win, win_pos, win_config, "above")
    end
end, { desc = "Expand up" })
vim.keymap.set("n", "<M-k><M-j>", function()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.row = math.max(win_pos[1] + 2, 0)
    win_config.height = math.max(win_config.height - 2, 1)
    vim.api.nvim_win_set_config(win, win_config)
end)

vim.keymap.set("n", "<M-j><M-j>", function()
    local win = vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.height = win_config.height + 2
    vim.api.nvim_win_set_config(win, win_config)
end, { desc = "Expand dowwn" })

vim.keymap.set("n", "<M-j><M-k>", function()
    local win = vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(win)
    win_config.height = math.max(win_config.height - 2, 1)
    vim.api.nvim_win_set_config(win, win_config)
end)

vim.keymap.set("n", "[b", "<cmd>bprevious<CR>")
vim.keymap.set("n", "]b", "<cmd>bnext<CR>")
vim.keymap.set("n", "[B", "<cmd>bfirst<CR>")
vim.keymap.set("n", "]B", "<cmd>blast<CR>")

vim.keymap.set("n", "<C-n>", "<cmd>messages<cr>", { desc = "Run :messages" })
vim.keymap.set("n", "<C-l>", "<cmd>nohlsearch<CR>", { desc = "Run :noh" })

vim.keymap.set("n", "<leader>esc", "<cmd>set spell<CR>",
    { desc = "[E]nable [S]yntax [C]heck" });
vim.keymap.set("n", "<leader>dsc", "<cmd>set nospell<CR>",
    { desc = "[D]isable [S]yntax [C]heck" });

vim.keymap.set('t', '<Esc>', "<C-\\><C-n>", { desc = "Exit terminal" })
vim.keymap.set('t', '<C-[>', "<C-\\><C-n>", { desc = "Exit terminal" })

vim.keymap.set("n", "<leader>tc",
    ":split<CR>" ..
    ":let $VIM_DIR=expand('%:h')<CR>" ..
    ":terminal<CR>icd $VIM_DIR<CR><C-L><C-\\><C-n>",
    { desc = "Open Terminal window at a current directory" });
vim.keymap.set("n", "<leader>tr", ":split<CR>:terminal<CR>",
    { desc = "Open Terminal window at the root directory" });

-- Vim Like Navigation in the Insert, Terminal and Cmd modes
vim.keymap.set({ "i", "t", "c" }, "<C-g>h", "<Left>")
vim.keymap.set({ "i", "t", "c" }, "<C-g>l", "<Right>")
vim.keymap.set({ "t", "c" }, "<C-g>k", "<Up>")
vim.keymap.set({ "t", "c" }, "<C-g>j", "<Down>")
vim.keymap.set({ "i", "t", "c" }, "<C-g>b", "<C-Left>")
vim.keymap.set({ "i", "t", "c" }, "<C-g>w", "<C-Right>")
vim.keymap.set({ "i", "t", "c" }, "<C-x>i", "<C-Right>")

vim.keymap.set("n", "/", "/\\v")

vim.keymap.set({ 'n' }, '<Esc>', function()
    local buffer = vim.fn.win_getid()

    if vim.api.nvim_win_is_valid(buffer) and
        vim.api.nvim_win_get_config(buffer).relative ~= '' then
        vim.api.nvim_win_hide(buffer)
    end
end, { desc = "Close floating window" })
vim.keymap.set({ 'v' }, '<Esc>', "<C-c>", { desc = "Quit visual mode" })

-- yank current dir path
vim.api.nvim_create_user_command("Cppath", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

vim.cmd("cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'")

P = function(v)
    print(vim.inspect(v))
    return v
end




M.is_in_area = function(win_config, target_win, direction)
    local win_row = win_config.row
    local win_col = win_config.col

    if direction == "above" then
        win_row = win_row - 2
    elseif direction == "left" then
        win_col = win_col - 2
    end
    return target_win.row <= win_row

        and win_row < target_win.row + target_win.height
        and target_win.col <= win_col
        and win_col < target_win.col + target_win.width
end

M.shift_other_win = function(win, win_pos, win_config, direction)
    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, other_win in pairs(wins) do
        if other_win == win then
            goto continue
        end

        local other_win_config = vim.api.nvim_win_get_config(other_win)
        local other_win_pos = vim.api.nvim_win_get_position(other_win)

        if M.is_in_area({
                    row = win_pos[1],
                    col = win_pos[2],
                    height = win_config.height,
                    width = win_config.width },
                {
                    row = other_win_pos[1],
                    col = other_win_pos[2],
                    height = other_win_config.height,
                    width = other_win_config.width,
                }, direction) then
            if direction == "left" then
                other_win_config.width = math.max(other_win_config.width - 5, 1)
            elseif direction == "above" then
                other_win_config.height = math.max(other_win_config.height - 5, 1)
            end
        end
        vim.api.nvim_win_set_config(other_win, other_win_config)

        ::continue::
    end
end
