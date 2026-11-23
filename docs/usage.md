# Використання

## Запуск агента у VS Code

1. Відкрийте репозиторій у VS Code.
2. Відкрийте панель GitHub Copilot Chat.
3. Виберіть custom agent `build-engineer`.
4. Запустіть повний ідемпотентний цикл:

   ```text
   /lab-init
   ```

5. Для перевірки без змін запустіть:

   ```text
   /check
   ```

Інші команди доступні окремо:

- `/git-init` — перевірити Git і доповнити `.gitignore`
- `/create-project` — створити TypeScript scaffold
- `/create-build` — налаштувати збірку, Vitest та ci-скрипти
- `/create-actions` — створити GitHub Actions workflow

## Локальна збірка

Linux або macOS:

```bash
./ci.sh
```

Windows у cmd або через GitHub Actions:

```bat
ci.bat
```

Скрипти виконують `npm ci`, `npm run build`, `npm test`, перевірку програми та повертають ненульовий код при помилці.

Якщо ще немає `package-lock.json`, агент один раз виконує `npm install`, щоб створити lock-файл; `.gitignore` його не замінює. Подальша перевірка CI використовує детермінований `npm ci`. Після `npm run build` npm автоматично виконує `scripts/make-wrappers.mjs` через `postbuild`, тому каталог `build/` не треба комітити або створювати вручну.

Фільтр тесту `BasicAddition` запускається так:

```bash
npx vitest run -t BasicAddition
```

## Запуск Hello World

Після успішної збірки:

```bash
./build/hello
```

Очікуваний вивід:

```text
Hello, World!
```

На Windows:

```bat
build\hello.cmd
```

`/check` не змінює відстежувані Git-файли. Створення ігнорованих каталогів `node_modules/` і `build/` під час перевірки допустиме; наприкінці перевірка виконує `git status --porcelain` і відзначає FAIL, якщо змінено будь-який відстежуваний файл.
