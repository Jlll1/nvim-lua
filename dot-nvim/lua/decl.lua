-- @TODO this should handle types as well
-- @NEXT implement smart goto based on selected_node interpretation (method call, field access etc.) for C#
local function go_to_declaration()
  -- @INCOMPLETE This isn't exactly right, since we're not verifying whether the cursor is on the
  -- indexed indentifier or on the method identifier
  -- @IMPROVEMENT Reimplement get_node_at_cursor to remove treesiter-nvim dependency
  local selected_node = ts_utils.get_node_at_cursor()
  local selected_node_text = vim.treesitter.query.get_node_text(selected_node, vim.api.nvim_get_current_buf())

  -- @TODO is there a better way to do this?
  -- @INCOMPLETE @MORE_LANGS
  -- Convert file_extension to treesitter language
  local language = vim.bo.filetype
  if language == 'cs' then
    language = 'c_sharp'
  end

  -- Some languages don't have method declarations
  -- @INCOMPLETE @MORE_LANGS
  local query_string = '([(function_declaration (identifier) @target) (method_declaration (field_identifier) @target)])'
  if language == 'lua' then
    query_string = '(function_declaration (identifier) @target)'
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
