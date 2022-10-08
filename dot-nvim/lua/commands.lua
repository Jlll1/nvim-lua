local M = {}

local fzf = require('fzf').fzf
local action = require('fzf.actions').action

local function files(command)
  coroutine.wrap(function ()
    local preview = 'ash -c ' .. vim.fn.shellescape('bat --color never -- \"$0\"') .. ' {}'
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
  local preview_action = action(function (lines, fzf_lines)
    local filename, row = string.match(lines[1], '(.-):(%d+):.*')

    fzf_lines = tonumber(fzf_lines)
    local line_start = math.floor(row - (fzf_lines / 2))
    if line_start < 1 then line_start = 1 end
    local line_end = math.floor(row + (fzf_lines / 2)) - 1

    local cmd = "bat --style=numbers --color always " .. vim.fn.shellescape(filename) ..
      " --highlight-line " .. tostring(row) ..
      " --line-range " .. tostring(line_start) .. ":" .. tostring(line_end)
    return vim.fn.system(cmd)
  end)

  coroutine.wrap(function ()
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

    local filename = string.match(choices[2], "(.-):")
    vim.cmd(vimcmd .. " ".. vim.fn.fnameescape(filename))
  end)()
end

M.files = files
M.grep = grep
return M
