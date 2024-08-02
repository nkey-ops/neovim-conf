--- line 353 ~/.local/share/nvim/lazy/telescope.nvim/lua/telescope/utils.lua comment out
return function()
    local telescope = require("telescope")
    local builtin = require('telescope.builtin')
    local actions = require "telescope.actions"

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
    vim.keymap.set('n', '<A-f>g', builtin.git_files, {})
    vim.keymap.set('n', '<A-g>', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") });
    end)


    vim.keymap.set('n', '<leader>gi', builtin.lsp_implementations, {})


    -- LSP Document Symbols
    vim.keymap.set('n', '<A-s>a', function()
            builtin.lsp_document_symbols(
                { show_line = true }
            )
        end,
        { desc = "Telescope: List [A]ll [S]ymbols" })
    vim.keymap.set('n', '<A-s>f', function()
        builtin.lsp_document_symbols(
            {
                symbols = { "field", "constant" },
                symbol_type_width = 0,
                show_line = true
            })
    end, { desc = "Telescope: List [F]ields" })
    vim.keymap.set('n', '<A-s>m', function()
        builtin.lsp_document_symbols(
            {
                symbols = { "method" },
                symbol_type_width = 0,
                show_line = true
            })
    end, { desc = "Telescope: List [M]ethods" })
    vim.keymap.set('n', '<A-s>c', function()
        builtin.lsp_document_symbols(
            {
                symbols = { "class" },
                symbol_type_width = 0,
                show_line = true
            })
    end, { desc = "Telescope: List [C]lasses" })
    vim.keymap.set('n', '<A-s>t', function()
        builtin.lsp_document_symbols(
            {
                symbols = { "constructor" },
                symbol_type_width = 0,
                show_line = true
            })
    end, { desc = "Telescope: List Cons[t]ructors" })

    -- LSP Workspace Symbols
    vim.keymap.set('n', "<A-w>", function()
            builtin.lsp_dynamic_workspace_symbols(
                {
                    fname_width = 80,
                    symbol_width = 40,
                    show_line = true
                })
        end,
        { desc = "Telescope: Search Dynamically [W]orkspace Symbols" })
    --
    -- Buffers
    vim.keymap.set("n", "<A-b>b", function()
        builtin.buffers({
            ignore_current_buffer = true,
            sort_mru = true,
            desc = "Telescope: Show [B]uffers"
        })
    end)
    vim.keymap.set("n", "<A-b>a", function()
        builtin.buffers({
            ignore_current_buffer = false,
            -- sort_mru = true,
            show_all_buffers = true,
            desc = "Telescope: Show [B]uffers"
        })
    end)
end
