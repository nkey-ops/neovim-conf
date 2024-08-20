local dap, dapui = require("dap"), require("dapui")
local widgets = require("dap.ui.widgets")

-- dap.configurations.java = {
--     -- --vscode java clien args
--     -- {
--     --     type = 'java',
--     --     -- attach to a running Java program that was started with --debug-jvm
--     --     -- and that is waiting on 5005 for a debug adapter to attach
--     --     request = 'attach',
--     --     name = "Java attach",
--     --     hostName = "127.0.0.1",
--     --     port = 5005,
--     --     projectName = "Current Project",
--     -- }
-- }

dap.defaults.fallback.switchbuf = "usetab, useopen, uselast"

local my_sidebar = widgets.sidebar(widgets.frames)
vim.keymap.set("n", "<leader>dws", function() my_sidebar.open() end)
local map = vim.keymap;

map.set('n', '<leader>dc', function() dap.continue() end, { desc = "Debug: [C]ontinue" })
map.set('n', '<leader>drl', function() dap.run_last() end, { desc = "Debug: [R]un [L]ast" })
map.set('n', '<leader>dre', function() dap.restart() end, { desc = "Debug: [R]estart" })
map.set('n', '<leader>drc', function() dap.run_to_cursor() end, { desc = "Debug: [R]un to the [C]ursor" })
map.set('n', '<leader>dte', function() dap.terminate() end, { desc = "Debug: [Te]minate" })
map.set('n', '<leader>dp', function() dap.pause() end, { desc = "Debug: [P]ause" })
-- Steps
map.set('n', '<leader>dsv', function() dap.step_over() end, { desc = "Debug: [S]tep [O]ver" })
map.set('n', '<leader>dsi', function() dap.step_into({ askForTargets = true }) end, { desc = "Debug: [S]tep [I]nto" })
map.set('n', '<leader>dst', function() dap.step_out() end, { desc = "Debug: [S]tep Out" })
map.set('n', '<leader>dsb', function() dap.step_back() end, { desc = "Debug: [S]tep [B]ack" })
-- Breakpoints
map.set('n', '<leader>dbt', function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
map.set('n', '<leader>db', function() dap.set_breakpoint() end, { desc = "Debug: Set Breakpoint" })
map.set('n', '<leader>dbc', function()
    dap.set_breakpoint(
        vim.fn.input("Condition: "),
        vim.fn.input("Times Hit: "),
        vim.fn.input("Log message: "))
end, { desc = "Debug: Set Breakpoint with Conditions" })
map.set('n', '<leader>dbl', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log message: ')) end,
    { desc = "Debug: Set [B]reakpoint with [l]og message" })
-- map.set('n', '<leader>dbe', function() dap.set_exception_breakpoints() end, { desc = "Debug: [C]lear [B]reakpoints" })
map.set('n', '<leader>dbl', function() dap.list_breakpoints() end, { desc = "Debug: [L]ist [B]reakpoints" })
map.set('n', '<leader>dbd', function() dap.clear_breakpoints() end, { desc = "Debug: [C]lear [B]reakpoints" })

-- map.set('n', '<C-d>p', function() dap.up() end, { desc = "Debug: [S]tacktrace Up" })
-- map.set('n', '<C-d>n', function() dap.down() end, { desc = "Debug: [S]tacktrace Down" })

map.set('n', '<leader>df', function() dap.focus_frame() end, { desc = "Debug: [F]ocus Frame" })
map.set('n', '<leader>dfr', function() dap.restart_frame() end, { desc = "Debug: [R]estart Frame" })

map.set('n', '<leader>dur', function() dap.repl.toggle() end)
map.set('n', '<leader>dui', function() dapui.toggle() end)

vim.keymap.set({ 'n', 'v' }, '<leader>dh', function()
    widgets.hover()
end)
vim.keymap.set({ 'n', 'v' }, '<leader>dp', function()
    widgets.preview()
end)
vim.keymap.set('n', '<leader>df', function()
    widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<leader>ds', function()
    widgets.centered_float(widgets.scopes)
end)

dapui.setup()
dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end
