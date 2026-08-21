--- Асинхронное ожидание целевого статуса агента или его исчезновения.
--- Не блокирует Neovim — использует vim.defer_fn.
---
--- @class waiter
--- @field WaitForStatus fun(pane_id: string, target_statuses?: table, timeout?: number, on_done?: function)

local finder = require 'custom.herdr.finder'
local M = {}

--- Асинхронно ждать, пока агент достигнет целевого статуса или исчезнет.
--- Асинхронно ждать, пока агент достигнет целевого статуса или исчезнет.
---
--- @param pane_id string pane_id агента
--- @param target_statuses? table список целевых статусов (например {'done', 'stopped'})
--- @param timeout? number макс. время ожидания в секундах (по умолч. 30)
--- @param on_done? function callback(true) при успехе, callback(false) при таймауте
function M.WaitForStatus(pane_id, target_statuses, timeout, on_done)
  target_statuses = target_statuses or { 'done' }
  timeout = timeout or 30

  local max_iterations = math.floor(timeout / 0.5)
  local checked = 0

  local function check()
    checked = checked + 1
    local agent = finder.GetAgentByPaneId(pane_id)

    if on_done then
      if agent then
        local status = agent.agent_status or ''
        for _, ts in ipairs(target_statuses) do
          if status == ts then
            on_done(true)
            return
          end
        end
      else
        -- Агент не найден — значит, исчез из agent list после /quit.
        on_done(true)
        return
      end
    end

    if checked < max_iterations then
      vim.defer_fn(check, 500)
    else
      if on_done then
        on_done(false)
      end
    end
  end

  vim.defer_fn(check, 500)
end

return M