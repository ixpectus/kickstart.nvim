--- Формирование payload для AI-промпта.

local M = {}

local storage = require 'my_plugins.prompt_builder.storage'

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

--- Saves the current visual selection (with line numbers) and a user-provided
--- prompt to the system clipboard so it can be forwarded to any AI agent.
---
--- @param from? number start line (defaults to visual mark)
--- @param to? number end line (defaults to visual mark)
function M.save_prompt_to_clipboard(from, to)
  -- Accept range from the Ex command; fall back to marks for direct Lua calls.
  from = from or vim.fn.line "'<"
  to = to or vim.fn.line "'>"
  if from == 0 then
    from = 1
  end
  if to == 0 then
    to = vim.fn.line '$'
  end
  if from > to then
    from, to = to, from
  end

  local fname = vim.fn.expand '%:p'

  -- Build the text block (with line numbers).
  local selected_text = M.format_lines_with_numbers(from, to)

  -- Prompt the user for an instruction / prompt.
  local prompt = vim.fn.input('Prompt: ', '')
  if prompt == '' then
    vim.notify('SavePromptToClipboard: empty prompt cancelled', vim.log.levels.INFO)
    return
  end

  -- Compose the full payload.
  local payload = M.build_prompt_payload(fname, from, to, selected_text, prompt)

  -- Save to the system clipboard (+ register).
  vim.fn.setreg('+', payload)

  -- Log to persistent file.
  storage.log_prompt_to_file(fname, from, to, selected_text, prompt)
end

return M
