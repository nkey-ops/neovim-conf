local dap = require("dap")
local widgets = require("dap.ui.widgets")


--vim.keymap.set("n", "<leader>dtb", function() dap.toggle_breakpoint() end)
--vim.keymap.set("n", "<leader>dc", function() dap.continue() end)
--vim.keymap.set("n", "<leader>dso", function() dap.start_over() end)
--vim.keymap.set("n", "<leader>dsi", function() dap.step_into() end)
--vim.keymap.set("n", "<leader>drep", function() dap.repl.open() end)

local my_sidebar = widgets.sidebar(widgets.frames)
vim.keymap.set("n", "<leader>dws", function() my_sidebar.open() end)

vim.keymap.set('n', '<F5>', function() dap.continue() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)
vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint() end)
vim.keymap.set('n', '<leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
vim.keymap.set('n', '<leader>dl', function() dap.run_last() end)




vim.keymap.set({'n', 'v'}, '<leader>dh', function()
  widgets.hover()
end)
vim.keymap.set({'n', 'v'}, '<leader>dp', function()
  widgets.preview()
end)
vim.keymap.set('n', '<leader>df', function()
  local widgets = widgets
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<leader>ds', function()
  local widgets = widgets
  widgets.centered_float(widgets.scopes)
end)

