require("deuru.remap")
require("deuru.remap-layout")
require("deuru.set")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

local req_conf = function(mod)
    return require("deuru.conf." .. mod)
end

req_conf("filetypes.filetypes")
req_conf("filetypes.sql")
req_conf("filetypes.md")
req_conf("cwd-settings")


local plugins = {
    {
        'nvim-telescope/telescope.nvim',
        -- tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = req_conf('telescope'),
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release' ..
            '&& cmake --build build --config Release' ..
            '&& cmake --install build --prefix build'
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = req_conf('colors'),
        init = function()
            if tonumber(os.date("%H")) > 9 and tonumber(os.date("%H")) < 20 then
                vim.cmd.colorscheme("catppuccin-macchiato")
            else
                vim.cmd.colorscheme("catppuccin-mocha")
            end
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/playground" },
        build = ":TSUpdate",
        config = req_conf('treesitter')
    },
    {
        'mbbill/undotree',
        init = function() req_conf('undotree') end
    },
    {
        'tpope/vim-fugitive',
        config = req_conf('fugitive')
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = false,
        enabled = false,
        init = function()
            -- Disable automatic setup, we are doing it manually
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end
    },

    {
        "ray-x/lsp_signature.nvim",
        event = 'VeryLazy',
        opts = {
            bind = true, -- This is mandatory, otherwise border config won't get registered.
            floating_window = false,
            ignore_error = function(_, _, _) return true end
        }
    },

    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
        init = function() req_conf('mason') end,
    },
    {
        'hrsh7th/nvim-cmp',
        eventgt = { 'InsertEnter',
            'CmdlineEnter'
        },
        enabled = true,
        config = req_conf('cmp-conf'),
        dependencies = {
            { 'L3MON4D3/LuaSnip',                    version = "v2.*", },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-cmdline' },
            { 'hrsh7th/nvim-cmp' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'rafamadriz/friendly-snippets' },
            { 'kristijanhusak/vim-dadbod-completion' },

            { 'onsails/lspkind.nvim' },
        },
        init = function() req_conf("luasnip") end,
    },
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'williamboman/mason-lspconfig.nvim' },
        },
        init = function()
            req_conf('lsp-init')
            vim.lsp.inlay_hint.enable(false)
        end
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true,
        enabled = false,
        -- use opts = {} for passing setup options
        -- this is equalent to setup({}) function
    },
    {
        'mfussenegger/nvim-jdtls',
        enabled = true,
        dependencies = {
            {
                'jose-elias-alvarez/null-ls.nvim',
                init = function() req_conf('checkstyle-init') end,
                enabled = false
            },
            { 'mhartington/formatter.nvim', lazy = true }
        },
        ft = { "java", "class" },
        config = function()
            vim.api.nvim_create_autocmd('filetype', {
                pattern = "java",
                callback = function()
                    require("jdtls").start_or_attach(req_conf("java")())
                end
            })
            req_conf("java-init")
        end,
        lazy = true,
    },

    {
        "someone-stole-my-name/yaml-companion.nvim",
        dependencies = {
            { "neovim/nvim-lspconfig" },
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope.nvim" },
        },
        config = function()
            require("telescope").load_extension("yaml_schema")
        end,
    },
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            "rcarriga/nvim-dap-ui",
            dependencies = { "nvim-neotest/nvim-nio" }
        },
        init = function() req_conf('dap-init') end
    },
    {
        'Pocco81/auto-save.nvim',
        config = req_conf('auto-save'),
        enabled = true
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = req_conf('lualine'),
    },

    {
        'rest-nvim/rest.nvim',
        dependencies = { "nvim-lua/plenary.nvim" },
        ft = 'http',
        init = function()
            req_conf('rest-nvim')
            req_conf('rest-nvim-init')
        end
    },
    {
        'kristijanhusak/vim-dadbod-ui',
        dependencies = {
            { 'tpope/vim-dadbod', lazy = true },
            {
                'kristijanhusak/vim-dadbod-completion',
                ft = { 'sql', 'mysql', 'plsql' },
                lazy = true
            },
        },
        cmd = {
            'DBUI',
            'DBUIToggle',
            'DBUIAddConnection',
            'DBUIFindBuffer',
        },
        init = function() req_conf('dadbod-init') end
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        main = "ibl",
        enabled = true,
        config =
            function()
                require("ibl").setup {
                    scope = {
                        enabled = true,
                        show_exact_scope = true,
                        highlight = { "LineNr" },
                        exclude = { language = { "markdown", "codecompanion", "md" } }
                    },
                }
            end,
    },
    { "tpope/vim-surround" },
    { "nelstrom/vim-visual-star-search" },
    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    },
    {
        -- "nkey-ops/extended-marks.nvim",
        dir = "/home/local/table/extended-marks.nvim/",
        enabled = true,

        --- @type ExtendedMarksOpts
        opts = {
            -- path where 'extended-marks' dir will be created
            data_dir = "~/.cache/nvim",
            confirmation_on_last_key = true,
            confirmation_on_replace = true,
            Global = {
                key_length = 4
            },
            Cwd = {
                key_length = 5,
            },
            Local = {
                key_length = 3, -- valid from 1 to 30
                sign_column = 1,
            },
            Tab = {
                key_length = 2,
            },
            post_script = function(result)
                local misc = require("extended-marks.misc")
                local module = misc.ActionResultModule
                local type = misc.ActionResultType
                if (result.type == type.DELETE_MARK
                        or result.type == type.SET_MARK)
                    and result.module ~= module.LOCAL
                    and result.success == true then
                    require("tabby.tabline").render()
                end

                if result.type == type.JUMPT_TO_MARK
                    and result.module == module.LOCAL
                    and result.success == true then
                    vim.api.nvim_command(":normal! zt")
                end
            end
        },
        init = function()
            local marks = require('extended-marks')
            vim.keymap.set("n", "m", marks.set_cwd_or_local_mark)
            vim.keymap.set("n", "`", marks.jump_to_cwd_or_local_mark)
            vim.keymap.set("n", "M", marks.set_global_or_tab_mark)
            vim.keymap.set("n", "'", marks.jump_to_global_or_tab_mark)
        end,
    },
    {
        "tpope/vim-eunuch"
    },
    {
        "nanozuki/tabby.nvim",
        dependencies = 'nvim-tree/nvim-web-devicons',
        init = function() req_conf('tabby-init') end
    },

    {
        "danymat/neogen",
        config = true,
        enabled = false,
        -- Uncomment next line if you want to follow only stable versions
        -- version = "*"
    },
    {
        "lewis6991/gitsigns.nvim",
        config = true,
    },
    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {},
        init = function()
            vim.keymap.set("n", "<M-t>", "<Cmd>TodoTelescope cwd=src/main/java<CR>")
        end
    },
    {
        'AckslD/messages.nvim',
        config = function() require("messages").setup() end,
    },

    -- MARKDONW SHENANIGANS
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown", "codecompanion" }
            vim.g.mkdp_auto_close = 0
            vim.g.mkdp_auto_start = 0
            vim.g.mkdp_combine_preview = 0
        end,
        ft = { "markdown", "md", "codecompanion" },
        keys = {
            {
                "<leader>pt",
                "<cmd>MarkdownPreviewToggle<cr>",
                ft = { "markdown", "md", "codecompanion" },
                desc = "Markdown: [P]review [T]oggle"
            }
        },
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = require("deuru.conf.obsidian")
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ft = { "markdown", "md", "codecompanion" },
        opts = {
            completions = { lsp = { enabled = true } },
            indent = { enabled = true, skip_heading = true, icon = "" },
            pipe_table = { cell = "trimmed" },
            latex = {
                enabled = false,
                -- top_pad = 1
                highlight = 'PmenuSel',
                -- converter = 'latex2text --fill-text'
            }
        },
        keys = {
            {
                "<leader>rt",
                '<cmd>RenderMarkdown toggle<cr>',
                ft = { "markdown", "md" },
                desc = "Markdown: [R]ender [T]oggle"
            }
        },
    },

    -- {
    --     "JavaHello/spring-boot.nvim",
    --     dependencies = {
    --         "mfussenegger/nvim-jdtls",
    --     },
    --     config = {
    --         -- ls_path = "/home/local/sts-4.29.1.RELEASE/plugins/org.springframework.tooling.boot.ls_1.61.1.202503181316/servers/spring-boot-language-server/lib/spring-boot-3.4.0.jar",
    --         ls_path = "/home/local/.vscode/extensions/vmware.vscode-spring-boot-1.61.1/language-server/spring-boot-language-server-1.61.1-SNAPSHOT-exec.jar"
    --     }    },
    --     enabled = false
    -- }
    {
        "m4xshen/hardtime.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {}
    },
    {
        dir = "~/table/hireg",
        opts = {}
    },
    {
        "olimorris/codecompanion.nvim",
        version = "^19.0.0",
        enabled = true,
        opts = {
            display = {
                chat = {
                    auto_scroll = true,
                    -- show_settings = true,
                }
            },
            interactions = {
                chat = {
                    adapter = "claude_code",
                }
            },
            adapters = {
                acp = {
                    -- opts = { show_presets = false },
                    claude_code = function()
                        return require("codecompanion.adapters")
                            .extend("claude_code", {})
                    end,
                },
                http = {
                    opts = { show_presets = false },
                    gemini = function()
                        return require("codecompanion.adapters").extend("gemini", {
                            defaults = {
                                auth_method = "gemini-api-key",

                            },
                            schema = {
                                model = {
                                    default = "gemini-3-flash-preview"
                                }
                            }
                        })
                    end
                },
            },
            opts = {
                log_level = "DEBUG"
            }
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        init = function()
            vim.keymap.set({ "n", "v" }, "<Leader>a", "<cmd>CodeCompanionChat Toggle<cr>",
                { noremap = true, silent = true })
            req_conf("codecompanion")
        end

    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        enabled = false,
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                sql = { "sqlfluff" },
                mysql = { "sqlfluff" },

            },
            formatters = {
                sqlfluff = {
                    args = { "format",
                        "--config", vim.fn.expand("~/.config/dotfiles/sqlfluff/.sqlfluff"),
                        "-" },
                    exit_codes = { 0, 1 },
                },
            },
            format_on_save = {
                timeout_ms = 10000,
                lsp_fallback = true,
            },
        },
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        opts = {
            -- Size can be a number or function
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<c-\>]], -- Shortcut to toggle
            hide_numbers = true,
            shade_terminals = true,
            start_in_insert = true,
            insert_mappings = true,   -- whether or not the open mapping applies in insert mode
            terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
            persist_size = true,      -- This fixes the "resizing" issue by remembering window sizes
            direction = 'float',      -- 'vertical' | 'horizontal' | 'tab' | 'float'
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = 'curved',
                winblend = 3,
            },
        },
        config = function(_, opts)
            require("toggleterm").setup(opts)

            -- Terminal Navigation Maps
            function _G.set_terminal_keymaps()
                local map_opts = { buffer = 0 }
                -- jk to escape terminal mode and use vim motions
                -- vim.keymap.set('t', 'jk', [[<C-\><C-n>]], map_opts)
                -- Easy movement between splits from within the terminal
                -- vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], map_opts)
                -- -- ...existing code...
                -- vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], map_opts)
                -- vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], map_opts)
                -- vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], map_opts)
            end

            -- Apply maps when terminal opens
            -- vim.api.nvim_create_autocmd("TermOpen", {
            --   pattern = "term://*",
            --   callback = function()
            --     set_terminal_keymaps()
            --   end,
            -- })
        end
    }
}
require("lazy").setup(plugins)
