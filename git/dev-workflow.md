# Git Dev Workflow

Fork-based development model. You work on your personal fork, file PRs against the target repo.

## Remote naming convention

Use named remotes that identify the org, not generic labels:

| Remote | Points to | Example |
|--------|-----------|---------|
| `origin` | Your personal fork | `git@github.com:youruser/repo.git` |
| `<org-name>` | Org/company fork (if applicable) | `git@github.com:mycompany/repo.git` |
| `upstream` | The true upstream (open source root) | `git@github.com:apache/repo.git` |

This makes multi-remote setups readable - `git fetch upstream` vs `git fetch mycompany`
makes it clear where you're pulling from.

## One-time setup

```bash
# 1. Fork the repo on GitHub (via UI or CLI)
gh repo fork <org>/<repo> --clone

# 2. Verify remotes
git remote -v
# origin    git@github.com:<you>/<repo>.git (your fork)
# upstream  git@github.com:<org>/<repo>.git (upstream)

# 3. If there are multiple upstreams (e.g., company fork + open source root):
git remote add upstream git@github.com:<oss-org>/<repo>.git
git remote add <company> git@github.com:<company>/<repo>.git
git fetch --all

# 4. Set local main to track upstream (so `git pull` on main pulls from upstream, not origin)
git fetch upstream
git reset --hard upstream/main
git branch -u upstream/main
```

## Daily workflow

```bash
# 1. Start from a fresh branch off the target remote
#    (use upstream/main for OSS PRs, <company>/main for company PRs)
git fetch upstream
git checkout -b my-feature upstream/main

# 2. Make changes, commit
git add -p
git commit -m "description of change"

# 3. Keep it as a single commit (amend for follow-up changes)
git commit --amend

# 4. Push to your fork
git push origin my-feature
# After amend, force push is expected on your branch:
git push origin my-feature --force-with-lease

# 5. Create PR against the target
gh pr create --base main
# Or specify the target repo explicitly:
gh pr create --repo <org>/<repo> --base main
```

## Sync your fork

```bash
# Update your local main from upstream
git checkout main
git fetch upstream
git rebase upstream/main
git push origin main
```

## After PR is merged

```bash
# Clean up
git checkout main
git fetch upstream
git rebase upstream/main
git push origin main
git branch -d my-feature
git push origin --delete my-feature
```

## Rules

- **Never force push to main/master** - the pre-push hook blocks this
- **Single commit per PR** - squash/amend before pushing
- **Force push on feature branches is normal** - that's how you keep a clean single commit
- **Always branch from the target remote's main** - not from your fork's main
- **Name remotes by org** - makes multi-remote setups readable
