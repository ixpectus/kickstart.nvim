--- Формирование payload для AI-промпта.

local M = {}

--- Build line numbers text block.
--- @param from number start line (1-indexed)
--- @param to number end line (1-indexed)
--- @return string text with line numbers
function M.format_lines_with_numbers(from, to)
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
function M.build_prompt_payload(fname, from, to, selected_text, prompt)
  local parts = {
    'File: ' .. fname,
    string.format('Lines: %d-%d', from, to),
    selected_text,
  }
  if prompt ~= '' then
    table.insert(parts, 'Prompt: ' .. prompt)
  end
  return table.concat(parts, '\n\n')
end

return M
