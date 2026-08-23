Встречаю в коде такие конструкции, но плохо понимаю, как они работают.

```lua 
      local dt = s.first_message_date:gsub('Z', '')
```

```lua 
   :find() 
```

Я хочу разобраться как это устроено.
Уметь быстро запускать lua скрипты, чтобы проводить эксперименты.
Результаты  будем фиксировать в этом файле под ---

---
## Разбор конструкций

### 1. `string:gsub(pattern, repl)` — глобальная замена

**Что делает:** заменяет все вхождения pattern в строке на repl.

**Возвращает:** `(новая_строка, число_замен)`

```lua
local s = "2024-01-15T14:30:00Z"
local dt = s:gsub("Z", "")
-- Результат: "2024-01-15T14:30:00"

-- gsub с pattern (regexp-подобным)
local cleaned = s:gsub("[TZ]", "")
-- Результат: "2024-01-1514:30:00"

-- gsub возвращает два значения:
local result, n = s:gsub("0", "9")
-- result = "2924-91-15T14:39:99Z", n = 5 (число замен)
```

**Pattern-ы:** Lua string patterns (не полноценный regexp):
- `%d` — цифра, `%w` — алфавитно-цифровой, `%a` — буква
- `.` — любой символ, `%S` — не пробел

**Пример из кода проекта** (`telescope_sessions.lua:49-50`):
```lua
local dt = s.first_message_date:gsub('Z', '')
date_str = dt:sub(1, 19):gsub('T', ' ')
-- "2024-01-15T14:30:00Z" → "2024-01-15 14:30:00"
```

---

### 2. `:find()` — что это?

**Два разных `find`:**

#### A. `string:find(substring)` — поиск подстроки

```lua
local s = "2024-01-15T14:30:00Z"
local start, finish = s:find("T")
-- start = 11, finish = 11
```

**Возвращает:** `(начальная_позиция, конечная_позиция)` или `nil` если не найдено.

```lua
-- Поиск с позиции (четвёртый аргумент)
local s3 = "aaaabaaa"
local pos = 1
while true do
    local start, finish = s3:find("b", pos)
    if not start then break end
    pos = finish + 1
end
-- Находит все вхождения "b"
```

#### B. `:find()` в Telescope — вызов метода объекта

```lua
-- В коде: telescope.themes.get_dropdown():find()
-- Это НЕ string.find!

-- get_dropdown() возвращает объект-picker
-- picker:find() — вызывает метод find() на этом объекте
-- Это запускает поиск и показывает окно выбора

-- Схематично:
local picker = get_dropdown{commands = get_commands()}
picker:find()  -- picker.find(picker) — запускает поиск
```

---

### Как это работает: синтаксис `:` vs `.`

```lua
-- Двоеточие — это синтаксический сахар
obj:method(arg)  ===  obj.method(obj, arg)

-- Для таблиц:
local T = {}
function T:greet()
    return "hello, " .. self.value  -- self передается автоматически
end

T.value = 42
print(T:greet())      -- hello, 42  (двоеточие)
print(T.greet(T))     -- hello, 42  (точка, self вручную)

-- self = nil при объявлении через точку:
function T.no_self()
    print(self)  -- nil
end

---

### Что такое `self`?

**Правило: один-единственный**

| Объявление | Вызов | `self` |
|------------|-------|--------|
| `function T:m()` | `T:m()` | `T` (таблица справа от `:`) |
| `function T:m()` | `T.m(T)` | `T` (явно передана) |
| `function T.m()` | `T.m()` | **nil** |

- `self` есть у **всех** методов, объявленных через `:` (двоеточие)
- `self` **отсутствует** у функций, объявленных через `.` (точку)
- `self` **не статичен** — он равен объекту, справа от которого вызвали метод

```lua
local Counter = {}
Counter.__index = Counter  -- КЛАССИЧЕСКИЙ ПОДХОД

function Counter:new()
    -- self = Counter (класс)
    return setmetatable({ count = 0 }, self)
end

function Counter:incr()
    -- self = объект-потомок (не класс!)
    self.count = self.count + 1
    return self.count
end

local c = Counter:new()
c:incr()  -- self = c (потомок), а не Counter (класс)

---

### Почему `Counter.__index = Counter`?

Это **стандартный паттерн** в Lua — классический способ реализовать ООП.

