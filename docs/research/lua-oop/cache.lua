local cache = {
  __call = function(self, ...)
    -- self тут будет Cache
    local obj = setmetatable({ data = {} }, self)
    return obj
  end,
}

local Cache = setmetatable({ data = {} }, cache)
function Cache:print(val)
  print(val)
end

Cache.__index = Cache

local c = Cache()
c:print '3'
