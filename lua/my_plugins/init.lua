require('my_plugins.prompt_builder').setup()
require('my_plugins.herdr').setup()
require('my_plugins.exec').setup()
require('my_plugins.prompts').setup()

-- Модули без setup():
require 'my_plugins.scratch'
require 'my_plugins.pi_sessions'
