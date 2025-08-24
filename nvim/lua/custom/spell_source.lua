local M = {}

function M.get_completions(ctx, callback)
  local word = vim.fn.expand("<cword>")
  local suggestions = vim.fn.spellsuggest(word)

  local items = {}
  for _, suggestion in ipairs(suggestions) do
    table.insert(items, {
      label = suggestion,
      kind = vim.lsp.protocol.CompletionItemKind.Text,
    })
  end

  callback({ items = items })
end

return M
