# Global Instructions

## Writing Style

- **No em-dashes or en-dashes.** Use regular hyphens (-) in all output - prose, bullet points,
  inline separators. Never use em-dashes or en-dashes.

## Interaction Style

- **Always ask clarifying questions before taking action.** Don't assume intent - confirm the
  approach, scope, or ambiguity before writing code or making changes. Exception: when the user
  explicitly enables "automode", switch to autonomous execution (make reasonable assumptions,
  keep moving, ask only if truly blocked).

## Code Quality - All Projects

Before committing any code, run quality checks appropriate to the project's language/build system.
This covers:

1. **Formatting** - auto-format with the project's formatter
2. **Style** - lint validation
3. **Tests** - all tests must pass
4. **Null safety** - guard nullable returns, check IO results, prefer immutability

5. **No arbitrary sleeps for synchronization** - Never use `Thread.sleep()`, `wait()`, or fixed
   delays to wait for a condition. Use condition-based waiting (polling with timeout,
   CountDownLatch, Future, Awaitility, etc.). Arbitrary sleeps are flaky and slow.

Do not commit code that has not passed quality checks.

## Git - All Projects

- **Single commit per PR**: Always squash/amend into a single commit before pushing. When making
  follow-up fixes on a PR branch, use `git commit --amend` instead of creating new commits.
  If multiple commits already exist, squash them before pushing.
- **No unrelated whitespace changes**: Do not include indentation-only or whitespace-only changes
  to lines that are not otherwise being modified. Keep diffs focused on the actual code change.
- **PR comment workflow**: When addressing PR review comments, first iterate on the fix locally
  until agreed upon. Then reply to the comment on GitHub explaining the resolution. Only push
  after replying - pushing first can mark comments as outdated and collapse them.
- **Never force push to main/master**: Force push on feature branches is normal (amend + push
  --force-with-lease). Force push to the default branch is never allowed.

## Git - Repo Creation

When creating a new GitHub repository, always configure branch protection after creation:
- Disable force pushes to the default branch
- Require pull requests (no direct pushes to main/master)

Use `gh api` to set the branch protection rule after `gh repo create`:
```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field enforce_admins=true \
  --field restrictions=null \
  --field required_status_checks=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```
