# Git Configuration Guide (Global & Local)

Git stores configuration options at three distinct levels:
1. **System** (`/etc/gitconfig`): Applied to all users on the operating system.
2. **Global** (`~/.gitconfig` or `~/.config/git/config`): Applied to all repositories for the current operating system user.
3. **Local** (`.git/config` inside a repository): Overrides global settings specifically for that single repository.

---

## 1. Configuring Commit Identity

Every commit records the author's name and email address. You can set a global identity for all projects, or override it inside a specific repository (e.g. using a work email for company repositories and a personal email for open source).

### git config (user identity)
Set author name and email address for commit attribution.
```bash
git config --global user.name "<YOUR_NAME>"
git config --global user.email "<YOUR_EMAIL>"
```

#### Flags
| Flag | Description |
|---|---|
| `--global` | Write to global `~/.gitconfig` (all repositories for current user) |
| `--local` | Write to `.git/config` (current repository only; default if inside a repo) |

#### Real-World Example: Setting Global Identity
```bash
git config --global user.name "<YOUR_NAME>"
git config --global user.email "<YOUR_EMAIL>"
```

#### Real-World Example: Overriding per Repository
```bash
cd /path/to/specific/repo
git config user.name "<YOUR_NAME>"
git config user.email "<YOUR_EMAIL>"
```

### Privacy Note: GitHub No-Reply Email
To prevent your private email address from being exposed in public commit logs and web scraping tools, configure GitHub's privacy proxy address:
1. Navigate to **GitHub Settings** $\to$ **Emails**.
2. Enable **Keep my email addresses private** and **Block command line pushes that expose my email**.
3. Use the provided no-reply address:
   ```bash
   git config --global user.email "<ID>+<USERNAME>@users.noreply.github.com"
   ```

---

## 2. Essential Configuration Best Practices

### Default Initial Branch Name
Ensure new repositories initialized with `git init` automatically name the primary branch `main`:
```bash
git config --global init.defaultBranch main
```

---

### Pull Strategy (Rebase vs Merge)
Configure Git's behavior when integrating upstream changes via `git pull`:
```bash
git config --global pull.rebase true
```

#### Understanding the Trade-Offs
- **Linear History (`pull.rebase true`)**: Reapplies your local commits on top of incoming remote commits without creating unnecessary "Merge branch 'main' of ..." merge commits. Keeps history clean and easy to read.
- **Merge Commits (`pull.rebase false`)**: Creates a merge commit whenever branches diverge. Preserves exact chronological order, but creates cluttered merge graph bubbles.
- *Trade-off*: When conflicts occur, `rebase` requires resolving conflicts per commit sequentially, whereas `merge` resolves conflicts in a single merge commit.

---

### Preferred Terminal Editor
Set your default command-line editor for writing commit messages and interactive rebasing:
```bash
# Nano (beginner friendly)
git config --global core.editor "nano"

# Vim
git config --global core.editor "vim"

# Visual Studio Code
git config --global core.editor "code --wait"
```

---

### Line Ending Handling (`core.autocrlf`)
Different operating systems use different newline characters (Windows uses Carriage Return + Line Feed `CRLF`, while Linux and macOS use Line Feed `LF`). Misconfigured line endings produce noisy diffs where every line appears modified.

#### Configuration by Operating System
- **Windows**: Convert CRLF to LF upon commit, and convert LF back to CRLF on checkout:
  ```bash
  git config --global core.autocrlf true
  ```
- **Linux & macOS**: Convert CRLF to LF upon commit, but keep LF on checkout:
  ```bash
  git config --global core.autocrlf input
  ```
- **Cross-Platform Repositories (Managed via `.gitattributes`)**: Keep line endings unchanged and rely on `.gitattributes`:
  ```bash
  git config --global core.autocrlf false
  ```

---

## 3. Productivity Aliases

Create convenient command shortcuts to accelerate everyday Git operations:

```bash
# Concise status
git config --global alias.st "status -sb"

# Fast branch and checkout
git config --global alias.co "checkout"
git config --global alias.sw "switch"
git config --global alias.br "branch"

# Pretty log graph
git config --global alias.lg "log --graph --oneline --decorate -n 15"

# Unstage files
git config --global alias.unstage "restore --staged"

# Show last commit details
git config --global alias.last "log -1 HEAD --stat"
```

---

## 4. Viewing Configuration & Origins

### git config --list
Display all active configuration settings along with the specific file origin defining each value.
```bash
git config --list --show-origin
```

#### Flags
| Flag | Description |
|---|---|
| `-l`, `--list` | List all variables set in configuration files |
| `--show-origin` | Augment output with the file origin of each setting |
| `--show-scope` | Display whether variable is system, global, or local |

#### Real-World Example
```bash
git config --list --show-origin
# Output example:
# file:/home/user/.gitconfig    user.name=<YOUR_NAME>
# file:/home/user/.gitconfig    user.email=<YOUR_EMAIL>
# file:/home/user/.gitconfig    init.defaultbranch=main
```
