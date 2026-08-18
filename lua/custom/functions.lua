local ai_prompt = require 'custom.ai_prompt'

--- Get the project root directory.
function GetProjectRoot()
  local root = vim.fn.finddir(('.git' .. '/..'), (vim.fn.expand '%:p:h' .. ';'))
  if root then
    return root
  end
  return vim.fn.expand '%:p:h'
end

--- Wrapper: send visual selection to agent (delegates to ai_prompt).
--- @see custom.ai_prompt.SendSelectionToAgent
function SendSelectionToAgent(from, to)
  return ai_prompt.SendSelectionToAgent(from, to)
end

--- Wrapper: clear the prompt log (delegates to ai_prompt).
--- @see custom.ai_prompt.ClearPromptLog
function ClearPromptLog()
  return ai_prompt.ClearPromptLog()
end

return {
  GetProjectRoot = GetProjectRoot,
  SendSelectionToAgent = SendSelectionToAgent,
  ClearPromptLog = ClearPromptLog,
}