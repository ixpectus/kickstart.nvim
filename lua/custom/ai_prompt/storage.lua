--- Файловое хранилище логов промптов.

local M = {}

--- Get the path to the persistent prompt log file.
function M.GetPromptLogPath()
  return vim.fn.stdpath 'data' .. '/prompts.log'
end

--- Get the path to the prompt log archive file.
function M.GetPromptArchivePath()
  return vim.fn.stdpath 'data' .. '/prompts_archive.log'
end

--- Append a prompt entry to the persistent log file.
--- @param fname string full file path
--- @param from number start line (1-indexed)
--- @param to number end line (1-indexed)
--- @param selected_text string the text block (with line numbers)
--- @param prompt string user prompt
function M.LogPromptToFile(fname, from, to, selected_text, prompt)
  local timestamp = vim.fn.strftime '%Y-%m-%d %H:%M:%S'
  local entry = string.format(
    '--- [%s] ---\nFile: %s\nLines: %d-%d\n\n%s\n\nPrompt: %s\n\n',
    timestamp,
    fname,
    from,
    to,
    selected_text,
    prompt
  )
  local f = io.open(M.GetPromptLogPath(), 'a')
  if f then
    f:write(entry)
    f:close()
  else
    vim.notify('Failed to write to prompt log', vim.log.levels.ERROR)
  end
end

--- Clear the persistent prompt log file, archiving its contents first.
function M.ClearPromptLog()
  local log_path = M.GetPromptLogPath()
  local archive_path = M.GetPromptArchivePath()

  -- Read current log content.
  local content = vim.fn.readfile(log_path)

  -- Append to archive.
  if #content > 0 then
    local archive_f = io.open(archive_path, 'a')
    if archive_f then
      for _, line in ipairs(content) do
        archive_f:write(line .. '\n')
      end
      archive_f:close()
    else
      vim.notify('Failed to write to prompt archive', vim.log.levels.ERROR)
      return
    end
  end

  -- Truncate the log file.
  local log_f = io.open(log_path, 'w')
  if log_f then
    log_f:close()
  end
  vim.notify('Prompt log cleared (archived)', vim.log.levels.INFO)
end

return M