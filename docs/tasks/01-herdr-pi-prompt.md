# Отправка промпта в агент Pi через Herdr

## Краткая инструкция

### 1. Найти панель с агентом Pi в текущем workspace

```bash
herdr agent list | jq --arg tid "$HERDR_TAB_ID" '.result.agents[] | select(.tab_id == $tid) | .pane_id'
```

Выведет `pane_id` (например `wE:p1`).

### 2. Проверить, что панель свободна (idle)

```bash
herdr agent list | jq --arg tid "$HERDR_TAB_ID" '.result.agents[] | select(.tab_id == $tid) | {pane_id, agent_status}'
```

Статус должен быть `idle`. Если `working` — дождаться завершения.

### 3. Отправить промпт

```bash
# Отправить текст
herdr pane send-text <PANE_ID> "твой промпт"

# Нажать Enter
herdr pane send-keys <PANE_ID> enter
```

### Пример целиком

```bash
PANE_ID=$(herdr agent list | jq --arg tid "$HERDR_TAB_ID" -r '.result.agents[] | select(.tab_id == $tid) | .pane_id')
herdr pane send-text "$PANE_ID" "Привет, покажи структуру проекта"
herdr pane send-keys "$PANE_ID" enter
```

### Чтение ответа

```bash
herdr pane read <PANE_ID> --source recent-unwrapped --lines 50
```