---
description: Створити GitHub Actions CI matrix workflow
agent: build-engineer
---

# Передумови

Виконай інструкції skill: [github-actions](../skills/github-actions/SKILL.md).

- Викликати skill `github-actions`.
- Існують `ci.sh` і `ci.bat`.
- Node.js у workflow має бути версії 22.

# Дії

1. Завантаж skill `github-actions`.
2. Створіть `.github/workflows/ci.yml` з однією job і matrix.
3. Налаштуй тригери та upload-artifact.
4. Перевір відсутність секретів і сторонніх службових credential.

# Очікувані файли

- `.github/workflows/ci.yml`

# Команди перевірки

```bash
test -f .github/workflows/ci.yml
grep -q "ubuntu-latest" .github/workflows/ci.yml
grep -q "windows-latest" .github/workflows/ci.yml
grep -q "macos-latest" .github/workflows/ci.yml
grep -q "ci.sh" .github/workflows/ci.yml
grep -q "ci.bat" .github/workflows/ci.yml
grep -q "actions/upload-artifact" .github/workflows/ci.yml
```

# Повідомлення про помилку

Якщо workflow відсутній, неповний або містить секрет/зовнішній credential-параметр, зупинись і поверни точний FAIL-опис.
