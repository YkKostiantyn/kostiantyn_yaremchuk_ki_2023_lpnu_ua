# Hello World TypeScript — AI Build Engineer

**Студент:** Яремчук Костянтин Вікторович  
**Група:** КІ-404  
**Варіант:** 6

## Технології

- Мова: **TypeScript**
- Система складання: **npm scripts** (`tsc`)
- Тестування: **Vitest**
- Ціль: кросплатформний консольний застосунок Hello World

Агент створює проєкт із точкою входу `src/hello.ts`, функцією `add(a, b)` у `src/math.ts`, тестом `BasicAddition`, збіркою в `build/`, локальними CI-скриптами та GitHub Actions workflow. Сам застосунок у поточному репозиторії ще не створений — він генерується агентом.

## Запуск AI-агента у VS Code

1. Виберіть custom agent **build-engineer**.
2. Створіть повний проєкт командою:

   ```text
   /lab-init
   ```

3. Перевірте результат:

   ```text
   /check
   ```

Інші доступні команди: `/git-init`, `/create-project`, `/create-build`, `/create-actions`.

Після виконання `/lab-init` можна локально перевірити збірку Linux/macOS:

```bash
./ci.sh
```

або Windows:

```bat
ci.bat
```

## Документація

- [Архітектура агента](docs/architecture.md)
- [Інструкція з використання](docs/usage.md)
- [Журнал взаємодії з AI](docs/ai-log.md)