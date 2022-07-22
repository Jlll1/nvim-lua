local function keymap(m, k, cmd)
  local opts = { silent = true }
  vim.keymap.set(m, k, cmd, opts)
end

local M = {}
-- [[ KEYMAPS ]]
-- Window Navigation
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

-- Indent
keymap("v", "<S-Tab>", "<gv")
keymap("v", "<Tab>", ">gv")
keymap("n", "<S-Tab>", "<<")
keymap("n", "<Tab>", ">>")

-- FTerm
  -- toggle terminal
keymap('t', '<Esc>', '<C-\\><C-n>')
keymap('t', '<C-n>', '<cmd>lua require("FTerm").toggle()<CR>')
keymap('n', '<C-n>', '<cmd>lua require("FTerm").toggle()<cr>')

-- FzfLua
  -- list files
keymap('n', '<C-p>', '<cmd>FzfLua files<cr>')
  -- list open buffers
keymap('n', '<C-b>', '<cmd>FzfLua buffers<cr>')
  -- list keymaps
keymap('n', '<F1>', '<cmd>FzfLua keymaps<cr>')
  -- list code actions
keymap('n', '<leader>a', '<cmd>FzfLua lsp_code_actions<cr>')
  -- list implementations 
keymap('n', '<leader>i', '<cmd>FzfLua lsp_implementations<cr>')
  -- list git commits for current file
keymap('n', '<leader>h', '<cmd>FzfLua git_bcommits<cr>')
  -- list git commits for project
keymap('n', '<leader>H', '<cmd>FzfLua git_commits<cr>')

-- [[ CMP KEYMAPS ]]
function M.cmp_keymaps(cmp)
  return cmp.mapping.preset.insert {
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
  }
end

-- [[ LSP KEYMAPS ]]
function M.on_attach(bufnr)
  local function bufmap(m, k, cmd)
    local opts = { noremap=true, silent=true }
    vim.api.nvim_buf_set_keymap(bufnr, m, k, cmd, opts)
  end

  -- jump to the definition
  bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
  -- jump to the declaration
  bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
  -- rename all references
  bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')
  -- go to next diagnostic
  bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  -- go to previous diagnostic
  bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
end
return M
