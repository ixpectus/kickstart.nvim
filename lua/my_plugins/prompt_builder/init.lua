--- Точка входа модуля prompt_builder. Экспортирует публичное API и регистрирует команды.

local M = {}

local storage = require 'my_plugins.prompt_builder.storage'
local builder = require 'my_plugins.prompt_builder.builder'
local viewer = require 'my_plugins.prompt_builder.viewer'

M.get_prompt_log_path = storage.get_prompt_log_path
M.get_prompt_archive_path = storage.get_prompt_archive_path
M.clear_prompt_log = storage.clear_prompt_log
M.build_prompt_payload = builder.build_prompt_payload
M.save_prompt_to_clipboard = builder.save_prompt_to_clipboard
M.prompt_show = viewer.prompt_show
M.prompt_open = viewer.prompt_open
M.prompt_archive_show = viewer.prompt_archive_show

return M
