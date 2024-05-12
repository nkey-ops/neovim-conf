require("deuru.remap") require("deuru.set")
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
local plugins = {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = require('deuru.conf.telescope')
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
        config = require('deuru.conf.colors'),
        init = function()
            vim.cmd('set termguicolors')
            vim.cmd.colorscheme("catppuccin-mocha")
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = require('deuru.conf.treesitter')
    },
    {
        'mbbill/undotree',
        init = function() require('deuru.conf.undotree') end
    },
    {
        'tpope/vim-fugitive',
        config = require('deuru.conf.fugitive')
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = false,
        init = function()
            -- Disable automatic setup, we are doing it manually
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end
    },

    {
        "ray-x/lsp_signature.nvim",
        event = 'VeryLazy',
        config = function()
            require('lsp_signature').setup({
                bind = true, -- This is mandatory, otherwise border config won't get registered.
                handler_opts = {
                    border = "rounded",
                },
                floating_window = false,
            })
        end,
        int = function()
            vim.keymap.set({ 'i' }, '<C-f>', function()
                require('lsp_signature').toggle_float_win()
            end, { silent = true, noremap = true, desc = 'toggle signature' })
        end

    },

    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
        init = function() require('deuru.conf.mason') end,
    },
    {
        'hrsh7th/nvim-cmp',
        event = { 'InsertEnter',
            -- 'CmdlineEnter'

        },
        config = require('deuru.conf.cmp'),
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
        }
    },
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' }, { 'williamboman/mason-lspconfig.nvim' },
        },
        config = require('deuru.conf.lsp-zero')
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equalent to setup({}) function
    },
    {
        'mfussenegger/nvim-jdtls',
        ft = 'java',
        config = require('deuru.conf.java'),
        lazy = true,
        init = function() require('deuru.conf.java-init') end
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
        init = function() require('deuru.conf.dap-init') end
    },
    { 'Pocco81/auto-save.nvim',         config = require('deuru.conf.auto-save') },
    {
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
        enabled = false
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = require('deuru.conf.lualine'),
    },

    {
        'jose-elias-alvarez/null-ls.nvim',
        dependencies = {
            "google/vim-codefmt",
            "google/vim-maktaba",
            "google/vim-maktaba",
            "google/vim-glaive"
        },
        init = function() require('deuru.conf.checkstyle-init') end,
        enabled = false
        --   use('mfussenegger/nvim-lint')
    },
    {
        'rest-nvim/rest.nvim',
        commit = "8b62563",
        tag = "v1.2.1",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = require('deuru.conf.rest-nvim'),
        init = function() require('deuru.conf.rest-nvim-init') end
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
        init = function() require('deuru.conf.dadbod-init') end
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        main = "ibl",
        config =
            function()
                require("ibl").setup {
                    scope = {
                        enabled = true,
                        show_exact_scope = true
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
    }

}

require("lazy").setup(plugins)
