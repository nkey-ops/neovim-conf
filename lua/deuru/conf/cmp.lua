return function()
    vim.opt.pumheight = 10

    local cmp = require('cmp')
    local lspkind = require('lspkind')
    local luasnip = require('luasnip')

    require('luasnip.loaders.from_vscode').lazy_load()

    -- If you want insert `(` after select function or method item

    -- if require("nvim-autopairs") then
    --     cmp.event:on(
    --         'confirm_done',
    --         require('nvim-autopairs.completion.cmp').on_confirm_done()
    --     )
    -- end

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

        confirmation = {
            get_commit_characters = function(commit_characters)
                return { "(", ")" }
            end
        },
        matching = {
            -- disallow_fuzzy_matching = true,
            -- disallow_partial_fuzzy_matching = true,
            disallow_partial_matching = false, --
            disallow_prefix_unmatching = true, --
            disallow_symbol_nonprefix_matching = true,
        },
        sorting = {
            -- 1 Fuzzy matching with dismissal of items with an incorrect case matche,
            -- 2 The shorter length the higher rate
            -- 3 Functions have the lowest rate out of other kinds
            -- 4 Snake case bad
            -- 5 Recently used
            -- 6 Kind -- snippets should be last
            -- 7 Scopes
            --
            -- 8 The same methods with lowest number of arguments have higher rate
            -- 9 Deprecated items have the lowest rate
            --
            -- {
            -- cmp.config.compare.offset,
            -- cmp.config.compare.exact,
            -- -- compare.scopes,
            -- compare.score,
            -- compare.recently_used,
            -- compare.locality,
            -- compare.kind,
            -- compare.sort_text,
            -- compare.length,
            -- compare.order,
            -- }
            --
            -- https://github.com/eclipse-lsp4j/lsp4j/blob/main/org.eclipse.lsp4j/src/main/java/org/eclipse/lsp4j/CompletionItemKind.java
            -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionItem

            comparators = {
                -- match_score > length > vars > methods
                function(e1, e2)
                    local comps = {
                        -- [1]
                        function(o1, o2) -- the higher the better
                            local diff = o1.score - o2.score
                            if diff == 0 then return nil end
                            return diff > 0
                        end,
                        -- [2]
                        function(o1, o2) -- length name sorting | the shorter the better
                            -- [9] deprecated items have the lowest rate
                            if o1.completion_item.tags
                                and o1.completion_item.tags[1] == 1 then
                                return false
                            end

                            if o2.completion_item.tags
                                and o2.completion_item.tags[1] == 1 then
                                return false
                            end

                            -- when snippet doesn't have an insert_text
                            local t1 = o1.completion_item.insertText and o1.completion_item.insertText or
                                o1.filter_text
                            local t2 = o2.completion_item.insertText and o2.completion_item.insertText or
                                o2.filter_text

                            local diff = #t1 - #t2
                            if diff == 0 then
                                -- if the kind is the same of a completion item
                                if o1.completion_item.kind == o2.completion_item.kind then
                                    -- [8] if both completion items are functions lets pick the one
                                    --     with the least function arguments
                                    if o1.completion_item.kind == 2 then
                                        local _, o1_arg_count = o1.completion_item.filterText:gsub('${', '')
                                        local _, o2_arg_count = o2.completion_item.filterText:gsub('${', '')

                                        local arg_diff = o1_arg_count - o2_arg_count
                                        return arg_diff < 0
                                    end
                                    if diff == 0 then return nil end
                                    return diff < 0
                                end

                                -- [3] if one is a function, lower it rate
                                if o1.completion_item.kind == 2 then
                                    return false
                                elseif o2.completion_item.kind == 2 then
                                    return true
                                else
                                    return nil
                                end
                            end
                            return diff < 0
                        end,
                        -- [5]
                        -- cmp.config.compare.recently_used
                    }

                    local score = 0
                    for i, comp in pairs(comps) do
                        --- @type boolean?
                        local diff = comp(e1, e2)
                        if diff ~= nil then
                            score = score + (diff and 1 + (#comps - i) or -1)
                        end
                    end

                    if score == 0 then return nil end
                    return score > 0
                end
            },
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
            -- ['<A-y>'] = cmp.mapping.scroll_docs(-1),
            -- ['<A-e>'] = cmp.mapping.scroll_docs(1),
            -- ['<A-u>'] = cmp.mapping.scroll_docs(-4),
            -- ['<A-d>'] = cmp.mapping.scroll_docs(4),
            --
            ['<C-[>'] = cmp.mapping.close(),

            ['<C-p>'] =
                function()
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                    else
                        cmp.complete({ select = true })
                    end
                end,

            ['<C-i>'] = function()
                cmp.complete({ performance = { max_view_entries = 1 } })
                cmp.confirm({ select = true })
            end,
            ['<Tab>'] = vim.NIL,
            ['<C-n>'] =
                function()
                    -- cmp.select_next_item({ behaviour = cmp.ConfirmBehavior.Replace })
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                    else
                        cmp.complete({ select = true })
                    end
                end,
            ['<C-y>'] = function()
                cmp.confirm({ select = true })
            end,
            -- luasnip mapping
            -- ['<C-l>'] = function()
            --     luasnip.expand_or_jump()
            -- end,
            -- ['<C-h>'] = function()
            --     luasnip.jump(-1)
            -- end
        }),
        sources = cmp.config.sources({

            { name = 'path' },
            {
                name = 'nvim_lsp',
                priority = 5,
                group_index = 2,
                keword_length = 1,
                entry_filter = function(entry)
                    local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]
                    return kind ~= 'Keyword'
                end
            },
            { name = 'luasnip',        priority = 1, group_index = 1, keword_length = 5 }, -- For luasnip users.
            { name = 'render-markdown' },
            -- { name = 'vsnip',    keyword_length = 1 }, -- For vsnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
        }
        ),
    })

    -- Set configuration for specific filetype.
    -- cmp.setup.filetype('gitcommit', {
    --     sources = cmp.config.sources({
    --         { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    --     }, {
    --         { name = 'buffer' },
    --     })
    -- })

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
        completion = {
            autocomplete = { cmp.TriggerEvent.TextChanged }
        },
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })
end
