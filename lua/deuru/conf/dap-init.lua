local dap, dapui = require("dap"), require("dapui")
local widgets = require("dap.ui.widgets")
local map = vim.keymap;

-- dap.defaults.fallback.switchbuf = "usevisible, usetab, useopen, uselast"
dap.defaults.fallback.switchbuf = "uselast"

local function step_into()
    return dap.step_into({ askForTargets = true })
end
local function conditional_breakpoint()
    return dap.set_breakpoint(
        vim.fn.input("Condition: "),
        vim.fn.input("Times Hit: "),
        vim.fn.input("Log message: "))
end
local function log_breakpoint()
    dap.set_breakpoint(nil, nil, vim.fn.input('Log message: '))
end
local function float_frames() widgets.centered_float(widgets.frames) end
local function float_scopes() widgets.centered_float(widgets.scopes) end

-- Run
map.set('n', '<leader>drl', dap.run_last, --[[----------]] { desc = "Debug: [R]un [L]ast" })
map.set('n', '<leader>drr', dap.restart, --[[-----------]] { desc = "Debug: [R]un [R]estart" })
map.set('n', '<leader>drt', dap.run_to_cursor, --[[-----]] { desc = "Debug: [R]un [t]o the Cursor" })
map.set('n', '<leader>drc', dap.continue, --[[----------]] { desc = "Debug: [R]un [C]ontinue" })
map.set('n', '<leader>drs', dap.terminate, --[[---------]] { desc = "Debug: [R]un [S]top" })
map.set('n', '<leader>drp', dap.pause, --[[-------------]] { desc = "Debug: [R]un [P]ause" })
-- Steps
map.set('n', '<leader>dso', dap.step_over, --[[---------]] { desc = "Debug: [S]tep [O]ver" })
map.set('n', '<leader>dsi', step_into, --[[-------------]] { desc = "Debug: [S]tep [I]nto" })
map.set('n', '<leader>dst', dap.step_out, --[[----------]] { desc = "Debug: [S]tep Ou[t]" })
map.set('n', '<leader>dsb', dap.step_back, --[[---------]] { desc = "Debug: [S]tep [B]ack" })
-- Breakpoints
map.set('n', '<leader>dbt', dap.toggle_breakpoint, --[[-]] { desc = "Debug: Set [B]reakpoint [T]oggle" })
map.set('n', '<leader>dbc', conditional_breakpoint, --[[]] { desc = "Debug: Set [B]reakpoint with [C]onditions" })
map.set('n', '<leader>dbl', log_breakpoint, --[[--------]] { desc = "Debug: Set [B]reakpoint with [L]og message" })
map.set('n', '<leader>dbe', dap.set_exception_breakpoints, { desc = "Debug: Set [B]reakpoint on [E]xception" })
map.set('n', '<leader>dbl', dap.list_breakpoints, --[[--]] { desc = "Debug: [B]reakpoints [L]ist" })
map.set('n', '<leader>dbr', dap.clear_breakpoints, --[[-]] { desc = "Debug: [B]reakpoints [R]emove all" })
-- Frames
map.set('n', '<leader>dfp', dap.up, --[[----------------]] { desc = "Debug: [F]rame [P]revious" })
map.set('n', '<leader>dfn', dap.down, --[[--------------]] { desc = "Debug: [F]rame [N]ew" })
map.set('n', '<leader>dfr', dap.restart_frame, --[[-----]] { desc = "Debug: [F]rame [R]estart" })
map.set('n', '<leader>dff', dap.focus_frame, --[[-------]] { desc = "Debug: [F]rame [F]ocus" })
-- UI
map.set('n', '<leader>dut', dapui.toggle, --[[-----------]] { desc = "Debug: [U]I [T]oggle" })
map.set('n', '<leader>dus', function() dapui.toggle(1) end, { desc = "Debug: [U]I [S]ide Bar" })
map.set('n', '<leader>duc', function() dapui.toggle(2) end, { desc = "Debug: [U]I [C]onsole" })
map.set('n', '<leader>dur', function() dapui.toggle(3) end, { desc = "Debug: [U]I [R]epl" })
map.set('n', '<leader>duf', float_frames, --[[-----------]] { desc = "Debug: [U]I Floating [F]rames" })
map.set('n', '<leader>dup', float_scopes, --[[-----------]] { desc = "Debug: [U]I Floating Sco[p]es" })

map.set({ 'n', 'v' }, '<leader>dh', widgets.hover, --[[--]] { desc = "Debug: [H]over" })
map.set({ 'n', 'v' }, '<leader>dp', widgets.preview, --[[]] { desc = "Debug: [P]review" })

dapui.setup({
    layouts = { {
        elements = { {
            id = "scopes",
            size = 0.25
        }, {
            id = "breakpoints",
            size = 0.25
        }, {
            id = "stacks",
            size = 0.25
        }, {
            id = "watches",
            size = 0.25
        } },
        position = "left",
        size = 40
    }, {
        elements = { {
            id = "console",
            size = 0.5
        } },
        position = "bottom",
        size = 10
    }, {
        elements = {
            {
                id = "repl",
                size = 0.5
            },
        },
        position = "bottom",
        size = 10
    }
    }
})

dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function(config)
    if config.config.mainClass:match(".*junit.*") then
        dapui.open({ layout = 2 })
        dapui.open({ layout = 3 })
    else
        dapui.open({ layout = 2 })
    end
end
