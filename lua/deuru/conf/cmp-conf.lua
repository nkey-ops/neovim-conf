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

    local function refuse_first_or_second_object_methods(o1_insert_text, o2_insert_text)
        assert(type(o1_insert_text) == "string")
        assert(type(o2_insert_text) == "string")

        local methods = { "notify", "notifyAll", "wait",
            "toString", "hashCode", "equals", "getClass", "clone" }


        local does_o1_match = false
        local does_o2_match = false
        for _, method in pairs(methods) do
            if o1_insert_text:match(string.format("^%s$", method)) then
                does_o1_match = true
            end
            if o2_insert_text:match(string.format("^%s$", method)) then
                does_o2_match = true
            end
        end

        if (does_o1_match and does_o2_match) or
            (not does_o1_match and not does_o2_match) then
            return nil
        end

        return does_o1_match
    end

    local function refuse_first_or_second_deprecated_item(o1_tags, o2_tags)
        assert(type(o1_tags) == "table")
        assert(type(o2_tags) == "table")

        if o1_tags[1] == 1 or o2_tags[1] == 1 then
            if o1_tags[1] == o2_tags[1] then
                return nil
            else
                return o1_tags[1] == 1
            end
        end

        return nil
    end
    local function format(entry, vim_item)
        local lspkind_format = lspkind.cmp_format({ mode = 'symbol' })

        vim_item = lspkind_format(entry, vim_item)

        local kind = entry.completion_item.kind

        if kind ~= 15 then -- except snippets
            -- methods, functions and constructors
            if kind == 2 or kind == 3 or kind == 4 then
                -- word "named_function"
                -- abbr "named_function(String arg1)"
                -- >>
                -- menu -> "(String arg1)"
                local s = vim_item.word:find("(", 1, { plain = true })
                vim_item.menu = vim_item.abbr:sub(s or 1)
            else
                -- -- word "named_var"
                -- -- abbr "named_var : Var_Type"
                -- -- >>
                -- -- menu -> "Var_Type"
                vim_item.menu = vim_item.abbr:sub(#vim_item.word + 4)
            end

            local i = vim_item.menu:find(":")

            local type
            if i then
                type = vim_item.menu:sub(i):sub(1, 18)
                if #type == 18 then type = type .. ".." end
                vim_item.menu = vim_item.menu:sub(1, i - 2)
            end

            vim_item.menu = vim_item.menu:sub(1, 18)
            if #vim_item.menu == 18 then vim_item.menu = vim_item.menu .. ".." end

            vim_item.menu = string.format("%-20s", vim_item.menu)

            if type then
                vim_item.menu = vim_item.menu .. " " .. type
            end
            -- cmp only displayc "abbr", lets assing a shorter "word"
            vim_item.abbr = vim_item.word
        end

        local hl
        if kind == 1 then
            hl = "String"
        elseif kind == 2 or kind == 3 then
            hl = "Function"
        elseif kind == 5 then
            hl = "@variable.member"
        elseif kind == 7 then
            hl = "Type"
        elseif kind == 20 then
            hl = "Structure"
        elseif kind == 21 then
            hl = "Constant"
        end

        -- if the completion item is not deprecated set an hl
        if entry.completion_item.tags and entry.completion_item.tags[1] ~= 1 then
            vim_item.abbr_hl_group = hl
        end

        vim_item.kind_hl_group = hl
        return vim_item
    end

    local function nvim_lsp_entry_filter(entry, ctx)
        assert(type(entry) == "table", "entry shold not be nil and should have type 'table'")
        assert(type(ctx) == "table", "ctx shold not be nil and should have type 'table'")

        local kind = require('cmp.types').lsp.CompletionItemKind[entry:get_kind()]

        -- doing some replacements of responses
        if entry.completion_item.filterText then
            local f_text = entry.completion_item.filterText
            local newText = nil

            if f_text == "{@link}" then
                newText = "{@link ${1}} ${0}"
            elseif f_text == "{@code}" then
                newText = "{@code ${1}} ${0}"
            end

            -- before text is inserted cmp resolve the completion item against the server
            -- then it will call a callback so we can work the update data
            table.insert(entry.resolved_callbacks, function()
                if newText then
                    entry.completion_item.textEdit.newText = newText
                end
            end)
        end
        return kind ~= 'Keyword'
    end

    local comparators = {
        -- 1 Fuzzy matching with dismissal of items with an incorrect case match,
        -- 2 The shorter length the higher rate
        -- 3 Functions have the lowest rate out of other kinds
        -- 4 Snake case bad
        -- 5 Recently used
        -- 6 Kind -- snippets should be last
        -- 7 Scopes
        --
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
        --
        -- 2. length       | the shorter the better
        --    2.1. same lengths
        --         2.1.1 if one is a function | prefer non function
        --         2.1.2 both functions       | the less arguments the better
        --    2.2. variable name generation   | the longer the better
        -- 3. vars                            | prefered more than functions
        -- 4. if a snippet matches completely | highest rate otherwise lowest
        -- 9. deprecated                      | lowest rate

        function(e1, e2)
            local compare = function(o1, o2) -- length name sorting | the shorter the better
                local o1_kind = o1.completion_item.kind;
                local o2_kind = o2.completion_item.kind;
                local o1_label = o1.completion_item.label
                local o2_label = o2.completion_item.label
                local o1_tags = o1.completion_item.tags and o1.completion_item.tags or {}
                local o2_tags = o2.completion_item.tags and o2.completion_item.tags or {}

                local input = o1.match_view_args_ret.input;

                -- when kind "snippet" doesn't have an "insertText" use its "label"
                local o1_insert_text = o1.completion_item.insertText and o1.completion_item.insertText or
                    o1.completion_item.label
                local o2_insert_text = o2.completion_item.insertText and o2.completion_item.insertText or
                    o2.completion_item.label

                -- [9] deprecated items have the lowest rate
                local refuse_deprecated = refuse_first_or_second_deprecated_item(o1_tags, o2_tags)
                if refuse_deprecated ~= nil then
                    return not refuse_deprecated
                end

                local refuse_object_method = refuse_first_or_second_object_methods(o1_insert_text,
                    o2_insert_text)
                if refuse_object_method ~= nil then
                    return not refuse_object_method
                end

                -- [4]
                if (o1_kind == 15 or o2_kind == 15) and o1_kind ~= o2_kind then
                    if o1_kind == 15 then
                        return input ~= ""
                            and o1_label:match('^' .. input .. '$') ~=
                            nil
                    end
                    if o2_kind == 15 then
                        return not (input ~= "" and o2_label:match('^' .. input .. '$')) ~=
                            nil
                    end
                end


                local diff = #o1_insert_text - #o2_insert_text
                -- [2.1] same lengths
                if diff == 0 then
                    -- if the kind is the same of a completion item
                    if o1_kind == o2_kind then
                        -- [2.1.2] if both completion items are functions lets pick the one
                        --       with the least function arguments
                        if o1_kind == 2 then
                            local o1_text = o1.completion_item.filterText and o1.completion_item.filterText or
                                o1_insert_text
                            local o2_text = o2.completion_item.filterText and o2.completion_item.filterText or
                                o2_insert_text

                            local _, o1_arg_count = o1_text:gsub('${', '')
                            local _, o2_arg_count = o2_text:gsub('${', '')

                            local arg_diff = o1_arg_count - o2_arg_count
                            return arg_diff < 0
                        end
                        if diff == 0 then return nil end
                        return diff < 0
                    end

                    -- [2.1.1] if one is a function, lower its rate
                    if o1_kind == 2 then
                        return false
                    elseif o2_kind == 2 then
                        return true
                    else
                        return nil
                    end
                end

                -- [2.2] if this is a var name generation choose the longest name
                -- I don't know why and how these properties actually work
                -- but it seems that this is what is different between a new
                -- name generation of a variable and any other completions
                if o1.item_defaults and o2.item_defaults and
                    o1.item_defaults.data and o2.item_defaults.data and
                    o1.item_defaults.data.completionKinds[1] == 10 and
                    o2.item_defaults.data.completionKinds[1] == 10 then
                    return diff > 0
                end

                return diff < 0
            end

            return compare(e1, e2);
        end
    }

    local keybinds = {
        ['<C-y>'] = cmp.mapping.scroll_docs(-1),
        ['<C-e>'] = cmp.mapping.scroll_docs(1),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-[>'] = cmp.mapping.close(),
        ['<C-p>'] =
            function()
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    cmp.complete({ select = true })
                end
            end,
        ['<C-n>'] =
            function()
                -- cmp.select_next_item({ behaviour = cmp.ConfirmBehavior.Replace })
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    cmp.complete({ select = true })
                end
            end,
        ['<C-i>'] = function()
            cmp.complete({ performance = { max_view_entries = 1 } })
            cmp.confirm({ select = true })
        end,
        -- Mirrowing previous 3 key-maps for Buffer only completion
        ['<C-x><C-p>'] = function()
            cmp.complete({
                config = { sources = { { name = "buffer" } } },
                performance = {
                    max_view_entries = 1
                }
            })
            if cmp.visible() then
                cmp.select_prev_item({
                    config = { sources = { { name = "buffer" } } },
                    behavior = cmp.SelectBehavior.Select
                })
            else
                cmp.complete(
                    {
                        config = { sources = { { name = "buffer" } } },
                        select = true
                    })
            end
        end,
        ['<C-x><C-i>'] = function()
            if not cmp.visible() then
                cmp.complete({
                    config = { sources = { { name = "buffer" } } },
                    performance = {
                        max_view_entries = 1
                    }
                })
            end
            cmp.confirm({ select = true })
        end,
        -- inside a snippet navigation
        ['<C-c><C-n>'] = cmp.mapping(function()
            P(luasnip.jump(1))
        end, { "i", "s" }),
        ['<C-c><C-p>'] = cmp.mapping(function()
            luasnip.jump(-1)
        end, { "i", "s" })
    }

    cmp.setup {
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
        },
        matching = {
            disallow_fuzzy_matching = false,
            disallow_partial_fuzzy_matching = false,
            disallow_partial_matching = false, --
            disallow_prefix_unmatching = true, --
            disallow_symbol_nonprefix_matching = true,
        },
        sorting = {

            -- comparators = comparators
        },

        preselect = cmp.PreselectMode.Item,

        formatting = {
            fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
            -- format = format,
        },

        mapping = cmp.mapping.preset.insert(keybinds),
        sources = cmp.config.sources({

            { name = 'path' },
            {
                name = 'nvim_lsp',
                priority = 1,
                -- entry_filter = nvim_lsp_entry_filter
            },
            { name = 'luasnip',        priority = 2, group_index = 2 }, -- For luasnip users.
            { name = 'render-markdown' },
            -- { name = 'vsnip',    keyword_length = 1 }, -- For vsnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
        }
        ),
    }

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


-- local l = #params.context.cursor_line
-- if params.context.cursor_before_line:sub(l, l) == '(' then
--     lsp_params.position.character = params.context.cursor.character - 1
--     -- lsp_params.context.cursor_after_line = ""
--     -- lsp_params.context.cursor_before_line = params.context.cursor_before_line:sub(1,
--     --     #params.context.cursor_before_line - 1)
--     -- lsp_params.context.cursor_line = lsp_params.context.cursor_before_line
--     -- lsp_params.context.cursor = params.context.cursor
--     -- lsp_params.context.cursor.character = params.context.cursor.character - 1
-- end

-- P(lsp_params)
-- lsp_params.context.triggerKind = params.completion_context.triggerKind
-- lsp_params.context.triggerCharacter = params.completion_context.triggerCharacter
-- self:_request('textDocument/completion', lsp_params, function(_, response)
--     -- if response then
--     --     for _, item in pairs(response.items) do
--     --         if item.kind >= 2 and item.kind <= 4
--     --             and item.filterText
--     --             and item.detail and (item.filterText:sub(#item.filterText, #item.filterText) ~= ';'
--     --                 and item.filterText:sub(#item.filterText, #item.filterText) ~= ')') then
--     --             item.filterText = item.filterText .. (item.detail:match("%(%)") and "()" or "(${1})")
--     --             if item.insertText and item.textEdit then
--     --                 item.textEdit.newText = item.filterText
--     --             end
--     --         end
--     --     end
--     -- end
--     callback(response)
-- end)
--
-- if item.kind >= 2 and item.kind <= 4 then
--     if item.textEdit then
--         item.textEdit.newText = item.filterText
--     end
-- end
--
