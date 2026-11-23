---
description: Оркеструвати повне створення й перевірку лабораторного проєкту
agent: build-engineer
---

# Передумови

1. Перевірти Node.js: `node --version`; прийнятна major-version `>=20`.
2. Перевірити доступність `npm --version`.
3. Перевірити доступність `git --version`.
4. Якщо будь-який prerequisite відсутній або Node нижче 20, зупинись із поясненням і не змінюй файли.

# Дії

1. Виконай перевірку передумов.
2. Прочитай і виконай кожен prompt-file по черзі:
   1. [git-init](git-init.prompt.md)
   2. [create-project](create-project.prompt.md)
   3. [create-build](create-build.prompt.md)
   4. [create-actions](create-actions.prompt.md)
   5. [check](check.prompt.md)
3. Після кожного кроку перевір очікуваний результат і exit code.
4. Зупинись при першій помилці: назви крок, причину та наступну дію для користувача.
5. Повторний запуск має бути ідемпотентним: не дублювати рядки і не руйнувати сумісні зміни.
6. Наприкінці виведи підсумковий звіт зі статусом кожного кроку та diff.

# Очікувані файли

- `.gitignore`
- Весь scaffold і build/test конфігурація.
- `ci.sh`, `ci.bat`
- `.github/workflows/ci.yml`
- Результати перевірки та артефакти `build/`.

# Команди перевірки

```bash
node --version
npm --version
git --version
git rev-parse --is-inside-work-tree
./ci.sh
npx vitest run -t BasicAddition
git check-ignore build node_modules
```

# Повідомлення про помилку

При першій помилці заверши оркестрацію повідомленням:
«Init stopped at <крок>: <причина>. Жоден наступний крок не виконано».
