--- Модуль prompts — выборка промптов из каталога `prompts/` через telescope.
---
--- Каждый `.md` файл в каталоге `prompts/` (относительно `stdpath('config')`)
--- становится элементом пикера: имя файла — display, содержимое — превью.
--- По Enter промпт вставляется в текущий буфер на месте курсора.
---
--- @usage local prompts = require 'custom.prompts'
--- @usage prompts.list() -- или :PromptsList

local M = {}

local pickers = require 'telescope.pickers'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local previewers = require 'telescope.previewers'
local themes = require 'telescope.themes'

--- Каталог с промптами.
--- @return string path
local function prompts_dir()
  return vim.fn.stdpath 'config' .. '/prompts'
end

--- Собрать список промптов из каталога.
--- @return table[] entries
local function collect_prompts()
  local dir = prompts_dir()
  if vim.fn.isdirectory(dir) ~= 1 then
    vim.fn.mkdir(dir, true)
  end

  local entries = {}
  for _, name in ipairs(vim.fn.readdir(dir)) do
    if not name:match '^%.' and name:match '%.md$' then
      local path = dir .. '/' .. name
      local lines = vim.fn.readfile(path)
      local title = name:gsub('%.md$', '')
      table.insert(entries, {
        name = title,
        path = path,
        display = name,
        ordinal = name,
        content = table.concat(lines, '\n'),
      })
    end
  end

  table.sort(entries, function(a, b)
    return a.name < b.name
  end)
  return entries
end

--- Вставить текст промпта в текущий буфер.
--- Если текущая строка пустая — вставляем в неё, иначе — после неё.
--- @param content string
local function insert_prompt(content)
  local lnum = vim.api.nvim_win_get_cursor(0)[1]

  local lines = vim.split(content, '\n')
  local cur_line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ''

  if cur_line == '' then
    -- Пустая строка: заменяем её на строки промпта
    vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, lines)
    vim.api.nvim_win_set_cursor(0, { lnum, 0 })
  else
    -- Не пустая: вставляем после текущей строки, сдвигаем содержимое вниз
    vim.api.nvim_buf_set_lines(0, lnum, lnum, false, lines)
    vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
  end
end

--- Запустить telescope picker со списком промптов.
function M.list()
  local entries = collect_prompts()
  if #entries == 0 then
    vim.notify('prompts: no prompts found in ' .. prompts_dir(), vim.log.levels.WARN)
    return
  end

  pickers
    .new(
      {},
      themes.get_dropdown {
        prompt_title = 'Prompts',
        sorting_strategy = 'ascending',
        layout_config = {
          height = 14,
          width = 0.9,
          mirror = true,
        },
        previewer = previewers.new_buffer_previewer {
          title = 'Prompt',
          dyn_title = function(_, entry)
            if not entry or not entry.value then
              return ''
            end
            return entry.value.name
          end,
          define_preview = function(self, entry)
            if not entry or not entry.value then
              return
            end
            local lines = vim.split(entry.value.content, '\n')
            if #lines > 20 then
              lines = vim.list_slice(lines, 1, 20)
              table.insert(lines, '…')
            end
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            vim.wo[self.state.winid].wrap = true
          end,
        },
        finder = require('telescope.finders').new_table {
          results = entries,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.ordinal,
              path = entry.path,
            }
          end,
        },
        sorter = conf.generic_sorter(),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              insert_prompt(selection.value.content)
            end
          end)

          -- Открыть файл промпта в буфере
          vim.keymap.set('n', 'o', function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection and selection.value.path then
              vim.cmd.edit(selection.value.path)
            end
          end, { buffer = prompt_bufnr, silent = true, desc = 'Open prompt file' })

          -- Скопировать содержимое промпта в буфер обмена
          vim.keymap.set('n', 'y', function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection and selection.value.content then
              vim.fn.setreg('+', selection.value.content)
              vim.notify('Prompt скопирован: ' .. selection.value.name, vim.log.levels.INFO)
            end
          end, { buffer = prompt_bufnr, silent = true, desc = 'Copy prompt content' })

          return true
        end,
      }
    )
    :find()
end

function M.setup()
  vim.api.nvim_create_user_command('PromptsList', M.list, {
    desc = 'List prompts from the prompts/ directory in telescope',
  })
end

return M
