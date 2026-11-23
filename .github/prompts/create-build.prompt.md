---
description: Налаштувати npm збірку, Vitest і CI-скрипти
agent: build-engineer
---

# Передумови

Виконай інструкції skill: [build-and-test](../skills/build-and-test/SKILL.md).

- Викликати skill `build-and-test`.
- Scaffold і Node.js/npm доступні.
- Збережено зміни з `create-project`, якщо вона була виконана раніше.

# Дії

1. Завантаж skill `build-and-test`.
2. Налаштуй scripts `build`, `test`, `start`, `clean`.
3. Створіть `tests/math.test.ts` із тестом `BasicAddition`.
4. Створіть `ci.sh` і `ci.bat` і обгортки збірки.
5. Виконай перевірки без прихованих помилок.

# Очікувані файли

- `package.json`
- `tests/math.test.ts`
- `ci.sh`
- `ci.bat`
- `build/hello.js`
- `build/hello`
- `build/hello.cmd`

# Команди перевірки

```bash
npm ci
npm run build
npm test
npx vitest run -t BasicAddition
./ci.sh
test "$(./build/hello)" = "Hello, World!"
```

# Повідомлення про помилку

При будь-якій помилці зупинись із назвою тесту або script-команди та її exit code. Не запускай `create-actions`, якщо локальна збірка не пройшла.
