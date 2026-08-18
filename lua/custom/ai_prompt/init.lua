--- Точка входа модуля ai_prompt. Экспортирует публичное API.

local storage = require 'custom.ai_prompt.storage'
local builder = require 'custom.ai_prompt.builder'
local sender  = require 'custom.ai_prompt.sender'
local viewer  = require 'custom.ai_prompt.viewer'

return {
  -- из storage
  GetPromptLogPath    = storage.GetPromptLogPath,
  GetPromptArchivePath = storage.GetPromptArchivePath,
  ClearPromptLog      = storage.ClearPromptLog,
  -- из builder
  BuildPromptPayload  = builder.BuildPromptPayload,
  FormatLinesWithNumbers = builder.FormatLinesWithNumbers,
  -- из sender
  SendSelectionToAgent = sender.SendSelectionToAgent,
  -- из viewer
  PromptShow       = viewer.PromptShow,
  PromptOpen       = viewer.PromptOpen,
  PromptArchiveShow = viewer.PromptArchiveShow,
}