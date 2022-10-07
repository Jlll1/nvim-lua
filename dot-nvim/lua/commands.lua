local M = {}

local fzf = require('fzf').fzf

local function files(command)
  local preview = 'ash -c ' .. vim.fn.shellescape('bat --color never -- \"$0\"') .. ' {}'

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

M.files = files
return M
