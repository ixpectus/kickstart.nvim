--- Get the project root directory.
function get_project_root()
  local root = vim.fn.finddir(('.git' .. '/..'), (vim.fn.expand '%:p:h' .. ';'))
  if root then
    return root
  end
  return vim.fn.expand '%:p:h'
end

--- Send visual selection as a command to the Pi agent via herdr.
--- Calls SavePromptToClipboard, reads the clipboard, then sends to Pi.
--- @param opts? table { skip_status_check? boolean, tab_id? string }
function send_command_and_selection_to_pi(opts)
  opts = opts or {}

  -- 1. Запомнить содержимое буфера обмена до вызова SavePromptToClipboard.
  local before = vim.fn.getreg '+'

  -- 2. Вызвать SavePromptToClipboard (спрашивает prompt ОДИН РАЗ, кладёт в буфер)
  require('my_plugins.prompt_builder').save_prompt_to_clipboard()

  -- 3. Прочитать содержимое буфера обмена после.
  local after = vim.fn.getreg '+'

  -- 4. Если содержимое не изменилось — ничего не отправляем.
  if before == after then
    return
  end

  -- 5. Отправить через SendCommandToPi.
  require('my_plugins.herdr').send_command_to_pi(after, opts)
end

--- Wrapper: send visual selection to agent (delegates to prompt_builder).
--- @see my_plugins.prompt_builder.save_prompt_to_clipboard
function save_prompt_to_clipboard(from, to)
  return require('my_plugins.prompt_builder').save_prompt_to_clipboard(from, to)
end

function clear_prompt_log()
  return require('my_plugins.prompt_builder').clear_prompt_log()
end
--- Перезапустить агент Pi.
function restart_pi()
  require('my_plugins.herdr').restart_pi()
end

return {
  get_project_root = get_project_root,
  save_prompt_to_clipboard = save_prompt_to_clipboard,
  clear_prompt_log = clear_prompt_log,
  send_command_and_selection_to_pi = send_command_and_selection_to_pi,
  restart_pi = restart_pi,
}
