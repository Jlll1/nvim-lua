local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.execute(
    '!git clone https://github.com/wbthomason/packer.nvim' .. install_path
  )
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- [[ LSP & LANGUAGE SUPPORT ]]
  use "neovim/nvim-lspconfig"
  use 'williamboman/mason.nvim'
  use {
    'williamboman/mason-lspconfig.nvim',
    requires = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
    }
  }
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  }
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    }
  }
  use {
    'tami5/lspsaga.nvim',
    requires = {'neovim/nvim-lspconfig'}
  }
  use 'ionide/Ionide-vim' -- F# syntax highlighting

  -- [[ THEMES ]]
  use 'savq/melange'

  -- [[ OTHER ]]
  use 'ibhagwan/fzf-lua'
  use 'vim-scripts/auto-pairs-gentle' -- Pair brackets, quotes etc.
  use 'lukas-reineke/indent-blankline.nvim' -- Display indentation guides for all lines
  use 'numToStr/FTerm.nvim' -- Floating Terminal
  use 'ray-x/lsp_signature.nvim' -- Display function signature tooltip
  use 'nvim-lualine/lualine.nvim' -- Custom status line
end)


