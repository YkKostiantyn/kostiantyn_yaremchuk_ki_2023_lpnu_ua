---
name: github-actions
description: Створює GitHub Actions CI workflow для Ubuntu, Windows і macOS без секретів.
---

# Коли застосовувати

Застосовуй для створення або перевірки `.github/workflows/ci.yml` після наявності `ci.sh` і `ci.bat`.

# Вхідні дані

- Гілки: `main`, `master`, `develop`.
- Push для гілок `feature/**`.
- Pull request для `main`, `master`, `develop`.
- Matrix ОС: `ubuntu-latest`, `windows-latest`, `macos-latest`.
- Node.js 22.

# Результат (файли)

- `.github/workflows/ci.yml`

# Кроки

1. Створіть workflow із однією job і matrix `os`.
2. Налаштуйте triggers `push` і `pull_request` на вимагані гілки; push для `feature/**`.
3. Додайте одну job із `fail-fast: false`, `permissions: contents: read` і matrix для Ubuntu/Windows/macOS.
4. Додайте кроки `actions/checkout@v4`, `actions/setup-node@v4` із Node 22 та `cache: npm`.
5. Для Linux/macOS запускайте `bash ./ci.sh`. Для Windows додайте окремий крок із `shell: cmd` і командою `ci.bat`.
6. Додайте `actions/upload-artifact@v4` із каталогом `build/`, `name: hello-${{ matrix.os }}` і `if-no-files-found: error`.
7. Не додавай environment variables, credentials, secrets або сторонні службові кроки і не вставляй прямі npm-команди поза ci-скриптом.

# Перевірки (точні команди)

```bash
test -f .github/workflows/ci.yml
grep -E "ubuntu-latest|windows-latest|macos-latest" .github/workflows/ci.yml
grep -E "ci\\.sh|ci\\.bat" .github/workflows/ci.yml
grep -E "actions/upload-artifact|build/" .github/workflows/ci.yml
grep -E "node-version: ['\\\"]?22" .github/workflows/ci.yml
```

# Приклад входу

```text
Потрібен matrix CI для Ubuntu, Windows і macOS.
Запускати ci.sh або ci.bat відповідно до ОС.
```

# Очікуваний результат

Workflow валідний, містить одну job, усі три ОС, Node 22, усі тригери, запуск тільки ci-скриптів і upload-artifact із назвою ОС.

# Типовий сценарій помилки

- Якщо matrix назви або операційна система не узгоджені, виправ `.github/workflows/ci.yml`.
- Якщо у workflow знайдено прямі npm-команди поза ci-скриптом, видали їх з цього workflow.
- Якщо знайдено секрет або credential, негайно не копіюй і не розкривай його; видали секретну конфігурацію та надай лише узагальнений опис.
