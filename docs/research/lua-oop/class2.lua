local Dog = { -- это таблица класс
  state = '',
}
function Dog:say()
  self.state = 'woofed'
  print 'woof'
end

local mt = { -- это метатаблица, правило привязки объекта к таблице классу
  __index = Dog,
}

local k = setmetatable({}, mt)

print(k:say())
print(k.state)
print('dog ' .. Dog.state)
