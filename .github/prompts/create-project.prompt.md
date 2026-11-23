---
description: Створити TypeScript scaffold проєкту
agent: build-engineer
---

# Передумови

Виконай інструкції skill: [project-scaffold](../skills/project-scaffold/SKILL.md).

- Викликати skill `project-scaffold`.
- Вхідні дані: мова TypeScript і назва поточного репозиторію.
- Поточний репозиторій доступний для змін.

# Дії

1. Завантаж skill `project-scaffold`.
2. Створіть або доповніть `package.json`, `tsconfig.json`, `src/hello.ts`, `src/math.ts`, `.gitignore` та README-розділ.
3. Не перезаписуй сумісні існуючі налаштування без потреби.
4. Показати diff цільових змін.

# Очікувані файли

- `package.json`
- `tsconfig.json`
- `src/hello.ts`
- `src/math.ts`
- `.gitignore`
- README-розділ у `README.md`

# Команди перевірки

```bash
test -f src/hello.ts
test -f src/math.ts
npm run build
test "$(node build/hello.js)" = "Hello, World!"
```

# Повідомлення про помилку

При помилці першого кроку зупинись і назви файл або команду, де сталася помилка. Не переходь до наступних command.
