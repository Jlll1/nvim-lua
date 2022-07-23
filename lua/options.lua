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



-- [[ Indent-Blankline ]]
cmd([[
highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine
highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine
highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine
highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine
highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine
highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine
]])

require('indent_blankline').setup({
  char_highlight_list = {
    'IndentBlanklineIndent1',
    'IndentBlanklineIndent2',
    'IndentBlanklineIndent3',
    'IndentBlanklineIndent4',
    'IndentBlanklineIndent5',
    'IndentBlanklineIndent6',
  },
})

-- [[ LSP Signature ]]
require('lsp_signature').setup({
  doc_lines = 0,
  hint_enable = false,
})

-- [[ CMP ]]
local cmp = require('cmp')
cmp.setup({
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }),
  mapping = require('keymaps').cmp_keymaps(cmp),
})

-- [[ Lualine ]]
require('lualine').setup {
  options = {
    icons_enabled = false,
    components_separators = '',
    section_separators = '',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'diagnostics' },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { 'branch', 'diff' },
  }
}
