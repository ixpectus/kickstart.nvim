--- Формирование payload для AI-промпта.

local M = {}

--- Build line numbers text block.
--- @param from number start line (1-indexed)
--- @param to number end line (1-indexed)
--- @return string text with line numbers
function M.FormatLinesWithNumbers(from, to)
  local lines = {}
  for i = from, to do
    local txt = vim.fn.getline(i)
    table.insert(lines, string.format('%d: %s', i, txt))
  end
  return table.concat(lines, '\n')
end

--- Build the full payload string for forwarding to an AI agent.
--- @param fname string full file path
--- @param from number start line (1-indexed)
--- @param to number end line (1-indexed)
--- @param selected_text string text block with line numbers (from FormatLinesWithNumbers)
--- @param prompt string user instruction
--- @return string formatted payload
function M.BuildPromptPayload(fname, from, to, selected_text, prompt)
  return string.format(
    [[File: %s
Lines: %d-%d

%s

Prompt: %s]],
    fname,
    from,
    to,
    selected_text,
    prompt
  )
end

return M