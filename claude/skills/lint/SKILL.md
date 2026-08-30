---
name: lint
description: Run code quality checks - formatting, style, and tests. Adapt commands to your project's build system.
argument-hint: "[module-path]"
---

# Code Quality Checks

Run all code quality checks on the specified module. If no module is provided, ask which module
to check.

## Checks (run in order, stop on first failure)

Adapt the commands below to your project's build system.

### Java (Maven)

```bash
# 1. Auto-format
./mvnw spotless:apply -pl $ARGUMENTS -q

# 2. Validate style
./mvnw checkstyle:check -pl $ARGUMENTS -q

# 3. Check for deprecation warnings
./mvnw compile -pl $ARGUMENTS -Dmaven.compiler.showDeprecation=true 2>&1 | grep "deprecat"

# 4. Run tests
./mvnw test -pl $ARGUMENTS
```

### Node (npm/pnpm)

```bash
# 1. Format
pnpm prettier --write .

# 2. Lint
pnpm eslint .

# 3. Test
pnpm test
```

### Python (ruff/pytest)

```bash
# 1. Format
ruff format .

# 2. Lint
ruff check . --fix

# 3. Test
pytest
```

### Rust (cargo)

```bash
# 1. Format
cargo fmt

# 2. Lint
cargo clippy -- -D warnings

# 3. Test
cargo test
```

## Final review

After all automated checks pass, scan the changed code for:
- Null dereference risks - guard nullable returns before access
- Resource leaks - ensure close/cleanup in error paths
- Unchecked return values (File.delete, IO operations)
- Fields that should be final/const
- Missing tests for new code paths

## Report

After all checks, report:
- Number of tests run and passed
- Any warnings or issues found and fixed
- Confirmation that all checks are green
