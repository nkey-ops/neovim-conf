return function()
    vim.opt.pumheight = 10

    local cmp = require('cmp')
    local lspkind = require('lspkind')
    local luasnip = require('luasnip')


    require('luasnip.loaders.from_vscode').lazy_load()

    -- If you want insert `(` after select function or method item
    cmp.event:on(
        'confirm_done',
        require('nvim-autopairs.completion.cmp').on_confirm_done()
    )

    cmp.setup({
        snippet = {
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

        view = {
            entries = { name = 'custom', selection_ordre = 'near_cursor' },
            docs = { auto_open = true }
        },
        completion = {
            autocomplete = false
        },

        sorting = {
            comparators = {
                -- using comparator that selects an item with the shortest length
                function(e1, e2)
                    local label1 = e1.completion_item.label
                    local label2 = e2.completion_item.label

                    local ls1 = label1:find('%(')
                    local ls2 = label2:find('%(')

                    if ls1 then
                        label1 = label1:sub(0, ls1)
                    end
                    if ls2 then
                        label2 = label2:sub(0, ls2)
                    end

                    return label1:len() < label2:len()
                end
            }
        },

        preselect = cmp.PreselectMode.Item,

        formatting = {
            format =
                function(entry, vim_item)
                    local lspkind_format = lspkind.cmp_format({ mode = 'symbol_text', maxwidth = 50 })

                    vim_item = lspkind_format(entry, vim_item)

                    local name = vim.fn.strcharpart(entry.source.name, 0, 4)
                    vim_item.menu = string.format("[%s]", name)
                    vim_item.kind = vim.fn.strcharpart(vim_item.kind, 0, 5)

                    return vim_item
                end
        },

        mapping = cmp.mapping.preset.insert({
            ['<A-y>'] = cmp.mapping.scroll_docs(-1),
            ['<A-e>'] = cmp.mapping.scroll_docs(1),
            ['<A-u>'] = cmp.mapping.scroll_docs(-4),
            ['<A-d>'] = cmp.mapping.scroll_docs(4),

            ['<C-[>'] = cmp.mapping.close(),

            ['<A-p>'] =
                function()
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                    else
                        cmp.complete()
                    end
                end,
            ['<A-o>'] = function()
                cmp.complete({ performance = { max_view_entries = 1 } })
                cmp.confirm({ select = true })
            end,
            ['<A-n>'] =
                function()
                    -- cmp.select_next_item({ behaviour = cmp.ConfirmBehavior.Replace })
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                    else
                        cmp.complete({ select = true })
                    end
                end,
            ['<A-i>'] = function()
                cmp.confirm({ select = true })
            end,
            -- luasnip mapping
            ['<A-l>'] = function()
                luasnip.expand_or_jump()
            end,
            ['<A-h>'] = function()
                luasnip.jump(-1)
            end
        }),
        sources = cmp.config.sources({
            { name = 'path' },
            { name = 'nvim_lsp', group_index = 2, keword_lengt = 1 },
            { name = 'luasnip',  group_index = 1, keword_lengt = 1 }, -- For luasnip users.
            -- { name = 'vsnip',    keyword_length = 1 }, -- For vsnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
        }
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
