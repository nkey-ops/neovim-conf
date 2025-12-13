vim.opt.sessionoptions = 'curdir,folds,globals,help,tabpages,terminal,winsize'
vim.o.showtabline = 2

local is_tab_name_present = false
local function get_rgb(hl, is_fg)
    assert(hl ~= nil)
    assert(type(hl) == 'string')
    assert(is_fg ~= nil)
    assert(type(is_fg) == 'boolean')

    local id = is_fg and "fg#" or "bg#"
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), id)
end

local function tab_name(tab)
    local line = string.gsub(tab.name(), "%[..%]", "")
    return line
end

local function tab_mark(tab)
    local mark_key = vim.t[tab.id]["extended_marks_tab_mark_key"]
    return mark_key and ' ' .. string.format('[%s]', mark_key) or ''
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

    local result
    if tab_status == 'severe' then
        result = {
            is_modifed and "" or "",
            hl = { fg = get_rgb("DiagnosticSignError", true) }
        }
    elseif tab_status == 'warn' then
        result = {
            is_modifed and "" or "⚠",
            hl = { fg = get_rgb("DiagnosticSignWarn", true) }
        }
    elseif tab_status == 'info' then
        result = {
            is_modifed and "🔍" or "🔍",
            hl = { fg = get_rgb("DiagnosticSignInfo", true) }
        }
    else
        result = {
            is_modifed and "" or "",
            hl = {}
        }
    end

    result[1] = ' ' .. result[1] .. ' '
    return result
end

local theme = {
    fill = 'TabLineFill',
    -- Also you can do this: fill = { fg = '#f2e9de', bg = '#907aa9', style = 'italic' },
    current_tab = 'TabLineSel',
    inactive_tab = 'TabLine',
    tail = 'TabLineFill',
}


require('tabby').setup({
    option = {
        lualine_theme = "auto",
        buf_name = { mode = "tail" }

    },

    line   = function(line)
        local current_tab_number = vim.api.nvim_tabpage_get_number(vim.api.nvim_get_current_tabpage())
        local is_mark_tab_present = false
        return {
            {
                { '  ', hl = theme.current_tab },
                line.sep(vim.api.nvim_get_current_tabpage() == 1 and '' or '', theme.current_tab, theme.tail),

            },
            line.tabs().foreach(function(tab)
                local hl = tab.is_current() and theme.current_tab or theme.inactive_tab
                local tab_sign = tab_modified_and_lsp(tab.id)
                if tab_sign.hl.fg == nil then
                    tab_sign.hl.fg = get_rgb(hl, true)
                end
                tab_sign.hl.bg = get_rgb(hl, false)

                local start_sign = tab.is_current() and '' or ''
                local end_sign = tab.number() - current_tab_number == -1 and '' or ''

                return {
                    line.sep(start_sign, hl, theme.tail),
                    is_tab_name_present and ' ' .. tab_name(tab) or '',
                    tab_mark(tab),
                    tab_sign,
                    line.sep(end_sign, hl, theme.tail),
                    -- margin = ' ',
                    hl = hl,
                }
            end),
            line.sep('%=s', theme.tail, theme.tail),
            (function()
                if not vim.b[0].extended_marks_cwd_mark_key
                    and not vim.b[0].extended_marks_cwd_mark_key then
                    return ""
                end

                return {
                    line.sep('', theme.current_tab, theme.tail),
                    {
                        (function()
                            local is_mark_present = false
                            local cwd_mark = vim.b[0].extended_marks_cwd_mark_key
                            cwd_mark = cwd_mark and "[c:" .. cwd_mark .. "]" or ""
                            if cwd_mark then
                                is_mark_present = true
                            end

                            local global_mark = vim.b[0].extended_marks_global_mark_key
                            global_mark = global_mark and "[g:" .. global_mark .. "]" or ""
                            if global_mark then
                                is_mark_present = true
                            end

                            is_mark_tab_present = is_mark_present
                            return string.format(" %s%s ", cwd_mark, global_mark)
                        end)(),
                        hl = theme.current_tab
                    },
                    line.sep('', theme.current_tab, theme.tail),
                }
            end)(),
            {
                line.sep(is_mark_tab_present and '' or '', theme.current_tab, theme.tail),
                {
                    string.format(" [%s] ", vim.fn.fnamemodify(vim.fn.getcwd(), ':t')),
                    hl = theme.current_tab
                },
            }
        }
    end,
})


vim.api.nvim_create_user_command("ToggleTabNames", function()
    is_tab_name_present = not is_tab_name_present
end, {})

vim.api.nvim_set_keymap("n", "<leader>ta", ":$tabnew<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>to", ":tabonly<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tn", ":tabn<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tp", ":tabp<CR>", { noremap = true })
-- move current tab to previous position
vim.api.nvim_set_keymap("n", "<leader>tmp", ":-tabmove<CR>", { noremap = true })
-- move current tab to next position
vim.api.nvim_set_keymap("n", "<leader>tmn", ":+tabmove<CR>", { noremap = true })
