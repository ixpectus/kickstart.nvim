--- Перезапуск агента Pi: отправить /quit, дождаться остановки, запустить нового.
---
local sender = require 'custom.herdr.sender'

local M = {}

--- Перезапустить агент Pi: отправить /quit, дождаться остановки, запустить нового.
--- @param pane_id string pane_id агента
--- @param finder table модуль finder с WaitForStatus
--- @param opts? table { quit_timeout? number }
--- @return boolean true при успехе, false при ошибке
function M.RestartPi(pane_id, finder, opts)
  opts = opts or {}

  -- Отправить /quit.
  local ok_quit = sender.SendToPane(pane_id, '/quit')
  if not ok_quit then
    vim.schedule(function()
      vim.notify('herdr: failed to send /quit', vim.log.levels.ERROR)
    end)
    return false
  end

  -- Нажать Enter.
  sender.SendToPane(pane_id, 'enter')

  -- Подождать, пока агент остановится.
  local ok_wait = finder.WaitForStatus(pane_id, { 'done' }, opts.quit_timeout)
  if not ok_wait then
    vim.schedule(function()
      vim.notify('herdr: timeout waiting for agent to stop (timeout: ' .. tostring(opts.quit_timeout or 30) .. 's)', vim.log.levels.ERROR)
    end)
    return false
  end

  -- Запустить нового агента Pi в том же pane_id.
  local ok_start = sender.SendToPane(pane_id, 'pi')
  if not ok_start then
    vim.schedule(function()
      vim.notify('herdr: failed to restart agent in pane ' .. pane_id, vim.log.levels.ERROR)
    end)
    return false
  end

  vim.schedule(function()
    vim.notify('herdr: agent restarted in pane ' .. pane_id, vim.log.levels.INFO)
  end)

  return true
end

return M
