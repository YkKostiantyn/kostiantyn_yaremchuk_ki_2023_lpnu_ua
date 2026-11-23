---
description: Перевірити Git і доповнити .gitignore без комітів
agent: build-engineer
---

# Передумови

- Команда `git` доступна.
- Поточна директорія є коренем репозиторію або очікується перевірка репозиторію.

# Дії

1. Виконай `git rev-parse --is-inside-work-tree`.
2. Визнач поточну гілку через `git branch --show-current`.
3. Якщо `.gitignore` відсутній, створіть його.
4. Додай за потреби без дублювання рядки:
   `node_modules/`, `build/`, `dist/`, `coverage/`, `*.log`, `.env*`, `.DS_Store`.
5. Після змін виконай `git status --short --branch`.
6. Не створюй коміт, не пуш, не змінюй гілку та не змінюй історію.

# Очікувані файли

- `.gitignore`

# Команди перевірки

```bash
git rev-parse --is-inside-work-tree
git branch --show-current
git check-ignore build node_modules
git status --short --branch
```

# Повідомлення про помилку

Якщо поточна директорія не належить Git-репозиторію, зупинись: «Не виявлено Git-репозиторій». Якщо `.gitignore` не можна доповнити або перевірка ігнорування не проходить, перерви крок із описом конкретної помилки.
