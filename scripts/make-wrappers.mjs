import { chmod, writeFile } from "node:fs/promises";

await writeFile(
  "build/hello",
  '#!/usr/bin/env sh\nexec node "$(dirname "$0")/hello.js" "$@"\n',
  "utf8",
);
await chmod("build/hello", 0o755);
await writeFile(
  "build/hello.cmd",
  '@node "%~dp0hello.js" %*\n',
  "utf8",
);
