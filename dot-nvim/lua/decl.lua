-- Currently we take any node that could represent some node (e. g. identifiers) and search for any node that matches expected type and the identifier
-- Possibly could be expanded with scope awareness to a certain degree (especially useful in the case of variables)
-- The first degree of scope awareness would be file scope, differentiating between global nodes and nodes in the currently opened buffer

-- @NEXT handle type scopes

local M = {}
local filetype_to_languagehandler = { }

filetype_to_languagehandler['cs'] = {
  language = 'c_sharp',
  -- Scopes provide for a node (use) and a node is covered by scopes (declaration)
  -- @INCOMPLETE handle nested qualified names - Foo.Bar etc.
  providing_scopes_query = '(using_directive (identifier) @target)',
  -- @INCOMPLETE support other scopes
  -- @INCOMPLETE handle classic namespaces with brackets
  covering_scope_query = '(file_scoped_namespace_declaration (identifier) @target)',
  get_query = function (selected_node)
      local query_string
      local parent_type = selected_node:parent():type()
      local type_node = selected_node:parent():field('type')[1]
      if type_node == selected_node or parent_type == 'base_list' or parent_type == 'generic_name' then
        query_string = [[([
          (class_declaration (identifier) @target)
          (interface_declaration (identifier) @target)
          (struct_declaration (identifier) @target)
          (enum_declaration (identifier) @target)
          (record_declaration (identifier) @target)
          (record_struct_declaration (identifier) @target)
          (class_declaration (base_list (identifier) @target))
          (interface_declaration (base_list (identifier) @target))
          (struct_declaration (base_list (identifier) @target))
        ])]]
      elseif parent_type == "member_access_expression" then
        local name_node = selected_node:parent():field('name')[1]
        if name_node == selected_node then
          query_string = [[([
            (property_declaration (identifier) @target)
            (field_declaration (variable_declaration (variable_declarator (identifier) @target)))
            (method_declaration (identifier) @target)
            (enum_member_declaration (identifier) @target)
            (record_declaration (parameter_list (parameter name: (identifier) @target)))
          ])]]
        else
          query_string = [[([
            (property_declaration (identifier) @target)
            (variable_declaration (variable_declarator (identifier) @target))
            (class_declaration (identifier) @target)
            (enum_declaration (identifier) @target)
          ])]]
        end
      elseif selected_node:type() == 'identifier' then
        query_string = [[([
          (property_declaration (identifier) @target)
          (variable_declaration (variable_declarator (identifier) @target))
          (method_declaration (identifier) @target)
          (parameter_list (parameter name: (identifier) @target))
          (local_function_statement name: (identifier) @target)
        ])]]
      end
      return query_string
    end,
}

filetype_to_languagehandler['lua'] = {
  language = 'lua',
  get_query = function (selected_node)
      local query_string
      local parent_type = selected_node:parent():type()
      local parent_parent_type = selected_node:parent():parent():type()
      if parent_type == 'dot_index_expression' and parent_parent_type == 'function_call' then
        query_string = '(function_declaration (identifier) @target)'
      elseif parent_type == 'function_call' then
        query_string = '(function_declaration (identifier) @target)'
      end

      return query_string
    end,
}

-- @IMPROVEMENT consider renaming, it doesn't go anywhere - it finds. Maybe find_implementations?
-- @CLEANUP start separating this into blocks
function M.go_to()
  local results = {}

  lang_handler = filetype_to_languagehandler[vim.bo.filetype]
  -- @INCOMPLETE provide error message
  if not lang_handler then return end

  local language = lang_handler.language

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]
  local curr_parser = vim.treesitter.get_parser(bufnr, language)
  local selected_node = curr_parser:named_node_for_range({ row, col, row, col })
  local selected_node_text = vim.treesitter.query.get_node_text(selected_node, bufnr)

  local query_string = lang_handler.get_query(selected_node)
  if not query_string then return results end

  local curr_root = curr_parser:tree_for_range({ row, col, row, col }):root()
  local providing_scopes = {}
  local query = vim.treesitter.parse_query(language, lang_handler.providing_scopes_query)
  local matches = query:iter_captures(curr_root, bufnr, 0, -1)
  for id, node, metadata in matches do
    providing_scopes[vim.treesitter.query.get_node_text(node, bufnr)] = true
  end

  local rgcmd = "rg --vimgrep --no-heading " .. vim.fn.shellescape(selected_node_text)

  -- Since we iterate over all declarations in a file, we don't need to include any file more than once.
  local filenames = {}
  for line in io.popen(rgcmd):lines() do
    local filename = string.match(line, '(.-):.*')
    filenames[filename] = true
  end

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

      local covering_scope_query = vim.treesitter.parse_query(language, lang_handler.covering_scope_query)
      local _, node, _ = covering_scope_query:iter_captures(root, file_content, 0, -1)()
      local covering_scope = vim.treesitter.query.get_node_text(node, file_content)

      if providing_scopes[covering_scope] then
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
      end
    end)

    ::continue::
  end

  return results
end

return M
