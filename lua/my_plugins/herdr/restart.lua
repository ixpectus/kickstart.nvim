local sender = require 'my_plugins.herdr.sender'
local waiter = require 'my_plugins.herdr.waiter'

local M = {}

--- Перезапустить агент Pi: отправить /quit, дождаться остановки, запустить нового.
--- @param pane_id string pane_id агента
--- @param opts? table { quit_timeout? number, session_id? string }
function M.restart_pi(pane_id, opts)
  opts = opts or {}

  -- Отправить /quit.
  local ok_quit = sender.send_to_pane(pane_id, '/quit')
  if not ok_quit then
    vim.schedule(function()
      vim.notify('herdr: failed to send /quit', vim.log.levels.ERROR)
    end)
    return
  end

  -- Нажать Enter.
  sender.send_to_pane(pane_id, 'enter')

  -- Подождать асинхронно, пока агент остановится, затем запустить нового.
  waiter.wait_for_status(pane_id, { 'done' }, opts.quit_timeout, function(ok)
    if not ok then
      vim.schedule(function()
        vim.notify('herdr: timeout waiting for agent to stop (timeout: ' .. tostring(opts.quit_timeout or 30) .. 's)', vim.log.levels.ERROR)
      end)
      return
    end

    local pi_cmd = 'pi'
    if opts.session_id and opts.session_id ~= '' then
      pi_cmd = pi_cmd .. ' --session ' .. opts.session_id
    end

    -- Запустить нового агента Pi — отправить команду в pane.
    local ok_start = sender.send_to_pane(pane_id, pi_cmd)
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
