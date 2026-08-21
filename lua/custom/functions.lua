--- Get the project root directory.
function get_project_root()
  local root = vim.fn.finddir(('.git' .. '/..'), (vim.fn.expand '%:p:h' .. ';'))
  if root then
    return root
  end
  return vim.fn.expand '%:p:h'
end

--- Wrapper: send visual selection to agent (delegates to ai_prompt).
--- @see custom.ai_prompt.send_selection_to_agent
function send_selection_to_agent(from, to)
  return require('custom.ai_prompt').send_selection_to_agent(from, to)
end

function clear_prompt_log()
  return require('custom.ai_prompt').clear_prompt_log()
end

--- Send visual selection as a command to the Pi agent via herdr.
--- Calls SendSelectionToAgent, reads the clipboard, then sends to Pi.
--- @param opts? table { skip_status_check? boolean, tab_id? string }
function send_command_and_selection_to_pi(opts)
  opts = opts or {}

  -- 1. Запомнить содержимое буфера обмена до вызова SendSelectionToAgent.
  local before = vim.fn.getreg '+'

  -- 2. Вызвать SendSelectionToAgent (спрашивает prompt ОДИН РАЗ, кладёт в буфер)
  require('custom.ai_prompt').send_selection_to_agent()

  -- 3. Прочитать содержимое буфера обмена после.
  local after = vim.fn.getreg '+'

  -- 4. Если содержимое не изменилось — ничего не отправляем.
  if before == after then
    return
  end

  -- 5. Отправить через SendCommandToPi.
  require('custom.herdr').send_command_to_pi(after, opts)
end

--- Перезапустить агент Pi.
function restart_pi()
  require('custom.herdr').restart_pi()
end

return {
  get_project_root = get_project_root,
  send_selection_to_agent = send_selection_to_agent,
  clear_prompt_log = clear_prompt_log,
  send_command_and_selection_to_pi = send_command_and_selection_to_pi,
  restart_pi = restart_pi,
}
