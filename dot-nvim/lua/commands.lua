local M = {}

local fzf = require('fzf').fzf
local action = require('fzf.actions').action

local function files(command)
  coroutine.wrap(function ()
    local preview = 'ash -c ' .. vim.fn.shellescape('bat --color never -- \"$0\"') .. ' {}'
    local choices = fzf(command, ("--ansi --preview=%s --expect=ctrl-v,ctrl-h"):format(vim.fn.shellescape(preview)))
    if not choices then return end

    local vimcmd
    if choices[1] == "ctrl-v" then
      vimcmd = "vnew"
    elseif choices[1] == "ctrl-h" then
      vimcmd = "new"
    else
      vimcmd = "e"
    end

    vim.cmd(vimcmd .. " " .. vim.fn.fnameescape(choices[2])) end)()
end

-- @TODO implement scrolling
local preview_action = action(function (lines, fzf_lines)
  local filename, row = string.match(lines[1], '(.-):(%d+):.*')

  fzf_lines = tonumber(fzf_lines)
  local line_start = math.floor(row - (fzf_lines / 2))
  if line_start < 1 then line_start = 1 end
  local line_end = math.floor(row + (fzf_lines / 2)) - 1

  local cmd = "bat --style=numbers --color always " .. vim.fn.shellescape(filename) ..
    " --theme 1337 " ..
    " --highlight-line " .. tostring(row) ..
    " --line-range " .. tostring(line_start) .. ":" .. tostring(line_end)
  return vim.fn.system(cmd)
end)

local function grep(pattern)
  coroutine.wrap(function ()
    -- @TODO Handle empty result set
    local rgcmd = "rg --vimgrep --no-heading " ..
      "--color ansi " ..vim.fn.shellescape(pattern)
    local choices = fzf(rgcmd, "--ansi --expect=ctrl-v,ctrl-h " .. "--preview " .. preview_action)
    if not choices then return end

    local vimcmd
    if choices[1] == "ctrl-v" then
      vimcmd = "vnew"
    elseif choices[1] == "ctrl-h" then
      vimcmd = "new"
    else
      vimcmd = "e"
    end

    local filename, row, col = string.match(choices[2], '(.-):(%d+):(%d+):.*')
    vim.cmd(vimcmd .. " ".. vim.fn.fnameescape(filename))
    vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(col) - 1 })
  end)()
end

local function grep_operator()
  local existing_func = vim.go.operatorfunc
  _G.op_grep = function ()
    local m_start = vim.api.nvim_buf_get_mark(0, '[')
    local m_end = vim.api.nvim_buf_get_mark(0, ']')
    local pattern = vim.api.nvim_buf_get_text(0, m_start[1] - 1, m_start[2], m_end[1] - 1, m_end[2] + 1, {})

    -- we don't do multiline rg, get only first line
    grep(pattern[1])

    vim.go.operatorfunc = existing_func
    _G.op_grep = nil
  end

  vim.go.operatorfunc = 'v:lua.op_grep'
  vim.api.nvim_feedkeys('g@', 'n', false)
end

M.files = files
M.grep = grep
M.grep_operator = grep_operator
M.go_to = go_to
return M
