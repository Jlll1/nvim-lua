local M = {}

local fzf = require('fzf').fzf

local preview = 'ash -c ' .. vim.fn.shellescape('bat --color never -- \"$0\"') .. ' {}'

local function files(command)
  coroutine.wrap(function ()
    local choices = fzf(command,
      ("--ansi --preview=%s --expect=ctrl-v,ctrl-h"):format(vim.fn.shellescape(preview)))
    if not choices then return end

    local vimcmd
    if choices[1] == "ctrl-v" then
      vimcmd = "vnew"
    elseif choices[1] == "ctrl-h" then
      vimcmd = "new"
    else
      vimcmd = "e"
    end

    vim.cmd(vimcmd .. " " .. vim.fn.fnameescape(choices[2]))
  end)()
end

local function grep(pattern)
  coroutine.wrap(function ()
    local rgcmd = 'rg --vimgrep --no-heading --color ansi ' .. vim.fn.shellescape(pattern)
    local choices = fzf(rgcmd,
      ("--ansi --preview=%s --expect=ctrl-v,ctrl-h"):format(vim.fn.shellescape(preview)))
    if not choices then return end

    local vimcmd
    if choices[1] == "ctrl-v" then
      vimcmd = "vnew"
    elseif choices[1] == "ctrl-h" then
      vimcmd = "new"
    else
      vimcmd = "e"
    end

    local filename = string.match(choices[2], '(.-):.*')
    vim.cmd(vimcmd .. " " .. vim.fn.fnameescape(filename))
  end)()
end

M.files = files
M.grep = grep
return M
