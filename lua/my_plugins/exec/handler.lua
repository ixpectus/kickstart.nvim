--- exec handlers — file-type-specific executors.
---
--- Extend by adding a function here and registering it in the `handlers` table.
---
--- @usage local handler = require 'my_plugins.exec.handler'
--- @usage handler.shell('/path/to/script.sh')
--- @usage handler.lua('/path/to/script.lua')

local M = {}

local scratch = require 'my_plugins.scratch'

-- Owner + group + other execute bits: 64 + 8 + 1 = 73.
local EXEC_MASK = 73

--- Get the file stat if the file exists.
--- @param path string
--- @return table? stat
local function getFileStatIfExists(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    vim.notify('exec: file not found: ' .. path, vim.log.levels.ERROR)
  end
  return stat
end

--- Validate that the file is executable.
--- @param stat table
local function validateExecutable(stat)
  if bit.band(stat.mode, EXEC_MASK) == 0 then
    vim.notify('exec: not executable: ' .. path, vim.log.levels.WARN)
    return false
  end
  return true
end

--- Execute a shell script (must have +x bit) and show output in scratch.
--- @param path string
function M.shell(path)
  local stat = getFileStatIfExists(path)
  if not stat or not validateExecutable(stat) then
    return
  end

  scratch.command(path, { layout = 'split' })
end

--- Execute a Lua script via `lua5.4` and show output in scratch.
--- @param path string
function M.lua(path)
  local stat = getFileStatIfExists(path)
  if not stat then
    return
  end

  scratch.command('lua5.4 ' .. path, { layout = 'split' })
end

--- Registry: extension → handler function.
--- Extend this table to support new file types.
M.handlers = {
  ['lua'] = M.lua,
}

return M