```lua
local Plugin = {}
Plugin.__index = Plugin

function Plugin:new()
    return setmetatable({ config = {} }, self)
end

function Plugin:setup(opts)
    for k, v in pairs(opts) do
        self.config[k] = v
    end
end

function Plugin:register(keymap)
    print("Регистрирую:", keymap)
end

local plugin = Plugin:new()
plugin:setup({ keymap = true })
plugin:register("<C-n>")
-- plugin.config.keymap = true
-- self здесь = plugin (не Plugin!)
```

**Почему `Plugin.__index = Plugin`, а не `Plugin.__index = {}`?**

Потому что все методы определены в `Plugin`:
- `function Plugin:setup()` — метод в Plugin
- `function Plugin:register()` — метод в Plugin

`Plugin.__index = Plugin` → при поиске метода Lua найдёт их в самой `Plugin`.

**Алгоритм работы:**

1. `Counter:new()` → создаёт `{ count = 0 }` с `__index = Counter`
2. `c:incr()` → ищет `incr` у `c` — нет
3. Ищет `c.__index` (= `Counter`) → находит `Counter.incr`
4. Вызывает `Counter.incr(c)` — `self = c`

**Важно:** `self` **не статичен** — он равен объекту, справа от которого вызвали метод:
- `Counter:new()` → `self = Counter`
- `c:incr()` → `self = c` (потомок, а не класс!)


---

### Что такое метатаблица?

Метатаблица — это **таблица-инструкция**, которая задаёт **поведение** Lua при операциях с объектом.

Это **правила действий в нестандартных ситуациях** — когда Lua не может просто взять ключ по значению из таблицы:

- Свойства нет? → вызов `__index` (чтение)
- Пытаются записать? → вызов `__newindex`
- Вызывают таблицу как функцию? → вызов `__call`
- Конкатенируют строку? → вызов `__concat`
- Складывают? → вызов `__add`
- Сравнивают? → вызов `__eq`
- Считают длину? → вызов `__len`

```lua
local T = {}
local mt = { __index = { x = 1 } }
setmetatable(T, mt)  -- связываем T с mt

-- Теперь Lua знает: если у T нет свойства — смотри в mt.__index
print(T.x)  -- 1
```

**Ключевые метатабличные ключи:**

| Ключ | Когда вызывается | Пример |
|------|-----------------|--------|
| `__index` | Чтение свойства | `obj.key` |
| `__newindex` | Запись свойства | `obj.key = val` |
| `__call` | Вызов таблицы как функции | `obj()` |
| `__tostring` | Преобразование в строку | `tostring(obj)` |
| `__add` | Сложение | `a + b` |
| `__sub` | Вычитание | `a - b` |
| `__eq` | Сравнение | `a == b` |
| `__len` | Длина объекта | `#obj` |

**Примеры:**

```lua
-- __call — таблица как функция
local T4 = {}
local mt4 = {
    __call = function(tbl, x)
        return x * 2
    end
}
setmetatable(T4, mt4)
print(T4(5))  -- 10

-- __tostring — вывод в print
local T5 = {}
local mt5 = {
    __tostring = function(tbl)
        return "T5: " .. tbl.value
    end
}
setmetatable(T5, mt5)
T5.value = 42
print(T5)  -- T5: 42

-- __add — арифметика
local T6 = {}
local mt6 = {
    __add = function(a, b)
        return a.value + b.value
    end
}
setmetatable(T6, mt6)
local t6a = setmetatable({ value = 10 }, mt6)
local t6b = setmetatable({ value = 20 }, mt6)
print(t6a + t6b)  -- 30
```

**Функции работы с метатаблицами:**

```lua
getmetatable(obj)  -- получить метатаблицу
setmetatable(obj, mt)  -- установить метатаблицу
rawget(tbl, key)  -- прочитать БЕЗ метатаблицы
rawset(tbl, key, val)  -- записать БЕЗ метатаблицы
rawequal(a, b)  -- сравнить БЕЗ метатаблицы
```

## Какие типы данных могут иметь метатаблицу?

| Тип | Встроенная метатаблица? | Можно задать свою? |
|-----|------------------------|-------------------|
| **table** | ❌ Нет (по умолчанию) | ✅ Да (основной способ) |
| **string** | ✅ Да (со строковыми методами) | ❌ Нет |
| **userdata** | Зависит от C-библиотеки | ✅ Да (Neovim API) |
| **number** | ❌ Нет | ❌ Нет |
| **boolean** | ❌ Нет | ❌ Нет |
| **thread** | ❌ Нет | ❌ Нет |

