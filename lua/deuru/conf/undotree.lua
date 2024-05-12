vim.keymap.set("n", "<leader>u",
    function ()
     vim.cmd.UndotreeToggle()
     vim.cmd.UndotreeFocus()
end)

vim.keymap.set("n", "<leader>uf",
    function ()
     vim.cmd.UndotreeFocus()
end)
