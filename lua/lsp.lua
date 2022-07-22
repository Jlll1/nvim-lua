local api = vim.api
local lsp = vim.lsp
local g   = vim.g

require('lspconfig')
local lsp_installer = require('nvim-lsp-installer')

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

for _, name in pairs(servers) do
  local found, server = lsp_installer.get_server(name)
  if found and not server:is_installed() then
    print("Installing " .. name)
    server:install()
  end
end

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

lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = on_attach,
    flags = {debounce_text_changes = 150},
    capabilities = capabilities,
  }

  -- And set up the server with our configuration!
  server:setup(opts)
end)
