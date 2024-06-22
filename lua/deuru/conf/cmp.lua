return function()
    vim.opt.pumheight = 10
    local format_opts = {
        ellipsis_char = '…',
        max_label_width = 20,
        min_label_width = 20
    }

    local function set_window_width(vim_item, opts)
        assert(vim_item ~= nil and opts ~= nil and
            opts.ellipsis_char ~= nil and
            opts.max_label_width ~= nil and
            opts.min_label_width ~= nil)

        local label = vim_item.abbr
        local truncated_label = vim.fn.strcharpart(label, 0, opts.max_label_width)

        if truncated_label ~= label then
            vim_item.abbr = truncated_label .. opts.ellipsis_char
        elseif string.len(label) < opts.min_label_width then
            local padding = string.rep(' ', opts.min_label_width - string.len(label))
            vim_item.abbr = label .. padding
        end
        -- vim_item.menu = ''
        vim_item.info = ''
        return vim_item
    end

    local lsp_zero = require('lsp-zero')
    local cmp = require('cmp')
    local cmp_action = lsp_zero.cmp_action()
    local lspkind = require('lspkind')

    lsp_zero.extend_cmp({ use_luasnip = true })

    require('luasnip.loaders.from_vscode').lazy_load()

    -- If you want insert `(` after select function or method item
    cmp.event:on(
        'confirm_done',
        require('nvim-autopairs.completion.cmp').on_confirm_done()
    )


    cmp.setup({
        snippet = {
            -- REQUIRED - you must specify a snippet engin
            expand = function(args)
                -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            end,
        },

        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },

        performance = {},
        view = { entries = { name = 'custom', selection_ordre = 'near_cursor' } },
        preselect = cmp.PreselectMode.Item,

        formatting = {
            format =
                function(entry, vim_item)
                    local lspkind_format = lspkind.cmp_format({ mode = 'symbol' })
                    local lsp_zero_formatting = lsp_zero.cmp_format({ details = true })

                    vim_item = lspkind_format(entry, vim_item)
                    vim_item = lsp_zero_formatting.format(entry, vim_item)
                    return set_window_width(vim_item, format_opts)
                end
        },
        -- lsp_zero.cmp_format({ details = true, max_width = 40 }),
        mapping = cmp.mapping.preset.insert({
            ['<C-y>'] = cmp.mapping.scroll_docs(-1),
            ['<C-e>'] = cmp.mapping.scroll_docs(1),
            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ['<C-[>'] = cmp.mapping.abort(),
            ['<C-p>'] =
                function()
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        cmp.complete()
                    end
                end,

            ['<C-n>'] =
                function()
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        cmp.complete()
                    end
                end,
            -- ['<C-c>'] = cmp.mapping.complete_common_string(),
            ['<C-i>'] = cmp.mapping.confirm({ select = true }),
            ['<CR>'] = vim.NIL,
            ['<Tab>'] = vim.NIL,
            -- luasnip mapping
            ['<C-f>'] = cmp_action.luasnip_jump_forward(),
            ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }),
        sources = cmp.config.sources({
            { name = 'path' },
            { name = 'nvim_lsp', group_index = 2 },
            { name = 'luasnip',  group_index = 1 }, -- For luasnip users.
            -- { name = 'vsnip',    keyword_length = 1 }, -- For vsnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
        }
        -- { name = 'buffer' }
        ),
    })

    -- Set configuration for specific filetype.
    cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
            { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
        }, {
            { name = 'buffer' },
        })
    })

    local cmdline_mapping = cmp.mapping.preset.cmdline({
        ['<C-y>'] = {
            c = function()
                cmp.confirm({ select = true })
                vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes("<CR>", true, false, true),
                    'm', false)
            end
        },
        ['<C-[>'] = { c = cmp.mapping.abort() },
        ['<C-p>'] = {
            c = function()
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    cmp.complete()
                end
            end
        },
        ['<C-n>'] = { c = cmp.mapping.select_next_item() },
        ['<C-i>'] = {
            c =
                function()
                    cmp.confirm({ select = true })
                    cmp.close()
                    vim.api.nvim_feedkeys(
                        vim.api.nvim_replace_termcodes("<Space>", true, false, true),
                        'm', false)
                    cmp.complete()
                end
        },
        ['<Tab>'] = { c = vim.NIL },
    })


    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmdline_mapping,
        sources = {
            { name = 'buffer' }
        }
    })
    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        mapping = cmdline_mapping,
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })
end
