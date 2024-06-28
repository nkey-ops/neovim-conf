vim.opt.sessionoptions = 'curdir,folds,globals,help,tabpages,terminal,winsize'
vim.o.showtabline = 2

local function tab_name(tab)
    local line = string.gsub(tab.name(), "%[..%]", "")
    if tab.is_current() then
        line = vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. "|" .. line
    end
    return line
end
local function tab_modified(tab)
    wins = require("tabby.module.api").get_tab_wins(tab)
    for i, x in pairs(wins) do
        if vim.bo[vim.api.nvim_win_get_buf(x)].modified then
            return ""
        end
    end
    return ""
end

local function lsp_diag(buf)
    diagnostics = vim.diagnostic.get(buf)
    local count = { 0, 0, 0, 0 }

    for _, diagnostic in ipairs(diagnostics) do
        count[diagnostic.severity] = count[diagnostic.severity] + 1
    end
    if count[1] > 0 then
        return vim.bo[buf].modified and "" or ""
    elseif count[2] > 0 then
        return vim.bo[buf].modified and "" or ""
    end
    return vim.bo[buf].modified and "" or ""
end

local function get_modified(buf)
    if vim.bo[buf].modified then
        return ''
    else
        return ''
    end
end

local function buffer_name(buf)
    if string.find(buf, "NvimTree") then
        return "NvimTree"
    end
    return buf
end

local theme = {
    fill = 'TabLineFill',
    -- Also you can do this: fill = { fg = '#f2e9de', bg = '#907aa9', style = 'italic' },
    head = 'TabLine',
    current_tab = 'TabLineSel',
    tab = 'TabLine',
    win = 'TabLine',
    tail = 'TabLine',
}

require('tabby').setup({
    line = function(line)
        return {
            {
                { '  ', hl = theme.head },
                line.sep('', theme.head, theme.fill),
            },
            line.tabs().foreach(function(tab)
                local hl = tab.is_current() and theme.current_tab or theme.tab
                return {
                    line.sep('', hl, theme.fill),
                    tab.number(),
                    "",
                    tab_name(tab),
                    "",
                    tab_modified(tab.id),
                    line.sep('', hl, theme.fill),
                    hl = hl,
                    margin = ' ',
                }
            end),
            hl = theme.fill,
        }
    end,
})
