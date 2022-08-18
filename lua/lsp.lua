local api = vim.api
local lsp = vim.lsp
local g   = vim.g

local lspconfig = require('lspconfig')

local servers = {
  "angularls",      -- Angular
  "bashls",         -- Bash
  "clangd",         -- C
  "csharp_ls",      -- C#
  "fsautocomplete", -- F#
  "gopls",          -- Go
  "jsonls",         -- JSON
  "sumneko_lua",    -- Lua
  "svelte",         -- Svelte
  "tsserver",       -- TS/JS
}

require('mason').setup()
require('mason-lspconfig').setup({
  servers,
  ensure_installed = servers,
  automatic_installation = true,
})

local on_attach = function(_, bufnr)
  local function bufopt(...)
    api.nvim_buf_set_option(bufnr, ...)
  end
  bufopt('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Import LSP Keymaps from keymaps.lua
  require('keymaps').on_attach(bufnr)
end

local capabilities = lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local opts = {
  on_attach = on_attach,
  flags = {debounce_text_changes = 150},
  capabilities = capabilities,
}

for _, server in ipairs(servers)
do
  lspconfig[server].setup(opts)
end
