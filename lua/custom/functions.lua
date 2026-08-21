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
  return require('custom.ai_prompt').SendSelectionToAgent(from, to)
end

function ClearPromptLog()
  return require('custom.ai_prompt').ClearPromptLog()
end

--- Send visual selection as a command to the Pi agent via herdr.
--- Calls SendSelectionToAgent, reads the clipboard, then sends to Pi.
--- @param opts? table { skip_status_check? boolean, tab_id? string }
function SendCommandAndSelectionToPi(opts)
  opts = opts or {}

  -- 1. Запомнить содержимое буфера обмена до вызова SendSelectionToAgent.
  local before = vim.fn.getreg '+'

  -- 2. Вызвать SendSelectionToAgent (спрашивает prompt ОДИН РАЗ, кладёт в буфер)
  require('custom.ai_prompt').SendSelectionToAgent()

  -- 3. Прочитать содержимое буфера обмена после.
  local after = vim.fn.getreg '+'

  -- 4. Если содержимое не изменилось — ничего не отправляем.
  if before == after then
    return
  end

  -- 5. Отправить через SendCommandToPi.
  require('custom.herdr').SendCommandToPi(after, opts)
end

--- Перезапустить агент Pi.
function RestartPi()
  require('custom.herdr').RestartPi()
end

return {
  GetProjectRoot = GetProjectRoot,
  SendSelectionToAgent = SendSelectionToAgent,
  ClearPromptLog = ClearPromptLog,
  SendCommandAndSelectionToPi = SendCommandAndSelectionToPi,
  RestartPi = RestartPi,
}
