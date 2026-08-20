--- Точка входа модуля herdr. Экспортирует публичное API для работы с агентом Pi через Herdr.
---
---
--- ```lua
--- -- Отправить команду в найденное окно (tab_id из $HERDR_TAB_ID)
--- require('custom.herdr').SendCommandToPi('Привет, покажи структуру проекта')
---
--- -- С явным pane_id и tab_id
--- require('custom.herdr').SendCommandToPi('Сделай рефакторинг', { pane_id = 'wE:p1', tab_id = 'wE:t1' })
---
--- -- Без проверки статуса (поставить задачу в очередь, даже если агент working)
--- require('custom.herdr').SendCommandToPi('Сделай рефакторинг', { pane_id = 'wH:pD', skip_status_check = true })
--- ```

local finder = require 'custom.herdr.finder'
local sender = require 'custom.herdr.sender'

local M = {}

--- Найти pane_id агента Pi в текущем workspace.
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return string|nil pane_id (например 'wE:p1'), или nil если не найден
function M.FindPiPane(tab_id)
  return finder.FindPiPane(tab_id)
end

--- Отправить промпт в окно Pi (проверка статуса — в sender.lua).
---
--- @param prompt string текст промпта для отправки
--- @param opts? table опции: { pane_id? string, tab_id? string, skip_status_check? boolean }
--- @return boolean true при успехе, false при ошибке
function M.SendCommandToPi(prompt, opts)
  opts = opts or {}
  local pane_id = opts.pane_id
  local tab_id = opts.tab_id

  -- Если pane_id не передан — найти его через tab_id.
  if not pane_id or pane_id == '' then
    pane_id = M.FindPiPane(tab_id)
    if not pane_id then
      vim.schedule(function()
        vim.notify('herdr: pane not found for tab_id=' .. tostring(tab_id), vim.log.levels.ERROR)
      end)
      return false
    end
  end

  return sender.SendCommandToPi(pane_id, prompt, tab_id, opts)
end

--- Получить информацию об агенте Pi по tab_id.
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return table|nil таблица агента с полями pane_id, agent_status и т.д.
function M.GetAgentInfo(tab_id)
  return finder.GetAgentInfo(tab_id)
end

--- Проверить, свободен ли агент Pi (статус idle или done).
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return boolean
function M.IsAgentIdle(tab_id)
  return finder.IsAgentIdle(tab_id)
end

--- Получить текущий статус агента Pi.
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return string|nil статус агента ('idle', 'working', 'done')
function M.GetAgentStatus(tab_id)
  return finder.GetAgentStatus(tab_id)
end

--- Получить информацию об агенте Pi по pane_id.
---
--- @param pane_id string pane_id (например 'wE:p1')
--- @return table|nil таблица агента с полями pane_id, agent_status и т.д.
function M.GetAgentByPaneId(pane_id)
  return finder.GetAgentByPaneId(pane_id)
end
return M