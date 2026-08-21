local sender = require 'custom.herdr.sender'
local waiter = require 'custom.herdr.waiter'

local M = {}

--- Перезапустить агент Pi: отправить /quit, дождаться остановки, запустить нового.
--- @param pane_id string pane_id агента
--- @param opts? table { quit_timeout? number }
function M.RestartPi(pane_id, opts)
  opts = opts or {}

  -- Отправить /quit.
  local ok_quit = sender.SendToPane(pane_id, '/quit')
  if not ok_quit then
    vim.schedule(function()
      vim.notify('herdr: failed to send /quit', vim.log.levels.ERROR)
    end)
    return
  end

  -- Нажать Enter.
  sender.SendToPane(pane_id, 'enter')

  -- Подождать асинхронно, пока агент остановится, затем запустить нового.
waiter.WaitForStatus(pane_id, { 'done' }, opts.quit_timeout, function(ok)
    if not ok then
      vim.schedule(function()
        vim.notify('herdr: timeout waiting for agent to stop (timeout: ' .. tostring(opts.quit_timeout or 30) .. 's)', vim.log.levels.ERROR)
      end)
      return
    end

    -- Запустить нового агента Pi — отправить 'pi' в pane.
    local ok_start = sender.SendToPane(pane_id, 'pi')
    if not ok_start then
      vim.schedule(function()
        vim.notify('herdr: failed to restart agent in pane ' .. pane_id, vim.log.levels.ERROR)
      end)
      return
    end

    vim.schedule(function()
      vim.notify('herdr: agent restarted in pane ' .. pane_id, vim.log.levels.INFO)
    end)
  end)
end

return M