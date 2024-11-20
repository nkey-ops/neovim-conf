--- line 353 ~/.local/share/nvim/lazy/telescope.nvim/lua/telescope/utils.lua comment out
return function()
    local telescope = require("telescope")
    local builtin = require('telescope.builtin')
    local actions = require("telescope.actions")
    local local_marks = require('extended-marks.local')

    local fzf_opts = {
        fuzzy = true,                   -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
    }

    telescope.setup {
        defaults = {
            layout_strategy = 'vertical',
            layout_config = { height = 0.95 },
            cache_picker = { 1, 100 },
            path_display = function(_, path)
                if path:match("jdt://.*") then
                    path = path:gsub("jdt://contents/(.-)%?.*", "%1");
                end
                return path
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
        builtin.find_files({ no_ignore = true, no_ignore_parent = true })
    end, {})
    vim.keymap.set('n', '<A-f>g', function()
        builtin.git_files({ use_git_root = false })
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
