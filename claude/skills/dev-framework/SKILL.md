---
name: dev-framework
description: End-to-end development framework for building production-quality features. Covers design through shipping with iterative review cycles. Use when starting a new feature, library, or significant implementation.
argument-hint: "[feature-name]"
---

# Development Framework

A repeatable process for building production-quality features.

## Phase 1: Design Before Code

### 1.1 Research the problem space
- Search for industry standards and existing implementations
- Understand the native format/protocol you're targeting
- Identify what the industry considers best practices and defaults

### 1.2 Design document
- Write a design doc BEFORE writing code
- Cover: motivation, API surface, data flow, configuration, known trade-offs
- Include multiple approaches with pros/cons table
- Get alignment on the approach before implementing

### 1.3 Prototype multiple approaches
- Implement 2-3 candidate approaches (even rough)
- Benchmark all of them with realistic data sizes
- Select based on data, not intuition
- Keep rejected approaches on an archive branch for reference

## Phase 2: Implementation

### 2.1 Start with the API
- Design the public API first: constructor, main method, config, result type
- Keep it minimal - one class, one method, one config
- Don't introduce interfaces/factories/enums until you have 2+ implementations
- YAGNI: no abstractions for hypothetical future needs

### 2.2 Build incrementally with tests
- Write tests alongside code, not after
- Start with happy path, then edge cases, then error cases
- Test each data type individually (lossless round-trip)
- Test configuration (JSON serde round-trip for config classes)
- Test negative paths (invalid input, missing files, bad config)

### 2.3 Config design
- JSON-serializable from day one (will be embedded in task configs)
- Sensible defaults matching industry standards
- Validation in setters
- `@JsonIgnoreProperties(ignoreUnknown = true)` for forward compatibility (Java)

## Phase 3: Iterative Review Cycles

### 3.1 Automated code review
- Run code review after each significant change
- Fix all CRITICAL and MAJOR findings before next round
- Reply to reviewer comments with fix references or "by design" justification
- Track review rounds in progress log

### 3.2 Common findings pattern (expect these)
- **Round 1-2:** Obvious bugs - overflow, resource leaks, null handling
- **Round 3-4:** Architecture - memory model, streaming vs materialization, pre-allocation
- **Round 5-6:** Edge cases - empty arrays, mixed types, special characters in names
- **Round 7-8:** Polish - naming, docs, dead code, duplicate code
- **Round 9+:** Diminishing returns - stop when 0 critical/major

### 3.3 Address all review comments
- Reply to every comment (fixed, by design, stale, not a bug)
- Don't leave unreplied comments - reviewers check this
- Track which comments are on deleted files (stale)

## Phase 4: Quality Hardening

### 4.1 Run `/lint` before every commit
- Formatting (auto-formatter + license headers)
- Style (linter validation)
- Deprecation warnings (zero tolerance)
- Tests (all passing)
- Null safety scan

### 4.2 Deprecation audit
- Replace deprecated APIs with non-deprecated alternatives
- Suppress only when no replacement exists, with a comment explaining why

### 4.3 IDE warning sweep
- NPE: never dereference potentially-null without guard
- Resource cleanup return values checked
- Fields `final`/`const`/`readonly` where possible
- No fully-qualified class names - use imports
- `toString()` on value classes
- Comment on intentional code duplication

### 4.4 Document all limitations
- Every unsupported feature/type: TODO in code + Known Limitations in PR
- Every design trade-off: doc comment explaining why
- Cross-reference: code TODO, PR description, progress log

## Phase 5: Benchmarking

### 5.1 Design benchmark sweeps
- Identify the tuning parameters
- Design focused experiments: vary one parameter, fix others
- Include baseline comparison
- Measure: write time, read time, file size, structural metrics

### 5.2 Run and document results
- Create a separate benchmark report (don't overwrite earlier benchmarks)
- Include industry comparison table
- Derive default config recommendations from data
- Gate benchmarks behind a flag (don't run in CI)

## Phase 6: Shipping

### 6.1 PR hygiene
- Single commit (amend, don't create new commits)
- Rebase onto latest main before final push
- PR description: summary, known limitations, benchmark results, test plan
- Reply to all review comments

### 6.2 Progress log
- Update after every significant change
- Track: review rounds, fixes, test count, benchmark results
- This is your audit trail

### 6.3 Pre-merge checklist
- [ ] All tests pass locally
- [ ] CI green (or failures unrelated to your changes)
- [ ] Zero deprecation warnings
- [ ] Zero unreplied review comments
- [ ] All limitations documented in code + PR
- [ ] Progress log up to date
- [ ] Config is serializable with serde tests
- [ ] Benchmark results documented

## Anti-patterns to Avoid

| Anti-pattern | What to do instead |
|-------------|-------------------|
| Building 3 implementations and shipping all 3 | Prototype all, benchmark, ship one, archive the rest |
| Interface + Factory for one implementation | Just use the class directly. Add abstraction when needed. |
| Materializing everything in memory | Stream where possible, batch where needed |
| Fixing all review findings in one giant commit | Fix per round, verify tests pass between rounds |
| Ignoring IDE warnings | Fix them - the reviewer uses an IDE too |
| Writing tests after the code is "done" | Write tests alongside, they catch design issues early |
| Committing benchmark result files | Gate behind a flag, results in docs not committed artifacts |
| Documenting limitations only in PR description | Also in code (TODO + doc comments) - PR descriptions get stale |
