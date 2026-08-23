--- exec handlers — file-type-specific executors.
---
--- Extend by adding a function here and registering it in the `handlers` table.
---
--- @usage local handler = require 'custom.exec.handler'
--- @usage handler.shell('/path/to/script.sh')
--- @usage handler.lua('/path/to/script.lua')

local M = {}

local scratch = require 'custom.scratch'

--- Execute a shell script (must have +x bit) and show output in scratch.
--- @param path string
function M.shell(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    vim.schedule(function()
      vim.notify('exec: file not found: ' .. path, vim.log.levels.ERROR)
    end)
    return
  end

  -- Check if any execute bit is set (owner, group, or other).
  if bit.band(stat.mode, 73) == 0 then
    vim.schedule(function()
      vim.notify('exec: not executable: ' .. path, vim.log.levels.WARN)
    end)
    return
  end

  local buf = scratch.command(path, { layout = 'split' })
  return buf
end

--- Execute a Lua script via `lua5.4` and show output in scratch.
--- @param path string
function M.lua(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    vim.schedule(function()
      vim.notify('exec: file not found: ' .. path, vim.log.levels.ERROR)
    end)
    return
  end

  local cmd = 'lua5.4 ' .. path
  local buf = scratch.command(cmd, { layout = 'split' })
  return buf
end

--- Registry: extension → handler function.
--- Extend this table to support new file types.
M.handlers = {
  ['.lua'] = M.lua,
}

return M