**Метатаблицу можно задать только таблицам и userdata.**

**Строка — не исключение, а выбор дизайна.** У строки есть встроенная метатаблица (через неё работают `s:sub()`, `s:find()` и т.д.), но заменить её нельзя. Остальные примитивные типы (number, boolean, thread) — вообще без метатаблиц.

Строка получила встроенную метатаблицу, потому что у строк есть общепринятые операции: длина, подстрока, поиск, замена. Это осознанный выбор: примитивные типы, для которых есть смысл в таких операциях, получают встроенную метатаблицу.


### Что такое `__index`?

`__index` — это **ключ в метатаблице**, который говорит Lua:

> Если свойства нет у объекта — ищи его в другой таблице.

```lua
local Animal = {}
Animal.__index = Animal  -- Ключевой момент

function Animal:speak()
    print("I am a", self.kind)
end

-- Создаём потомка:
local Dog = setmetatable({ kind = "dog" }, Animal)
-- setmetatable({kind="dog"}, Animal) = { __index = Animal }

-- Алгоритм Dog.kind:
-- 1. Есть ли Dog.kind? Да = "dog"
-- 2. Нет Dog.speak? Идём в Dog.__index (= Animal)
-- 3. Animal.speak есть → возвращаем

print(Dog.kind)    -- dog (своё свойство)
Dog:speak()        -- I am a dog (метод из Animal)
```

**__index может быть функцией** (динамический поиск):

```lua
local Cache = setmetatable({}, {
    __index = function(tbl, key)
        print("Ищу", key)
        return "не найдено"
    end
})
print(Cache.foo)  -- Ищу foo  →  не найдено
print(Cache.bar)  -- Ищу bar  →  не найдено
```

**Алгоритм поиска свойства в Lua:**

1. Есть свойство у объекта напрямую? → вернуть
2. Есть метатаблица? → проверить `__index`
3. `__index` — функция? → вызвать `__index(obj, key)`
4. `__index` — таблица? → рекурсивно искать в ней
5. Ничего не найдено → `nil`

**В контексте Neovim-плагинов:**

```lua
-- Стандартный паттерн:
local M = {}
M.__index = M

function M:new()
    return setmetatable({ options = {} }, self)
end

function M:setup(opts)
    -- self = экземпляр, не M
    for k, v in pairs(opts) do
        self.options[k] = v
    end
end

local plugin = M:new()
plugin:setup({ keymap = true })  -- self = plugin
```

`plugin:setup()` → `self = plugin` → ищем `setup` в `plugin.__index` → находим в `M`.

**В контексте Neovim-плагинов:**
- `self` = таблица-модуль, справа от `:`
- При вызове `plugin:setup()` — `self` = `plugin`
- При наследовании через `__index` — `self` = объект, у которого ищут метод

**Строковые методы — это не потому, что строка таблица.**

Строка в Lua — **не таблица**. `type(s) == "string"`.

Но у строки есть **встроенная метатаблица**, в которой `__index` указывает на таблицу всех строковых методов:

```lua
local s = "hello"
print(getmetatable(s))  -- string (metatable)
print(getmetatable(s).__index)  -- string (таблица методов)
print(getmetatable(s).__index.sub)  -- function
```

`s:sub(1, 3)` — это `getmetatable(s).__index.sub(s, 1, 3)`.

**Ключевой момент:** `self` в строковом методе — это **строка**, а не таблица.

```lua
local s = "hello world"
-- s:find("w") === string.find(s, "w")
-- self здесь = "hello world" (строка, не таблица!)
```

**Итог:** строка — это примитивный тип. Метатаблица даёт ей методы, но сама строка таблицей не является.


---

## Примеры OOP из Telescope

### 1. Классический паттерн (Picker, EntryManager, AsyncJob)

```lua
-- Классический подход: __index = сам класс
local Picker = {}
Picker.__index = Picker

function Picker:new(opts)
    local obj = setmetatable({
        finder = assert(opts.finder),
        sorter = opts.sorter or require("telescope.sorters").empty(),
        -- ... остальные поля
    }, self)  -- self = Picker
    return obj
end

function Picker:find()  -- self = экземпляр
    self.finder(...)  -- вызов метода finder
end


### 7. `assert` — проверка обязательных аргументов

```lua
-- Telescope: pickers.lua
function Picker:new(opts)
    local obj = setmetatable({
        finder = assert(opts.finder),  -- если opts.finder == nil — ошибка
        sorter = opts.sorter or require("telescope.sorters").empty(),
    }, self)
    return obj
