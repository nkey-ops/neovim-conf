vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 4
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.opt.clipboard = 'unnamedplus'
vim.opt.showtabline = 1

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.scrollback = 2000
vim.opt.cursorline = true

vim.opt.showmode = false

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', eol = "↵" }

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.shellcmdflag = "-ic"

-- vim.cmd("setlocal autoread | au CursorHold * checktime | call feedkeys('lh')")
