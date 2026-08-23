local someStruct = {
  value = 3,
}

function someStruct.someMethod()
  print(self) -- тут никакого селфа нет, то есть он есть не у всех методов
end

function someStruct:someMethod2()
  print(self) -- тут селф есть, потому что объявлен метод через :
end

function someStruct.someMethod3(self) -- это полный аналог someStruct:someMethod3
  print(self)
end

print(someStruct.someMethod())
print(someStruct:someMethod2())
print(someStruct:someMethod3())
