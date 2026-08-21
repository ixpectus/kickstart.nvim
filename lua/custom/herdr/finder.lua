--- Парсинг вывода `herdr agent list` и поиск окна Pi по tab_id.
---
local M = {}

--- Получить $HERDR_TAB_ID из окружения.
--- @return string|nil
local function get_tab_id()
  return os.getenv 'HERDR_TAB_ID'
end

--- Выполнить `herdr agent list` и распарсить JSON.
--- @return table|nil таблица агентов или nil при ошибке
local function fetch_agent_list()
  local ok, result = pcall(vim.fn.system, 'herdr agent list')
  if not ok then
    return nil
  end

  local raw = string.gsub(result, '^%s*(.-)%s*$', '%1')
  if raw == '' or raw:sub(1, 1) ~= '{' then
    return nil
  end

  -- vim.fn.json_decode принимает строку и возвращает Lua-таблицу.
  -- Ожидаемый формат: { result = { agents = { ... } } }
  local decoded, err = vim.fn.json_decode(raw)
  if type(decoded) ~= 'table' then
    vim.schedule(function()
      vim.notify('herdr: failed to parse agent list: ' .. tostring(err), vim.log.levels.WARN)
    end)
    return nil
  end

  return decoded
end

--- Найти pane_id агента Pi по tab_id.
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return string|nil pane_id (например 'wE:p1'), или nil если не найден
function M.FindPiPane(tab_id)
  tab_id = tab_id or get_tab_id()

  if not tab_id then
    vim.schedule(function()
      vim.notify('herdr: HERDR_TAB_ID not set. Pass tab_id explicitly or export HERDR_TAB_ID.', vim.log.levels.WARN)
    end)
    return nil
  end

  local data = fetch_agent_list()
  if not data or not data.result or not data.result.agents then
    vim.schedule(function()
      vim.notify('herdr: could not retrieve agent list', vim.log.levels.ERROR)
    end)
    return nil
  end

  local agents = data.result.agents

  for _, agent in ipairs(agents) do
    if agent.agent == 'pi' and agent.tab_id == tab_id then
      return agent.pane_id
    end
  end

  vim.schedule(function()
    vim.notify('herdr: no Pi agent found for tab_id=' .. tab_id, vim.log.levels.WARN)
  end)

  return nil
end

--- Получить информацию об агенте Pi по tab_id (возвращает всю таблицу агента).
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return table|nil таблица агента с полями pane_id, agent_status и т.д.
function M.GetAgentInfo(tab_id)
  tab_id = tab_id or get_tab_id()

  if not tab_id then
    return nil
  end

  local data = fetch_agent_list()
  if not data or not data.result or not data.result.agents then
    return nil
  end

  for _, agent in ipairs(data.result.agents) do
    if agent.agent == 'pi' and agent.tab_id == tab_id then
      return agent
    end
  end

  return nil
end

--- Проверить, свободен ли агент Pi (статус idle или done).
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return boolean
function M.IsAgentIdle(tab_id)
  tab_id = tab_id or get_tab_id()
  if not tab_id then
    return false
  end

  local agent = M.GetAgentInfo(tab_id)
  if not agent then
    return false
  end

  local status = agent.agent_status or ''
  return status == 'idle' or status == 'done'
end

--- Получить текущий статус агента Pi.
---
--- @param tab_id? string явный tab_id; если nil — берётся из $HERDR_TAB_ID
--- @return string|nil статус агента ('idle', 'working', 'done')
function M.GetAgentStatus(tab_id)
  tab_id = tab_id or get_tab_id()
  if not tab_id then
    return nil
  end

  local agent = M.GetAgentInfo(tab_id)
  if not agent then
    return nil
  end


  return agent.agent_status

end
--- Получить информацию об агенте Pi по pane_id.
---
--- @param pane_id string pane_id (например 'wE:p1')
--- @return table|nil таблица агента с полями pane_id, agent_status и т.д.
function M.GetAgentByPaneId(pane_id)
  local data = fetch_agent_list()
  if not data or not data.result or not data.result.agents then
    return nil
  end

  for _, agent in ipairs(data.result.agents) do
    if agent.agent == 'pi' and agent.pane_id == pane_id then
      return agent
    end
  end
return nil
end

--- Ждать, пока агент остановится (достигнет статуса `done` или исчезнет из списка).
---
--- @param pane_id string pane_id агента
--- @param target_statuses table список целевых статусов (например {'done', 'stopped'})
--- @param timeout? number макс. время ожидания в секундах (по умолч. 30)
--- @return boolean true если агент остановился/исчез, false при таймауте
function M.WaitForStatus(pane_id, target_statuses, timeout)
  target_statuses = target_statuses or { 'done' }
  timeout = timeout or 30

  local interval = 0.5 -- 500 мс между проверками
  local max_iterations = math.floor(timeout / interval)
  local checked = 0

  while checked < max_iterations do
    checked = checked + 1
    local agent = M.GetAgentByPaneId(pane_id)

    if agent then
      -- Агент найден — проверить статус.
      local status = agent.agent_status or ''
      for _, ts in ipairs(target_statuses) do
        if status == ts then
          return true
        end
      end
    else
      -- Агент не найден — значит, исчез из agent list после /quit.
      -- Это тоже успех.
      return true
    end

    vim.uv.sleep(math.floor(interval * 1000))
  end

  return false
end

return M