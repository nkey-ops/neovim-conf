require('lsp_signature').setup({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
    },
    border = "rounded",
    floating_window = false,
})

local opts = { silent = true, noremap = true, desc = 'toggle signature' };

vim.keymap.set({'i' }, '<C-f>', function()
    require('lsp_signature').toggle_float_win()
end, opts)
