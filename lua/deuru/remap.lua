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

vim.keymap.set("n", "<M-h>", ":vertical resize -5<cr>")
vim.keymap.set("n", "<M-l>", ":vertical resize +5<cr>")

vim.keymap.set("n", "<M-j>", ":resize +5<cr>")
vim.keymap.set("n", "<M-k>", ":resize -5<cr>")

vim.keymap.set("n", "[b", "<cmd>bprevious<CR>")
vim.keymap.set("n", "]b", "<cmd>bnext<CR>")
vim.keymap.set("n", "[B", "<cmd>bfirst<CR>")
vim.keymap.set("n", "]B", "<cmd>blast<CR>")

vim.keymap.set("n", "<C-n>", "<cmd>messages<cr>", { desc = "Run :messages" })
vim.keymap.set("n", "<C-l>", "<cmd>nohlsearch<CR>", { desc = "Run :noh" })

vim.keymap.set("n", "<leader>esc", "<cmd>set spell spelllang=en_us<CR>",
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

-- Vim Like Cmd Navigation
vim.keymap.set({ "c", "t" }, "<A-h>", "<Left>")
vim.keymap.set({ "c", "t" }, "<A-l>", "<Right>")
vim.keymap.set({ "c", "t" }, "<A-j>", "<Down>")
vim.keymap.set({ "c", "t" }, "<A-k>", "<Up>")
vim.keymap.set({ "c", "t" }, "<A-w>", "<C-Right>")
vim.keymap.set({ "c", "t" }, "<A-b>", "<C-Left>")

vim.keymap.set("n", "/", "/\\v")

vim.keymap.set({ 'n' }, '<Esc>', function()
    local buffer = vim.fn.win_getid()

    if vim.api.nvim_win_is_valid(buffer) and
        vim.api.nvim_win_get_config(buffer).relative ~= '' then
        vim.api.nvim_win_close(buffer, false)
    end
end, { desc = "Close floating window" })


-- yunk current dir path
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
