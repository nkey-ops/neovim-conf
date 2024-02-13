local dir = vim.fn.glob("~/.local/share/nvim/site/pack/packer/start/vim-surround")
vim.cmd("runtime! " .. dir ..  '/*.vim' )
