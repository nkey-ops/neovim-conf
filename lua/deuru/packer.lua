-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', breanch = '0.1.x',
        -- or                            , branch = '0.1.x',

        requires =
        {
            { 'nvim-lua/plenary.nvim' },
        }
    }

    -- Requires manual compilation via "make" at the directory where
    -- packer installed it
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    --THEMES
    use({
        'rose-pine/neovim',
        as = 'rose-pine',
    })
    use { "catppuccin/nvim", as = "catppuccin" }
    --  use { "briones-gabriel/darcula-solid.nvim", requires = "rktjmp/lush.nvim" }
    --  use {'AlexvZyl/nordic.nvim'}
    --  use {'doums/darcula'}
    --  use { 'xiantang/darcula-dark.nvim',
    --      requires = {"nvim-treesitter/nvim-treesitter"}
    --  }
    -- ENDS THEMES

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('nvim-treesitter/playground')
    use {
        'theprimeagen/harpoon',
        branch = "harpoon2"
    }
    use('mbbill/undotree')
    use('tpope/vim-fugitive')

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },             -- Required
            -- { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
        }
    }
    use {
        'williamboman/mason.nvim',
        opts = {
            registries = {
                'github:nvim-java/mason-registry',
                'github:mason-org/mason-registry',
            },
        },
    }

    use('williamboman/mason-lspconfig.nvim')
    use('neovim/nvim-lspconfig')

    -- compatibilities set up
    use('hrsh7th/nvim-cmp')
    use('hrsh7th/cmp-buffer')
    use('hrsh7th/cmp-path')
    use('hrsh7th/cmp-cmdline')

    use('hrsh7th/cmp-nvim-lsp')
    use('hrsh7th/cmp-vsnip')
    use('hrsh7th/vim-vsnip')
    use("rafamadriz/friendly-snippets")
    --icons for Autocompletion
    use('onsails/lspkind.nvim')

    use('mfussenegger/nvim-jdtls')
    use('mfussenegger/nvim-dap')

    use('Pocco81/auto-save.nvim')
    require('auto-save').setup({
        enabled = false,
    })
    --
    -- MARKDOWN
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- Status Lne
    use {
        'nvim-lualine/lualine.nvim',
        requires = { "nvim-tree/nvim-web-devicons" }
    }

    --checkstyle
    use('jose-elias-alvarez/null-ls.nvim')
    --    use('mfussenegger/nvim-lint')
    use("ray-x/lsp_signature.nvim")

    -- Google Format
    use("google/vim-codefmt")
    use("google/vim-maktaba")
    use("google/vim-glaive")
    -- end

    use {
        "rest-nvim/rest.nvim",
        --commit = "8b62563",
        tag = "v1.2.1",
        requires = { "nvim-lua/plenary.nvim" },
    }

    -- Database
    use {
        "kristijanhusak/vim-dadbod-ui",
        requires = {
            "tpope/vim-dadbod",
            "kristijanhusak/vim-dadbod-completion",
            opt = true
        }

    }

    use { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} }

    -- Vim Extensions
    use { "tpope/vim-surround" }
    use { "nelstrom/vim-visual-star-search" }
    --
    --use { "aquasecurity/vim-trivy" } -- TODO

    -- Languages
    -- YAML
    use {
        "someone-stole-my-name/yaml-companion.nvim",
        requires = {
            { "neovim/nvim-lspconfig" },
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope.nvim" },
        },
        config = function()
            require("telescope").load_extension("yaml_schema")
        end,
    }

    --Comments
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }
    -- useless
    use { 'eandrju/cellular-automaton.nvim' }

    use {
        'nvimdev/dashboard-nvim',
        event = 'VimEnter',

        theme = 'hyper',
        hide = {
            tabline = true
        },
        require("dashboard").setup({
            theme = 'hyper',
            hide = {
                tabline = true
            },
            config = {
                week_header = {
                    enable = true,
                },
                shortcut = {
                    {
                        desc = '󰊳 Update',
                        group = '@property',
                        action = 'lua require("packer").update()',
                        key = 'u'
                    },
                    {
                        icon = ' ',
                        icon_hl = '@variable',
                        desc = 'Files',
                        group = 'Label',
                        action = 'Telescope find_files',
                        key = 'f',
                    },
                },
            },
        }),
        requires = { 'nvim-tree/nvim-web-devicons' }
    }
end)
