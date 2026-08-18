--- Get the path to the persistent prompt log file.
function GetPromptLogPath()
  return vim.fn.stdpath 'data' .. '/prompts.log'
end

--- Append a prompt entry to the persistent log file.
local function LogPromptToFile(fname, from, to, selected_text, prompt)
  local timestamp = vim.fn.strftime '%Y-%m-%d %H:%M:%S'
  local entry = string.format(
    '--- [%s] ---\nFile: %s\nLines: %d-%d\n\n%s\n\nPrompt: %s\n\n',
    timestamp,
    fname,
    from,
    to,
    selected_text,
    prompt
  )
  local f = io.open(GetPromptLogPath(), 'a')
if f then
    f:write(entry)
    f:close()
  else
    vim.notify('Failed to write to prompt log', vim.log.levels.ERROR)
  end
end

--- Clear the persistent prompt log file.
function ClearPromptLog()
  local f = io.open(GetPromptLogPath(), 'w')
  if f then
    f:close()
  end
  vim.notify('Prompt log cleared', vim.log.levels.INFO)
end

function GetProjectRoot()
  local root = vim.fn.finddir(('.git' .. '/..'), (vim.fn.expand '%:p:h' .. ';'))
  if root then
    return root
  end
  return vim.fn.expand '%:p:h'
end

--- Sends the current visual selection (with line numbers) and a user-provided
--- prompt to the system clipboard so it can be forwarded to any AI agent.
---
--- Usage in Neovim:
---   :SendSelectionToAgent
---
--- Or from another Lua module / keymap:
---   require('custom.functions').SendSelectionToAgent()
function SendSelectionToAgent(from, to)
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
  local lines = {}
  for i = from, to do
    local txt = vim.fn.getline(i)
    table.insert(lines, string.format('%d: %s', i, txt))
  end

  local selected_text = table.concat(lines, '\n')

  -- Prompt the user for an instruction / prompt.
  local prompt = vim.fn.input('Prompt: ', '')
  if prompt == '' then
    vim.notify('SendSelectionToAgent: empty prompt cancelled', vim.log.levels.INFO)
    return
  end

  -- Compose the full payload.
  local payload = string.format(
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

-- Save to the system clipboard (+ register).
  vim.fn.setreg('+', payload)

  -- Log to persistent file.
  LogPromptToFile(fname, from, to, selected_text, prompt)

  -- vim.notify(string.format('Sent %d:%d of %s to clipboard.', from, to, fname), vim.log.levels.INFO)
end

return {
  GetProjectRoot = GetProjectRoot,
  SendSelectionToAgent = SendSelectionToAgent,
  ClearPromptLog = ClearPromptLog,
  GetPromptLogPath = GetPromptLogPath,
}
