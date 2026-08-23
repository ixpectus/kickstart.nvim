local s = 'some string'
s = s:gsub('s', 'w')
print(s)

s = s.gsub(s, 's', 'w')
print(s)
