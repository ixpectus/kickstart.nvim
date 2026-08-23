local T = {}

local mT = {
  __call = function(tbl, x)
    return x * 3
  end,
  __index = function(tbl, key)
    print(key)
    return 1
  end,
}
local s = 'some string'
setmetatable(T, mT)
print(T(8)) -- 24
print(T.a)
print(type(s))
print(getmetatable(s))
n = 3
print(type(n))
setmetatable(n, mT)
