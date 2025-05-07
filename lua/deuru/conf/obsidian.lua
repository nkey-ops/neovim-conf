return function()
    local obsidian = require("obsidian")

    obsidian.setup({
        workspaces = {
            {
                name = "notes",
                path = "~/table/notes",
            },
            -- {
            --     name = "no-vault",
            --     path = function()
            --         -- alternatively use the CWD:
            --         -- return assert(vim.fn.getcwd())
            --         return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
            --     end,
            --     overrides = {
            --         notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
            --         new_notes_location = "current_dir",
            --         templates = {
            --             folder = vim.NIL,
            --         },
            --         disable_frontmatter = true,
            --     },
            -- },
        },

        daily_notes = {
            -- Optional, if you keep daily notes in a separate directory.
            folder = "dailies",
            -- -- Optional, if you want to change the date format for the ID of daily notes.
            -- date_format = "%Y-%m-%d",
            -- -- Optional, if you want to change the date format of the default alias of daily notes.
            -- alias_format = "%B %-d, %Y",
            -- -- Optional, default tags to add to each new daily note created.
            -- default_tags = { "daily-notes" },
            -- -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
            -- template = nil
        },

        -- Optional, configure additional syntax highlighting / extmarks.
        -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
        ui = {
            enable = false, -- set to false to disable all additional syntax features
        },
    })

    vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianQuickSwitch<CR>")
end
