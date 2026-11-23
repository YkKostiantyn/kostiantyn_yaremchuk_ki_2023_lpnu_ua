---
description: Без змін перевірити агент, проєкт і Git-ігнорування
agent: build-engineer
---

# Передумови

- Команди перевірки мають читати стан репозиторію лише без змін.
- Рекомендується запускати після `/init`.
- На Windows перевірку `./ci.sh` замінюють еквівалентним запуском `ci.bat`.

# Дії

1. Перевір наявність усіх agent-файлів: manifest, три SKILL.md, шість prompt-файлів і документацію.
2. Перевір manifest на секції Роль, Заборонені дії та Критерії успішного завершення.
3. Перевір `.github/workflows/ci.yml`: одну job, matrix для Ubuntu/Windows/macOS, тригери push/pull_request, запуск тільки ci-скриптів і відсутність прямих команд `npm`.
4. Перевір наявність проєктних файлів і виконуваних артефактів.
5. Запусти `./ci.sh` у середовищі Linux/macOS або `ci.bat` у Windows.
6. Запусти `npx vitest run -t BasicAddition`.
7. Виконай `git check-ignore build node_modules`.
8. Перевір, що кожен SKILL.md містить розділи «Вхідні дані», «Перевірки», «Приклад входу» та «Типовий сценарій помилки».
9. Перевір, що `init.prompt.md` посилається на 5 промпт-файлів у правильному порядку: git-init, create-project, create-build, create-actions, check.
10. Скануй конфігураційні файли workflow і репозиторію на явні токени/секрети без читання або розкриття секретів.
11. Створення `node_modules/` і `build/` під час CI допустиме, бо вони ігноруються Git.
12. Після перевірок виконай `git status --porcelain`; якщо змінились відстежувані файли, пункт repository-state — FAIL.
13. Нічого не змінюй у відстежуваних Git-файлах і виведи таблицю PASS/FAIL.
14. Завершись ненульовим кодом, якщо хоча б один пункт FAIL.

# Очікувані файли

- Усі файли manifest/skills/prompts/docs.
- `package.json`, `tsconfig.json`, `src/hello.ts`, `src/math.ts`, `tests/math.test.ts`.
- `ci.sh`, `ci.bat`, `.github/workflows/ci.yml`.
- `build/hello.js`, `build/hello`, `build/hello.cmd`.

# Команди перевірки

```bash
test -f .github/agents/build-engineer.agent.md
test -f .github/skills/project-scaffold/SKILL.md
test -f .github/skills/build-and-test/SKILL.md
test -f .github/skills/github-actions/SKILL.md
test -f docs/architecture.md
test -f docs/usage.md
test -f docs/ai-log.md
./ci.sh
npx vitest run -t BasicAddition
git check-ignore build node_modules
git status --porcelain
```

# Повідомлення про помилку

Якщо перевірка виявляє хоч один FAIL, виведи таблицю PASS/FAIL і завершися з помилкою: «Check failed: один або кілька пунктів не пройшли». Не змінюй файли під час check.
