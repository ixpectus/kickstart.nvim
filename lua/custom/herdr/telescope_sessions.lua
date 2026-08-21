--- Telescope picker для списка сессий Pi через pi_sessions_list.py.
---
--- Показывает: id сессии, количество сообщений, первый промпт, даты, длительность.
--- Действия: открыть файл сессии или скопировать id в буфер.
---
--- ```lua
--- require('custom.herdr.telescope_sessions').find()
--- ```

local pickers = require 'telescope.pickers'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local previewers = require 'telescope.previewers'
local themes = require 'telescope.themes'
local M = {}

--- Запустить telescope picker сессий.
function M.find()
  -- Собираем JSON от скрипта
  local raw = vim.fn.system 'python3 ~/scripts/pi_sessions_list.py'
  local ok, sessions = pcall(function()
    return vim.fn.json_decode(raw)
  end)
  if not ok or type(sessions) ~= 'table' then
    vim.notify('pi_sessions_list.py: ' .. tostring(sessions), vim.log.levels.ERROR)
    return
  end

  -- Форматируем строку отображения
  local entries = {}
  for _, s in ipairs(sessions) do
    local date_str = ''
    if s.first_message_date then
      local dt = s.first_message_date:gsub('Z', '')
      -- берём дату и время: "2026-08-21T14:42:55"
      date_str = dt:sub(1, 19):gsub('T', ' ')
    end

    local display = string.format('%d %s %s %s ', s.message_count, s.duration or '-', date_str, s.id:sub(1, 8))
    table.insert(entries, {
      id = s.id,
      file = s.file,
      message_count = s.message_count,
      first_prompt = s.first_prompt or '',
      first_message_date = s.first_message_date,
      last_message_date = s.last_message_date,
      duration = s.duration,
      display = display,
      ordinal = s.id,
    })
  end

  if #entries == 0 then
    vim.notify('Сессии не найдены', vim.log.levels.WARN)
    return
  end

  pickers
    .new(
      {},
      themes.get_dropdown {
        prompt_title = 'Pi Sessions',
        sorting_strategy = 'ascending',
        layout_config = {
          height = 14,
          width = 0.9,
          mirror = true,
        },
        finder = require('telescope.finders').new_table {
          results = entries,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.ordinal,
              file = entry.file,
            }
          end,
        },
        sorter = conf.generic_sorter(),
        previewer = previewers.new_buffer_previewer {
          title = 'First prompt',
          dyn_title = function(_, entry)
            if not entry or not entry.value then
              return ''
            end
            local p = entry.value.first_prompt or ''
            return #p > 80 and p:sub(1, 80) .. '…' or p
          end,
          define_preview = function(self, entry)
            if not entry or not entry.value then
              return
            end
            local prompt = entry.value.first_prompt or ''
            local lines = vim.split(prompt, '\n')
            -- Обрезаем превью до 20 строк
            if #lines > 20 then
              lines = vim.list_slice(lines, 1, 20)
              table.insert(lines, '…')
            end
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            vim.wo[self.state.winid].wrap = true
          end,
        },
        attach_mappings = function(prompt_bufnr)
          -- Открыть файл сессии
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            local file = selection.value.file
            if file then
              vim.cmd('edit ' .. vim.fn.fnameescape(file))
            end
          end)

          -- Скопировать id сессии
          vim.keymap.set('n', 'y', function()
            local selection = action_state.get_selected_entry()
            if selection and selection.value.id then
              vim.fn.setreg('+', selection.value.id)
              vim.notify('Session ID скопирован: ' .. selection.value.id, vim.log.levels.INFO)
            end
          end, { buffer = prompt_bufnr, silent = true, desc = 'Copy session ID' })

          return true
        end,
      }
    )
    :find()
end

return M
