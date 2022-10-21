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

-- [[ Treesitter ]]
-- Don't pull parsers from github, instead use local submodules
  local pcfg = require('nvim-treesitter.parsers').get_parser_configs()
  pcfg.c.install_info.url           = '/root/.config/nvim/treesitter-parsers/tree-sitter-c'
  pcfg.cpp.install_info.url         = '/root/.config/nvim/treesitter-parsers/tree-sitter-cpp'
  pcfg.c_sharp.install_info.url     = '/root/.config/nvim/treesitter-parsers/tree-sitter-c-sharp'
  pcfg.go.install_info.url          = '/root/.config/nvim/treesitter-parsers/tree-sitter-go'
  pcfg.html.install_info.url        = '/root/.config/nvim/treesitter-parsers/tree-sitter-html'
  pcfg.lua.install_info.url         = '/root/.config/nvim/treesitter-parsers/tree-sitter-lua'

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'c', 'cpp', 'c_sharp', 'go', 'html', 'lua' },
  sync_install = true,
  auto_install = false,
  payground = { enable = true },
})

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
keymap.set('n', 'ggg', '<cmd>lua require("commands").go_to_declaration()<cr>', { noremap = true })
