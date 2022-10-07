local opt = vim.opt
local cmd = vim.cmd
local g = vim.g

g.mapleader        = " "
g.nobackup         = true
g.noswapfile       = true
opt.syntax         = 'on'
opt.completeopt    = {'menu', 'menuone', 'noselect'}

opt.termguicolors  = true
opt.background     = "light"

opt.number         = true
opt.relativenumber = true
opt.list           = true
opt.cursorline     = true

opt.encoding       = 'utf8'
opt.fileencoding   = 'utf8'

opt.ignorecase     = true
opt.smartcase      = true
opt.incsearch      = true
opt.hlsearch       = true

opt.expandtab      = true
opt.tabstop        = 2
opt.shiftwidth     = 2

local colorscheme = "monochromenote"
pcall(vim.cmd, "colorscheme " .. colorscheme)

vim.keymap.set('n', 'fp',  '<cmd>lua require("commands").files("fd --color always -t f -L")<cr>', { noremap = true, silent = true })

vim.keymap.set('n', 'fp', '<cmd>lua require("fzf-lua").files()<cr>', { noremap = true, silent = true })
vim.keymap.set('n', 'fg', '<cmd>lua require("fzf-lua").live_grep()<cr>', { noremap = true, silent = true })

