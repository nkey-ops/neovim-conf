--- line 363 ~/.local/share/nvim/lazy/telescope.nvim/lua/telescope/utils.lua comment out
return function()
    local telescope = require("telescope")
    local builtin = require('telescope.builtin')
    local actions = require("telescope.actions")

    local fzf_opts = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
    }

    local string_byte, string_sub = string.byte, string.sub
    -- insane speed of a symbols lookup comparing to lua patterns
    local function strip_jdt_path(path)
        local tbl = { string_byte(path, 1, #path) } -- Note: This is about 15% faster than calling string.byte for every character.

        if #path < 17
            or tbl[1] ~= 106
            or tbl[2] ~= 100
            or tbl[3] ~= 116 then -- not 'jdt'
            return path
        end

        local last_slash
        local last_dollar_sign
        for i = 17, #tbl do
            c = tbl[i] -- Note: produces char codes instead of chars.
            if c == 47 then
                last_slash = i
            end
            if c == 36 then
                last_dollar_sign = i
            end

            if c == 63 then
                break
            end
        end

        if not last_slash then return path end
        return string_sub(path, 16, last_dollar_sign and last_dollar_sign - 1 or last_slash - 1)
    end

    telescope.setup {
        defaults = {
            layout_strategy = 'vertical',
            layout_config = { height = 0.95 },
            cache_picker = { 1, 100 },
            path_display = function(_, path)
                return strip_jdt_path(path)
            end,
            -- tiebreak = function(current_entry, existing_entry, _)
            --     return current_entry.value:len() < existing_entry.value:len()
            -- end,
            mappings = {
                i = {
                    -- exit on esc press
                    ["<esc>"] = actions.close,
                    ["<C-y>"] =
                        function()
                            actions.select_default(vim.api.nvim_get_current_buf())
                            vim.api.nvim_command(":normal! zt")
                        end,
                    ["<CR>"] =
                        function()
                            actions.select_default(vim.api.nvim_get_current_buf())
                            vim.api.nvim_command(":normal! zt")
                        end,
                }
            }
        },
        pickers = {
            -- Manually set sorter, for some reason not picked up automatically
            lsp_dynamic_workspace_symbols = {
                sorter = telescope.extensions.fzf.native_fzf_sorter(fzf_opts)
            },
        },
    }

    require('telescope').load_extension('fzf')

    vim.keymap.set('n', '<A-r>', builtin.resume, {})
    vim.keymap.set('n', '<A-f>d', function()
        builtin.find_files({ no_ignore = true, no_ignore_parent = true, follow = true })
    end, {})
    vim.keymap.set('n', '<A-f>g', function()
        builtin.git_files({ use_git_root = false, follow = true })
    end)
    vim.keymap.set('n', '<A-f>s', function()
        builtin.git_status({ use_git_root = true })
    end)
    vim.keymap.set('n', '<A-f>r', function()
        builtin.git_files({ use_git_root = false })
    end, {})

    vim.keymap.set('n', '<A-g>', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") });
    end)


    vim.keymap.set('n', '<leader>gi', builtin.lsp_implementations, {})

    local buffers = function()
        builtin.buffers({
            ignore_current_buffer = true,
            sort_mru = true,
        })
    end

    vim.keymap.set("n", "<A-b>", buffers, { desc = "Telescope: Show [B]uffers" })
end
