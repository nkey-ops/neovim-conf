vim.opt.sessionoptions = 'curdir,folds,globals,help,tabpages,terminal,winsize'
vim.o.showtabline = 2

local function tab_name(tab)
    local line = string.gsub(tab.name(), "%[..%]", "")

    if tab.is_current() then
        line = string.format('[%s] %s', vim.fn.fnamemodify(vim.fn.getcwd(), ':t'), line)
    end
    return line
end

local function tab_mark(tab)
    local mark_key = vim.t[tab.id]["mark_key"]
    return mark_key and string.format('[%s]', mark_key) or ''
end

local function lsp_diag(buf)
    local diagnostics = vim.diagnostic.get(buf)
    local count = { 0, 0, 0, 0 }

    for _, diagnostic in ipairs(diagnostics) do
        count[diagnostic.severity] = count[diagnostic.severity] + 1
    end
    if count[1] > 0 then
        return 'severe'
    elseif count[2] > 0 then
        return 'warn'
    elseif count[4] > 0 then
        return 'info'
    end
    return 'modified'
end

local function tab_modified_and_lsp(tab)
    local wins = require("tabby.module.api").get_tab_wins(tab)

    local tab_status = 'normal'
    local is_modifed = false

    for _, win in pairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_status = lsp_diag(buf)


        if buf_status == 'severe' then
            tab_status = 'severe'
            is_modifed = vim.bo[buf].modified
        elseif buf_status == 'warn' and tab_status ~= 'severe' then
            tab_status = 'warn'
            is_modifed = vim.bo[buf].modified
        elseif buf_status == 'info' and tab_status ~= 'severe' and tab_status ~= 'warn' then
            tab_status = 'info'
            is_modifed = vim.bo[buf].modified
        elseif tab_status == 'normal' and vim.bo[buf].modified then
            is_modifed = vim.bo[buf].modified
        end
    end

    if tab_status == 'severe' then
        return is_modifed and "" or ""
    elseif tab_status == 'warn' then
        return is_modifed and "" or "⚠"
    elseif tab_status == 'info' then
        return is_modifed and "🅘" or "ⓘ"
    else
        return is_modifed and "" or ""
    end
end

local theme = {
    fill = 'TabLineFill',
    -- Also you can do this: fill = { fg = '#f2e9de', bg = '#907aa9', style = 'italic' },
    head = 'Folded',
    current_tab = 'TabLineSel',
    tab = 'TabLine',
    win = 'TabLine',
    tail = 'Normal',
    cus = { fg = '#f2e9de', bg = '#907aa9', style = 'italic' },
}

require('tabby').setup({
    option = {
        lualine_theme = "auto",
        buf_name = { mode = "tail" }
    },

    line   = function(line)
        return {
            {
                { '  ', hl = theme.head },
                line.sep('', theme.head, theme.tail),

            },
            line.tabs().foreach(function(tab)
                local hl = tab.is_current() and theme.current_tab or theme.tab
                return {
                    line.sep('', hl, theme.tail),
                    tab_name(tab),
                    tab_mark(tab),
                    tab_modified_and_lsp(tab.id),
                    line.sep('', hl, theme.tail),
                    hl = hl,
                    margin = ' ',
                }
            end),
            hl = theme.fill,
        }
    end,
})

vim.api.nvim_set_keymap("n", "<leader>ta", ":$tabnew<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>to", ":tabonly<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tn", ":tabn<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tp", ":tabp<CR>", { noremap = true })
-- move current tab to previous position
vim.api.nvim_set_keymap("n", "<leader>tmp", ":-tabmove<CR>", { noremap = true })
-- move current tab to next position
vim.api.nvim_set_keymap("n", "<leader>tmn", ":+tabmove<CR>", { noremap = true })
