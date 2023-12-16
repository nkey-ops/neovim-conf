local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {} )
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)


vim.keymap.set('n', '<leader>pt',
        function ()
            builtin.treesitter()
        end
, {})
vim.keymap.set('n', '<leader>pm',
        function ()
            builtin.treesitter({symbols = {'method', 'function'}, search = "moves"})
        end
, {})

vim.keymap.set('n', '<leader>pva',
        function ()
            builtin.treesitter({symbols = 'var'})
        end
, {})

