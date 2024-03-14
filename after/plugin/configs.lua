 vim.keymap.set({'n'}, '<C-[>', function()
        local buffer = vim.fn.win_getid()

         if  vim.api.nvim_win_is_valid(buffer) and
             vim.api.nvim_win_get_config(buffer).relative ~= '' then

             vim.api.nvim_win_close(buffer, false)
         end
 end, {desc = "Close floating window"})
--
--
