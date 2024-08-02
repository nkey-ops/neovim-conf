return function()
    local obsidian = require("obsidian")

    obsidian.setup({
        workspaces = {
            {
                name = "notes2",
                path = "~/table/notes",
            },
            {
                name = "no-vault",
                path = function()
                    -- alternatively use the CWD:
                    -- return assert(vim.fn.getcwd())
                    return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
                end,
                overrides = {
                    notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
                    new_notes_location = "current_dir",
                    templates = {
                        folder = vim.NIL,
                    },
                    disable_frontmatter = false,
                },
            },
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
            enable = true,  -- set to false to disable all additional syntax features
            update_debounce = 200, -- update delay after a text change (in milliseconds)
            max_file_length = 5000, -- disable UI features for files with more than this many lines
            -- Define how various check-boxes are displayed
            checkboxes = {
                -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
                [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                ["x"] = { char = "", hl_group = "ObsidianDone" },
                [">"] = { char = "", hl_group = "ObsidianRightArrow" },
                ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
                ["!"] = { char = "", hl_group = "ObsidianImportant" },
                -- Replace the above with this if you don't have a patched font:
                -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

                -- You can also add more custom ones...
            },
            -- Use bullet marks for non-checkbox lists.
            bullets = { char = "•", hl_group = "ObsidianBullet" },
            external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            -- Replace the above with this if you don't have a patched font:
            -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            reference_text = { hl_group = "ObsidianRefText" },
            highlight_text = { hl_group = "ObsidianHighlightText" },
            tags = { hl_group = "ObsidianTag" },
            block_ids = { hl_group = "ObsidianBlockID" },
            hl_groups = {
                -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
                ObsidianTodo = { bold = true, fg = "#f78c6c" },
                ObsidianDone = { bold = true, fg = "#89ddff" },
                ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
                ObsidianTilde = { bold = true, fg = "#ff5370" },
                ObsidianImportant = { bold = true, fg = "#d73128" },
                ObsidianBullet = { bold = true, fg = "#89ddff" },
                ObsidianRefText = { underline = true, fg = "#c792ea" },
                ObsidianExtLinkIcon = { fg = "#c792ea" },
                ObsidianTag = { italic = true, fg = "#89ddff" },
                ObsidianBlockID = { italic = true, fg = "#89ddff" },
                ObsidianHighlightText = { bg = "#75662e" },
            },
        },

    })

    vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianQuickSwitch<CR>")
end
