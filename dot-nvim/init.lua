local api = vim.api
local opt = vim.opt
local cmd = vim.cmd
local keymap = vim.keymap
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

-- [[ Colorscheme ]]
local colorscheme = 'monochromenote'
pcall(vim.cmd, 'colorscheme ' .. colorscheme)

-- [[ Keymaps ]]
keymap.set('n', 'fp',  '<cmd>lua require("commands").files("fd --color always -t f -L")<cr>', { noremap = true, silent = true })

vim.api.nvim_create_user_command(
  'Rg',
  function (opts)
    require('commands').grep(opts.args)
  end,
  { nargs = 1 })
keymap.set('n', 'fg', ':<c-u>Rg<space>', { noremap = true })

keymap.set('n', 'fi', '<cmd>lua require("commands").grep_operator()<cr>', { noremap = true })
keymap.set('n', 'ggg', '<cmd>lua require("commands").go_to()<cr>', { noremap = true })
