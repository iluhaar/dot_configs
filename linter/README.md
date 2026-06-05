# Oxlint Configuration

Reusable `oxlint` configuration for modern TypeScript-first React projects.

## Usage

Run this config explicitly from a project root:

```sh
npx oxlint --config ./linter/.oxlintrc.json .
```

If you copy `.oxlintrc.json` into a project root, `oxlint` will discover it automatically:

```sh
npx oxlint .
```

## Baseline

This config is intentionally focused on correctness instead of formatting.

- `correctness`: error
- `suspicious`: error
- `perf`: warn
- `style`: off
- `pedantic`: off
- `restriction`: off
- `nursery`: off

Formatting should stay in Prettier, Biome, Oxfmt, or the project's formatter of choice.

## Error Examples

Unused variables fail lint unless the name starts with `_`.

```ts
const value = 1;
```

Use an underscore for intentionally unused values.

```ts
function handleClick(_event: MouseEvent) {
  return true;
}
```

React hooks must follow the Rules of Hooks.

```tsx
function Component({ enabled }: { enabled: boolean }) {
  if (enabled) {
    useEffect(() => {}, []);
  }

  return null;
}
```

Duplicate imports fail lint.

```ts
import { useEffect } from "react";
import { useState } from "react";
```

Circular imports fail lint when detected by the import plugin.

```ts
// a.ts
import { b } from "./b";

// b.ts
import { a } from "./a";
```

Suspicious code patterns fail lint.

```ts
if (Number.NaN === value) {
  console.log("never true");
}
```

## Warning Examples

Performance-oriented suggestions are warnings by default.

```ts
const found = items.filter((item) => item.active)[0];
```

React performance and maintainability rules can also warn instead of failing.

```tsx
function List({ items }: { items: string[] }) {
  return items.map((item, index) => <div key={index}>{item}</div>);
}
```

Warnings do not fail a normal lint run unless the command uses `--deny-warnings`.

```sh
npx oxlint --config ./linter/.oxlintrc.json --deny-warnings .
```

## Ignored Files

The config ignores common dependency, build, coverage, and generated outputs:

- `node_modules/**`
- `dist/**`
- `build/**`
- `coverage/**`
- `.next/**`
- `.nuxt/**`
- `.svelte-kit/**`
- `.turbo/**`
- `.vercel/**`
- `out/**`
- `generated/**`
- `**/__generated__/**`
- `**/*.generated.*`
- `**/*.gen.*`
- `**/*.min.*`

Test files are intentionally included and linted with the same baseline.
