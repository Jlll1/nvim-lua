local opt = vim.opt
local cmd = vim.cmd
local g = vim.g

g.mapleader        = " "
g.nobackup         = true
g.noswapfile       = true
opt.syntax         = 'on'
opt.completeopt    = {'menu', 'menuone', 'noselect'}

opt.termguicolors  = true
opt.background     = "dark"

opt.number         = true
opt.relativenumber = true
opt.list           = true
opt.signcolumn     = 'yes'

opt.encoding       = 'utf8'
opt.fileencoding   = 'utf8'

opt.ignorecase     = true
opt.smartcase      = true
opt.incsearch      = true
opt.hlsearch       = true

opt.expandtab      = true
opt.tabstop        = 2
opt.shiftwidth     = 2

