--- exec module — run files in a scratch window (horizontal split by default).
---
--- Public API:
---   :Exec <path>
---
--- Handlers are registered in handler.lua by file extension.
---
--- @usage local exec = require 'my_plugins.exec'
--- @usage exec.run_file('/path/to/script.sh')
--- @usage -- or from vim:  :Exec /path/to/script.sh

local M = {}

--- Resolve a possibly relative path to an absolute one.
--- Expands Vim special tokens: %, <cfile>, <cword>, <afile>.
local function resolve_path(path)
  -- If empty, use the current buffer's file.
  if not path or path == '' then
    path = vim.fn.expand '%:p'
    if not path or path == '' then
      vim.notify('exec: no file to run', vim.log.levels.WARN)
      return nil
    end
  end
  return vim.fn.expand(path)
end

--- Register the :Exec user command.
local function register_commands()
  -- :Exec [path] — run a file in a scratch window (horizontal split by default).
  vim.api.nvim_create_user_command('Exec', function(opts)
    M.run_file(opts.args or '')
  end, {
    nargs = '*',
    complete = function(_, context)
      return vim.fn.getcompletion(context.line, 'file')
    end,
  })
end

--- Run a file using the appropriate handler and display output in a
--- scratch window (horizontal split by default).
--- @param path string|nil
function M.run_file(path)
  path = resolve_path(path)
  if not path then
    return
  end

  local handler = require 'my_plugins.exec.handler'

  local ext = vim.fn.fnamemodify(path, ':e')
  local handler_fn = ext and handler.handlers[ext]

  if handler_fn then
    handler_fn(path)
  else
    if bit.band(vim.loop.fs_stat(path).mode, 73) ~= 0 then
      -- No explicit handler but file is executable — treat as shell script.
      handler.shell(path)
    else
      vim.notify('exec: no handler for "' .. path .. '"', vim.log.levels.WARN)
    end
  end
end

function M.setup()
  register_commands()
end

return M
