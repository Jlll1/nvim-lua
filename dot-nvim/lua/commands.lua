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

local ts_utils = require('nvim-treesitter.ts_utils')

-- @TODO this should handle types as well
local function go_to_declaration()
  -- @INCOMPLETE This isn't exactly right, since we're not verifying whether the cursor is on the
  -- indexed indentifier or on the method identifier
  local selected_node = ts_utils.get_node_at_cursor()
  local selected_node_text = vim.treesitter.query.get_node_text(selected_node, vim.api.nvim_get_current_buf())
  local rgcmd = "rg --vimgrep --no-heading " .. vim.fn.shellescape(selected_node_text)
  for line in io.popen(rgcmd):lines() do
    local filename = string.match(line, '(.-):.*')
    local file = io.open(filename, "r")
    local file_content = file:read("*all")
    file:close()

    local results = {}
    -- @INCOMPLETE handle multiple languages
    local parser = vim.treesitter.get_string_parser(file_content, "c_sharp")
    parser:parse()
    parser:for_each_tree(function (tstree, tree)
      local root = tstree:root()

      -- @INCOMPLETE this works only for method_declaration, handle function_declaration
      local query = vim.treesitter.parse_query("c_sharp", "(method_declaration (identifier) @method)")
      local matches = query:iter_captures(root, file_content, 0, -1)
      for id, node, metadata in matches do
        local node_text = vim.treesitter.query.get_node_text(node, file_content)
        if node_text == selected_node_text then
          results[#results + 1] = line
        end
      end
    end)

    if #results == 1 then
      local filename, row, col = string.match(results[1], '(.-):(%d+):(%d+):.*')
      vim.cmd("e " .. vim.fn.fnameescape(filename))
      vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(col) - 1 })
    elseif #results > 1 then
      coroutine.wrap(function ()
        local choices = fzf(results, "--ansi --expect=ctrl-v,ctrl-h " .. "--preview " .. preview_action)
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
  end
end

M.files = files
M.grep = grep
M.grep_operator = grep_operator
M.go_to_declaration = go_to_declaration
return M
