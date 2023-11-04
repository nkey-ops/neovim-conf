-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', breanch = '0.1.x',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use({
        'rose-pine/neovim',
        as = 'rose-pine',
    })
--   use {'AlexvZyl/nordic.nvim'}
--    use {'doums/darcula'}
   -- use { "briones-gabriel/darcula-solid.nvim", requires = "rktjmp/lush.nvim" }
--    use {
--        'xiantang/darcula-dark.nvim',
--        requires = {"nvim-treesitter/nvim-treesitter"}
--   }
    use { "catppuccin/nvim", as = "catppuccin" }

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use('nvim-treesitter/playground')
    use('theprimeagen/harpoon')
    use('mbbill/undotree')
    use('tpope/vim-fugitive')

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                run = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
        }
    }

    use('neovim/nvim-lspconfig')

    -- compatibilities set up
    use('hrsh7th/nvim-cmp')
    use('hrsh7th/cmp-buffer')
    use('hrsh7th/cmp-path')
    use('hrsh7th/cmp-cmdline')

    use('hrsh7th/cmp-nvim-lsp')
    use('hrsh7th/cmp-vsnip')
    use('hrsh7th/vim-vsnip')
    use ("rafamadriz/friendly-snippets")
    --icons for Autocompletion
    use('onsails/lspkind.nvim')


    use('mfussenegger/nvim-jdtls')
    use('Pocco81/auto-save.nvim')

    -- MARKDOWN
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- Status Lne
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    --checkstyle
    use('jose-elias-alvarez/null-ls.nvim')
--    use('mfussenegger/nvim-lint')
    use("ray-x/lsp_signature.nvim")

    -- Database
--    use {
--        "tpope/vim-dadbod",
--        opt = true,
--        requires = {
--            "kristijanhusak/vim-dadbod-ui",
--            "kristijanhusak/vim-dadbod-completion",
--        },
--        config = function()
--            require("config.dadbod").setup()
--        end,
--        cmd = { "DBUIToggle", "DBUI", "DBUIAddConnection", "DBUIFindBuffer", "DBUIRenameBuffer", "DBUILastQueryInfo" },
--    }
end)
