# devkit

One-command setup for a developer workstation. Workspaces with AI agents, shell config, Git
workflow, IDE settings, language runtimes - everything you need on a fresh environment.

## Quick start

```bash
git clone https://github.com/mayankshriv/devkit.git ~/devkit
cd ~/devkit
./install.sh
```

Then add one line to your `~/.zshrc`:

```bash
source ~/devkit/shell/devkit.zsh
```

Open a new terminal. Done.

> **Platform:** Built for macOS. Most modules (shell, git, claude, tabs, tmux) work on Linux.
> macOS-specific pieces: Brewfile, iTerm2 profile, `jdk()` function, SSH Keychain.

## What's included

| Module | What it does |
|--------|-------------|
| [shell/](shell/) | Prompt with git branch, aliases, functions, completions |
| [git/](git/) | Gitconfig, global gitignore, pre-push hook, [dev workflow](git/dev-workflow.md) |
| [tmux/](tmux/) | Alt+1-7 window switching, mouse, scrollback, status bar |
| [claude/](claude/) | Permissions allowlist, statusline, global instructions, lint skill |
| [tabs/](tabs/) | Named tabs with Claude in every pane (herdr or tmux) |
| [intellij/](intellij/) | Java code style, VM options, plugin recommendations |
| [terminal/](terminal/) | iTerm2 profile (font, colors) |
| [cloud/](cloud/) | AWS CLI, gcloud, kubectl setup and context switching |
| [languages/](languages/) | Java (jenv), Node (nvm), Python (pyenv+uv), Rust (rustup) |
| [ssh/](ssh/) | SSH config template (ed25519 + Keychain) |

## Tabs

Define your projects in `~/.config/devkit/tabs.yaml`:

```bash
mkdir -p ~/.config/devkit
cp ~/devkit/tabs/tabs.example.yaml ~/.config/devkit/tabs.yaml
# Edit with your projects
```

```yaml
workspaces:
  - name: my-project
    root: ~/projects/my-project
    tabs:
      - label: code
        panes:
          - command: claude
```

Then use these commands:

| Command | What it does |
|---------|-------------|
| `tabs` | Launch or reattach to all tabs |
| `tabls` | Show all tabs |
| `tabadd <name> [dir]` | Add a tab on the fly |
| `tabrm <name>` | Remove a tab |
| `taboff` | Stop all tabs |

Uses [herdr](https://herdr.dev) (agent-aware multiplexer - sessions survive lid close) with
tmux as fallback.

## Customization

### Override, don't fork

The source model means devkit layers on top of your existing setup:

- **Shell** - `source ~/devkit/shell/devkit.zsh` adds to your shell; it doesn't replace your `.zshrc`
- **Git** - `include.path` merges devkit aliases into your gitconfig; your name/email stay

### Local config files

Machine-specific configs live outside the repo so they survive `rm -rf ~/devkit`:

| File | What goes there |
|------|----------------|
| `~/.config/devkit/tabs.yaml` | Your tab/workspace layout (see [Tabs](#tabs)) |
| `shell/env.local` | API keys, tokens, env vars (gitignored) |
| `.claude/settings.local.json` | Claude Code permission overrides (gitignored) |

`tabs.yaml` is the only one stored in `~/.config`. The other two are gitignored in-repo files -
back them up separately if needed.

### Add your own

- **Aliases** - edit `shell/aliases.zsh`
- **Functions** - edit `shell/functions.zsh`
- **Claude instructions** - edit `claude/CLAUDE.md`
- **Brew packages** - edit `Brewfile`
- **Skills** - add directories under `claude/skills/`

## Git dev workflow

Fork-based development. See [git/dev-workflow.md](git/dev-workflow.md) for the full guide.

```bash
# Start a feature
git fetch upstream
git checkout -b my-feature upstream/main

# Work, commit, amend
git commit -m "my change"
git commit --amend              # follow-up fixes

# Push and PR
git push origin my-feature --force-with-lease
gh pr create --base main
```

**Protected branches**: A global pre-push hook blocks force pushes to main/master.
Force push on feature branches is normal and expected.

## Cloud tools

Setup scripts for AWS, GCP, and Kubernetes. Run individually:

```bash
./cloud/aws.sh       # AWS CLI + initial config
./cloud/gcloud.sh    # Google Cloud SDK + gcloud init
./cloud/kubectl.sh   # kubectl + context check
```

Shell helpers (loaded automatically via `devkit.zsh`):

| Command | What it does |
|---------|-------------|
| `awsprofile [name]` | Show or switch AWS profile |
| `gproject [id]` | Show or switch gcloud project |
| `kctx [name]` | Show or switch kubectl context |
| `kns [name]` | Show or switch kubectl namespace |

## Keeping it synced

```bash
# Second machine
git clone https://github.com/mayankshriv/devkit.git ~/devkit
cd ~/devkit && ./install.sh

# After pulling updates
cd ~/devkit && git pull && ./install.sh
```

`install.sh` is idempotent - it backs up existing files before replacing them and skips
what's already set up.

## Structure

```
devkit/
├── install.sh                  # One command setup
├── Brewfile                    # All brew packages
├── shell/
│   ├── devkit.zsh              # Source this from ~/.zshrc
│   ├── aliases.zsh
│   ├── functions.zsh
│   └── env.local               # Secrets (gitignored)
├── git/
│   ├── gitconfig               # Aliases, settings
│   ├── ignore                  # Global gitignore
│   ├── hooks/pre-push          # Block force push to main
│   └── dev-workflow.md         # Fork-based dev guide
├── ssh/
│   └── config                  # Template
├── tmux/
│   └── tmux.conf
├── claude/
│   ├── settings.json           # Permissions allowlist
│   ├── CLAUDE.md               # Global instructions
│   ├── statusline-command.sh   # Model, cost, tokens, git
│   └── skills/
│       ├── lint/SKILL.md       # Multi-language lint skill
│       └── dev-framework/SKILL.md  # Feature development framework
├── intellij/
│   ├── codestyle.xml           # Java code style
│   ├── idea.vmoptions          # 8GB heap
│   └── README.md
├── terminal/
│   ├── iterm2-profile.json     # Font + color palette
│   └── README.md
├── cloud/
│   ├── aws.sh                  # AWS CLI setup
│   ├── gcloud.sh               # Google Cloud SDK setup
│   └── kubectl.sh              # Kubernetes CLI setup
├── tabs/
│   ├── tabs.zsh                # tabs/tabls/taboff commands
│   └── tabs.example.yaml      # Template (copy to ~/.config/devkit/tabs.yaml)
└── languages/
    ├── java.sh                 # jenv + JDK setup
    ├── node.sh                 # nvm setup
    ├── python.sh               # pyenv + uv setup
    └── rust.sh                 # rustup setup
```

## License

MIT
