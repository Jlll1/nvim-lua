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

-- [[ NeoZoom ]]
require('neo-zoom').setup({
  left_ratio = 0.1,
  top_ratio = 0.05,
  width_ratio = 0.8,
  height_ratio = 0.8,
})
keymap.set('n', '<Tab>', ':NeoZoomToggle<cr>', { noremap = true })

-- [[ split.nvim ]]
keymap.set('n', 'gso', ':<c-u>SplitOn<space>', { noremap = true })
keymap.set('n', 'gsb', ':<c-u>SplitBefore<space>', { noremap = true })
keymap.set('n', 'gss', ':<c-u>SplitAfter<space>', { noremap = true })

-- [[ Commands ]]
keymap.set('n', 'fp',  '<cmd>lua require("commands").files("fd --color always -t f -L")<cr>', { noremap = true, silent = true })

vim.api.nvim_create_user_command(
  'Rg',
  function (opts)
    require('commands').grep(opts.args)
  end,
  { nargs = 1 })
keymap.set('n', 'fg', ':<c-u>Rg<space>', { noremap = true })

keymap.set('n', 'fi', '<cmd>lua require("commands").grep_operator()<cr>', { noremap = true })

keymap.set('n', 'gd', '<cmd>lua require("commands").go_to()<cr>', { noremap = true })

-- [[ Core Keymaps ]]
keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })
keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })
