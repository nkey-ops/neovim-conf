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



local api = vim.api

local lazy = setmetatable({
    async = nil,       --- @module "dap.async"
    utils = nil,       --- @module "dap.utils"
    progress = nil,    --- @module "dap.progress"
    ui = nil,          --- @module "dap.ui"
    breakpoints = nil, --- @module "dap.breakpoints"
}, {
    __index = function(_, key)
        return require('dap.' .. key)
    end
})

---@diagnostic disable-next-line: deprecated
local islist = vim.islist or vim.tbl_islist

local M = {}

--- Configurations per adapter. See `:help dap-configuration` for more help.
---
--- An example:
---
--- ```
--- require('dap').configurations.python = {
---   {
---       name = "My configuration",
---       type = "debugpy", -- references an entry in dap.adapters
---       request = "launch",
---       -- + Other debug adapter specific configuration options
---   },
--- }
--- ```
---@type table<string, dap.Configuration[]>
M.configurations = {}

local providers = {
    ---@type table<string, fun(bufnr: integer): dap.Configuration[]>
    configs = {},
}
do
    local providers_mt = {
        __newindex = function()
            error("Cannot add item to dap.providers")
        end,
    }
    M.providers = setmetatable(providers, providers_mt)
end

providers.configs["dap.global"] = function(bufnr)
    local filetype = vim.b["dap-srcft"] or vim.bo[bufnr].filetype
    local configurations = M.configurations[filetype] or {}
    assert(
        islist(configurations),
        string.format(
            '`dap.configurations.%s` must be a list of configurations, got %s',
            filetype,
            vim.inspect(configurations)
        )
    )
    return configurations
end

providers.configs["dap.launch.json"] = function()
    local ok, configs = pcall(require("dap.ext.vscode").getconfigs)
    if not ok then
        local msg = "Can't get configurations from launch.json:\n%s" .. configs
        vim.notify_once(msg, vim.log.levels.WARN, { title = "DAP" })
        return {}
    end
    return configs
end


local function notify(...)
    lazy.utils.notify(...)
end

M.select_config_and_run = function(opts)
    local bufnr = api.nvim_get_current_buf()
    local filetype = vim.bo[bufnr].filetype

    local all_configs = {}
    local provider_keys = vim.tbl_keys(providers.configs)
    table.sort(provider_keys)
    for _, provider in ipairs(provider_keys) do
        local config_provider = providers.configs[provider]
        local configs = config_provider(bufnr)
        if islist(configs) then
            vim.list_extend(all_configs, configs)
        else
            local msg = "Configuration provider %s must return a list of configurations. Got: %s"
            notify(msg:format(provider, vim.inspect(configs)), vim.log.levels.WARN)
        end
    end

    if #all_configs == 0 then
        local msg =
        'No configuration found for `%s`. You need to add configs to `dap.configurations.%s` (See `:h dap-configuration`)'
        notify(string.format(msg, filetype, filetype), vim.log.levels.INFO)
        return
    end

    opts = opts or {}
    opts.filetype = opts.filetype or filetype

    local result
    lazy.ui.pick_if_many(
        all_configs,
        "Configuration: ",
        function(i) return i.name end,
        function(configuration)
            if configuration then
                result =
                    configuration
            else
                notify('No configuration selected', vim.log.levels.INFO)
            end
        end
    )

    return result
end
return M
