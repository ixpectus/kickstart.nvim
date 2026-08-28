--- Отправка выделенного кода и промпта в буфер обмена.

local storage = require 'custom.ai_prompt.storage'
local builder = require 'custom.ai_prompt.builder'

local M = {}

--- Sends the current visual selection (with line numbers) and a user-provided
--- prompt to the system clipboard so it can be forwarded to any AI agent.
---
--- @param from? number start line (defaults to visual mark)
--- @param to? number end line (defaults to visual mark)
function M.send_selection_to_agent(from, to)
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
  local selected_text = builder.format_lines_with_numbers(from, to)

  -- Prompt the user for an instruction / prompt.
  local prompt = vim.fn.input('Prompt: ', '')
  if prompt == '' then
    vim.notify('SendSelectionToAgent: empty prompt cancelled', vim.log.levels.INFO)
    return
  end

  -- Compose the full payload.
  local payload = builder.build_prompt_payload(fname, from, to, selected_text, prompt)

  -- Save to the system clipboard (+ register).
  vim.fn.setreg('+', payload)

  -- Log to persistent file.
  storage.log_prompt_to_file(fname, from, to, selected_text, prompt)
end

return M
