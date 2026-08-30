# scratch

Scratch-окно для вывода команд и временного содержимого.

`:lua require('my_plugins.scratch').open({'line1', 'line2'}, { layout = 'split' })`
`:lua require('my_plugins.scratch').command('ls -la', { layout = 'split' })`
`:lua require('my_plugins.scratch').close()`

Layout: `'split'` (горизонтальный), `'vsplit'` (вертикальный), `'full'` (на весь экран).

