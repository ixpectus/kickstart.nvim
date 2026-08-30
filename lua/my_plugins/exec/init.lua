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

return M
