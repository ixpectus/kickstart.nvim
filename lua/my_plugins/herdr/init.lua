--- Точка входа модуля herdr. Экспортирует публичное API для работы с агентом Pi через Herdr.
---
---
--- ```lua
--- -- Отправить команду в найденное окно (tab_id из $HERDR_TAB_ID)
--- require('my_plugins.herdr').send_command_to_pi('Привет, покажи структуру проекта')
---
--- -- С явным pane_id и tab_id
--- require('my_plugins.herdr').send_command_to_pi('Сделай рефакторинг', { pane_id = 'wE:p1', tab_id = 'wE:t1' })
---
--- -- Без проверки статуса (поставить задачу в очередь, даже если агент working)
--- require('my_plugins.herdr').send_command_to_pi('Сделай рефакторинг', { pane_id = 'wH:pD', skip_status_check = true })
--- ```

local finder = require 'my_plugins.herdr.finder'
local sender = require 'my_plugins.herdr.sender'
local M = {}

--- Отправить промпт в окно Pi (проверка статуса — в sender.lua).
---
--- @param prompt string текст промпта для отправки
--- @param opts? table опции: { pane_id? string, tab_id? string, skip_status_check? boolean }
--- @return boolean true при успехе, false при ошибке
function M.send_command_to_pi(prompt, opts)
  opts = opts or {}
  local pane_id = opts.pane_id

  -- Если pane_id не передан — найти его через tab_id.
  if not pane_id or pane_id == '' then
    pane_id = finder.find_pi_pane(tab_id)
    if not pane_id then
      vim.schedule(function()
        vim.notify('herdr: pane not found for tab_id=' .. tostring(tab_id), vim.log.levels.ERROR)
      end)
      return false
    end
  end

  return sender.send_command_to_pi(pane_id, prompt, tab_id, opts)
end

--- Получить информацию об агенте Pi по tab_id.
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return table|nil таблица агента с полями pane_id, agent_status и т.д.
function M.get_agent_info(tab_id)
  return finder.get_agent_info(tab_id)
end

--- Проверить, свободен ли агент Pi (статус idle или done).
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return boolean
function M.is_agent_idle(tab_id)
  return finder.is_agent_idle(tab_id)
end

--- Получить текущий статус агента Pi.
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return string|nil статус агента ('idle', 'working', 'done')
function M.get_agent_status(tab_id)
  return finder.get_agent_status(tab_id)
end

--- Получить информацию об агенте Pi по pane_id.
---
--- @param pane_id string pane_id (например 'wE:p1')
--- @return table|nil таблица агента с полями pane_id, agent_status и т.д.
function M.get_agent_by_pane_id(pane_id)
  return finder.get_agent_by_pane_id(pane_id)
end

--- Перезапустить агент Pi: отправить /quit, дождаться остановки, запустить новую сессию.
--- Асинхронный — возвращает управление мгновенно.
---
--- @param opts? table опции: { pane_id? string, tab_id? string, quit_timeout? number }
function M.restart_pi(opts)
  opts = opts or {}
  local pane_id = opts.pane_id

  -- Если pane_id не передан — найти его через tab_id.
  if not pane_id or pane_id == '' then
    pane_id = finder.find_pi_pane(opts.tab_id)
    if not pane_id then
      vim.schedule(function()
        vim.notify('herdr: pane not found for restart', vim.log.levels.ERROR)
      end)
      return
    end

    require('my_plugins.herdr.restart').restart_pi(pane_id, opts)
  end
end

return M
