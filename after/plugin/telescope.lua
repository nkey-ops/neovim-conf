local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require('telescope.builtin')

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

        mappings = {
            i = {
                -- exit on esc press
                ["<esc>"] = actions.close,
                --["<CR>"] =  actions.select_default + actions.center,
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
}


vim.keymap.set('n', '<leader>tf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>tg', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)


vim.keymap.set('n', '<leader>ta',
    function() builtin.treesitter() end,
    { desc = "[T]elescope: List [A]ll Symbols" })
vim.keymap.set('n', '<leader>tm',
    function()
        builtin.treesitter(
            {
                symbols = { 'method', 'function' },
                search = "moves"
            })
    end,
    { desc = "[T]elescope: List [M]ethods" })
vim.keymap.set('n', "<leader>tw",
    function()
        builtin.lsp_dynamic_workspace_symbols(
            {
                fname_width = 80,
                symbol_width = 100
            })
    end,
    { desc = "[T]elescope: Search Dynamically [W]orkspace Symbols" })
