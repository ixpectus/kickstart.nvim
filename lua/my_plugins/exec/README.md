# exec

Запуск файлов в scratch-окне (горизонтальный сплит).

`:lua require 'my_plugins.exec'.run_file('/path/to/script.sh')`

Поддерживаемые типы: `.lua` (через `lua5.4`), исполняемые shell-скрипты (по +x биту).


Примеры: `test/ls.sh`, `test/class.lua`