end
```

**`assert(value)`** — если `value == false` или `nil`, выбрасывает ошибку. Иначе возвращает `value`.

**`assert(value, message)`** — то же, но с кастомным сообщением об ошибке.

**Зачем?** Быстрая валидация обязательных параметров. `Picker:new{}` без `finder` — ошибка: `attempt to call a nil value (field 'finder')`.

**Альтернатива:** `opts.finder or error("finder is required")`.

**Почему `Picker.__index = Picker`?** Потому что все методы определены в `Picker`. При `picker:find()` Lua ищет `find` у экземпляра — нет — ищет в `Picker.__index` (= `Picker`) — находит.

### 2. Ленивый поиск через `__index` как функцию

```lua
-- Telescope: make_entry.lua
make_entry.set_default_entry_mt = function(tbl, opts)
    return setmetatable({}, {
        __index = function(t, k)
            local override = handle_entry_index(opts, t, k)
            if override then
                return override
            end
            -- Только один раз берём из tbl
            local val = tbl[k]
            if val then
                rawset(t, k, val)  -- кэшируем в t
            end
            return val
        end,
    })
end
```

**Зачем?** Кэширует лениво вычисляемые свойства. Первый доступ — вычисляет, второй — берёт напрямую из таблицы (fast path).

### 3. `__call` — объект как функция

```lua
-- Telescope: finders.lua
local _callable_obj = function()
    local obj = {}
    obj.__index = obj
    obj.__call = function(t, ...)
        return t:_find(...)
    end
    obj.close = function() end
    return obj
end
```

**Зачем?** Позволяет вызывать объект как функцию: `finder(prompt, cb1, cb2)` вместо `finder:_find(prompt, cb1, cb2)`.

### 4. `__call` для конструктора (Layout, Border)

```lua
-- Telescope: pickers/layout.lua
local Border = setmetatable({}, {
    __call = init_border,
})

-- Border() создаёт новый Border через init_border()
```

**Зачем?** Фабричная функция: `Border()` вместо `Border:new()`.

### 5. Прокси-объект через `__index`

```lua
-- Telescope: command.lua
local _switch_metatable = {
    __index = function(_, k)
        utils.notify("command", {
            msg = string.format("Type of '%s' does not match", k),
            level = "WARN",
        })
    end,
}
```

**Зачем?** При обращении к несуществующему ключу — выдаёт предупреждение. Полезно для отладки.

### 6. Комбинирование действий через `__add`

```lua
-- Telescope: actions/mt.lua
action_mt.__call = function(t, ...)
    -- Выполняет все actions в списке
end

action_mt.__add = function(lhs, rhs)
    local new_action = setmetatable({}, action_mt.create())
    -- Объединяет две action-таблицы в одну
    return new_action
end
```

**Зачем?** Позволяет комбинировать действия: `action1 + action2`.

### Сводная таблица паттернов

| Паттерн | Когда использовать | Пример из Telescope |
|---------|-------------------|--------------------|
| `__index = класс` | Классическое ООП, все методы в классе | `Picker`, `EntryManager`, `AsyncJob` |
| `__index = функция` | Ленивый/динамический поиск | `make_entry.set_default_entry_mt` |
| `__index = таблица` | Простое наследование | `Sorter.__index = Sorter` |
| `__call = функция` | Объект как функция/фабрика | `_callable_obj`, `Border` |
| `__call = метод` | Метод как вызов | `Picker:find()` |
| `__add` | Комбинирование | `action1 + action2` |
| `__mode = "kv"` | Слабые ключи/значения | `state.get_status()` |
---

### Как быстро запускать Lua для экспериментов

| Способ | Команда |
|--------|---------|
| Одна строка | `lua5.4 -e "print(1+1)"` |
| Интерактивный режим | `lua5.4` (введите код, Enter) |
| Файл скрипта | `lua5.4 script.lua` |
| Внутри nvim | `:lua print("hello")` |
| Файл внутри nvim | `:luafile script.lua` |
