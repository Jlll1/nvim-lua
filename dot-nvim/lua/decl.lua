local fzf = require('fzf').fzf

-- @CLEANUP copy-pasted from commands.lua
local preview_action = require('fzf.actions').action(function (lines, fzf_lines)
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

local function go_to_declaration()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]
  local curr_parser = vim.treesitter.get_parser(bufnr, 'c_sharp')
  local selected_node = curr_parser:named_node_for_range({ row, col, row, col })
  local selected_node_text = vim.treesitter.query.get_node_text(selected_node, bufnr)

  -- @INCOMPLETE structs
  local query_string
  local parent_type = selected_node:parent():type()
  if parent_type == "member_access_expression" then
    if selected_node:parent():parent():type() == "invocation_expression" then
      query_string = "(method_declaration (identifier) @target)"
    else
      query_string = "([(property_declaration (identifier) @target) (field_declaration (variable_declaration (variable_declarator (identifier) @target)))])"
    end
  elseif parent_type == 'property_declaration' then
    local type_node = selected_node:parent():field('type')[1]
    if type_node ~= selected_node then return end
    query_string = "([(class_declaration (identifier) @target) (interface_declaration (identifier) @target) (class_declaration (base_list (identifier) @target))])"
  elseif parent_type == 'base_list' then
    query_string = "([(class_declaration (identifier) @target) (interface_declaration (identifier) @target)])"
  elseif parent_type == 'object_creation_expression' then
    query_string = "(class_declaration (identifier) @target)"
  elseif parent_type == 'variable_declaration' then
    query_string = "(class_declaration (identifier) @target)"
  else
    return
  end

  -- Convert file_extension to treesitter language
  local language = vim.bo.filetype
  if language == 'cs' then
    language = 'c_sharp'
  end

  local rgcmd = "rg --vimgrep --no-heading " .. vim.fn.shellescape(selected_node_text)

  -- Since we iterate over all declarations in a file, we don't need to include any file more than once.
  local filenames = {}
  for line in io.popen(rgcmd):lines() do
    local filename = string.match(line, '(.-):.*')
    filenames[filename] = true
  end

  local results = {}
  for filename, _ in pairs(filenames) do
    -- The declaration must be in a language that matches the current one.
    local file_extension = string.match(filename, '.*%.(.*)')
    if file_extension ~= vim.bo.filetype then goto continue end

    local file = io.open(filename, "r")
    local file_content = file:read("*all")
    file:close()

    local parser = vim.treesitter.get_string_parser(file_content, language)
    parser:parse()

    parser:for_each_tree(function (tstree, tree)
      local root = tstree:root()

      local query = vim.treesitter.parse_query(language, query_string)
      local matches = query:iter_captures(root, file_content, 0, -1)
      for id, node, metadata in matches do
        local node_text = vim.treesitter.query.get_node_text(node, file_content)
        -- @IMPROVEMENT can matching be done with a query?
        if node_text == selected_node_text then
          local row, col, _ = node:start()
          results[#results + 1] = { filename = filename, row = row + 1, col = col }
        end
      end
    end)

    ::continue::
  end

  if #results == 1 then
    vim.cmd("e " .. vim.fn.fnameescape(results[1].filename))
    vim.api.nvim_win_set_cursor(0, { tonumber(results[1].row), tonumber(results[1].col) })
  elseif #results > 1 then
    coroutine.wrap(function ()
      local str_results = {}
      for _, result in ipairs(results) do
        str_results[#str_results + 1] = result.filename .. ":" .. result.row .. ":" .. result.col
      end
      local choices = fzf(str_results, "--ansi --expect=ctrl-v,ctrl-h " .. "--preview " .. preview_action)
      if not choices then return end

      local vimcmd
      if choices[1] == "ctrl-v" then
        vimcmd = "vnew"
      elseif choices[1] == "ctrl-h" then
        vimcmd = "new"
      else
        vimcmd = "e"
      end
    end)()
  end
end

return {
  go_to_declaration = go_to_declaration
}
