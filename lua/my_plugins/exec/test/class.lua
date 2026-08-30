local Dog = {
  state = '',
}

function Dog:say()
  self.state = 'woofed'
  print 'nowof'
end

Dog.__index = Dog

function Dog:new()
  local res = setmetatable({ state = 'not woofed' }, self)
  self.__index = self
  return res
end

local d = Dog:new()
local c = Dog
local k = setmetatable({ state = 'not woofed' }, Dog)

print(d:say())
-- print(k:say())
print(d.state)
-- print(c.state)
print(k.state)
