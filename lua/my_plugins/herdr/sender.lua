--- Отправка текста и клавиш в окно Pi через `herdr pane`.
---
local finder = require 'my_plugins.herdr.finder'
local M = {}

--- Выполнить одну команду `herdr pane ...`.
---
--- @param pane_id string pane_id (например 'wE:p1')
--- @param subcommand string подкоманда (например 'send-text', 'send-keys')
--- @param args string аргумент (текст или ключ)
--- @return boolean
local function send_pane_command(pane_id, subcommand, args)
  local cmd = string.format('herdr pane %s %s %s', subcommand, pane_id, vim.fn.shellescape(args))
  vim.fn.system(cmd)
  return vim.v.shell_error == 0
end

--- Отправить текст в окно и нажать Enter.
---
--- @param pane_id string pane_id окна (например 'wE:p1')
--- @param prompt string текст промпта для отправки
--- @return boolean true при успехе, false при ошибке
function M.send_to_pane(pane_id, prompt)
  if not pane_id or pane_id == '' then
    vim.schedule(function()
      vim.notify('herdr: pane_id is empty', vim.log.levels.ERROR)
    end)
    return false
  end

  if not prompt or prompt == '' then
    vim.schedule(function()
      vim.notify('herdr: prompt is empty', vim.log.levels.ERROR)
    end)
    return false
  end

  -- Отправляем текст.
  local ok_text = send_pane_command(pane_id, 'send-text', prompt)

  -- Нажимаем Enter.
  local ok_enter = send_pane_command(pane_id, 'send-keys', 'enter')

  if ok_text and ok_enter then
    vim.schedule(function()
      vim.notify('herdr: command sent to ' .. pane_id, vim.log.levels.INFO)
    end)
    return true
  else
    vim.schedule(function()
      vim.notify('herdr: failed to send command to ' .. pane_id, vim.log.levels.ERROR)
    end)
    return false
  end
end

--- Отправить промпт в окно Pi через herdr pane.
---
--- @param pane_id string pane_id окна (например 'wE:p1')
--- @param prompt string текст промпта для отправки
--- @param tab_id? string явный tab_id (для проверки статуса)
--- @param opts? table опции: { skip_status_check? boolean }
--- @return boolean true при успехе, false при ошибке
function M.send_command_to_pi(pane_id, prompt, tab_id, opts)
  opts = opts or {}
  if not pane_id or pane_id == '' then
    vim.schedule(function()
      vim.notify('herdr: pane_id is empty', vim.log.levels.ERROR)
    end)
    return false
  end

  if not prompt or prompt == '' then
    vim.schedule(function()
      vim.notify('herdr: prompt is empty', vim.log.levels.ERROR)
    end)
    return false
  end

  -- Проверить статус агента перед отправкой.
  local skip = opts.skip_status_check or false
  if not skip and tab_id then
    local agent = finder.get_agent_info(tab_id)
    if agent and (agent.agent_status == 'working') then
      vim.schedule(function()
        vim.notify('herdr: agent is currently working (status: ' .. agent.agent_status .. '), skipping send', vim.log.levels.WARN)
      end)
      return false
    end
  end

  return M.send_to_pane(pane_id, prompt)
end

return M
