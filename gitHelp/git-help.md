# Git Command Reference and Workflow Recipes

This guide provides a comprehensive, production-ready Git reference covering repository onboarding, daily branching workflows, remote collaboration, undo/recovery procedures, `.gitignore` configuration, and commit conventions.

---

> [!IMPORTANT]
> ### Credential Safety Notice
> **Never embed personal access tokens or passwords directly inside remote URLs** (e.g. `https://<TOKEN>@github.com/...`). URLs are stored in plaintext in `.git/config` and often leak into terminal history and CI logs.
> - Use **SSH keys** (`git@github.com:<USERNAME>/<REPOSITORY>.git`) with an SSH agent.
> - Or use the **Git Credential Manager** or a secure system credential store (`cache`, `libsecret`).

---

## 1. Repository Setup & Onboarding

### git init
Initialize a new, empty Git repository or reinitialize an existing directory.
```bash
git init
```

#### Real-World Example: Initializing a New Project
```bash
# 1. Initialize git in project root
git init

# 2. Stage files
git add README.md

# 3. Create initial commit
git commit -m "chore: initial commit"

# 4. Set default branch name to main
git branch -M main

# 5. Link remote repository (HTTPS or SSH)
git remote add origin https://github.com/<USERNAME>/<REPOSITORY>.git
# Alternatively via SSH:
# git remote add origin git@github.com:<USERNAME>/<REPOSITORY>.git

# 6. Push and set upstream tracking
git push -u origin main
```

---

## 2. Daily Workflow

### git status
Display the state of the working directory and staging area.
```bash
git status
```

#### Flags
| Flag | Description |
|---|---|
| `-s`, `--short` | Display status in short-format output |
| `-b`, `--branch` | Show branch and tracking info even in short format |

#### Real-World Example
```bash
git status -sb
```

---

### git add
Add file modifications in the working directory to the staging index.
```bash
git add <FILE_OR_DIRECTORY>
```

#### Flags
| Flag | Description |
|---|---|
| `-A`, `--all` | Stage all modified, deleted, and untracked files |
| `-p`, `--patch` | Interactively select specific hunks to stage |
| `.` | Stage all changes in current directory and subdirectories |

#### Real-World Example
```bash
# Stage specific file
git add src/index.js

# Interactively review and stage changes hunk by hunk
git add -p
```

---

### git commit
Record staged changes into a new permanent snapshot in repository history.
```bash
git commit -m "<MESSAGE>"
```

#### Flags
| Flag | Description |
|---|---|
| `-m <MSG>` | Use the given message as the commit message |
| `-a`, `--all` | Automatically stage modified and deleted files before committing |
| `--amend` | Replace the tip of the current branch with a new commit |

#### Real-World Example
```bash
git commit -m "feat(auth): add token expiration validation"
```

---

### git diff
Show differences between commits, commit and working tree, or unstaged changes.
```bash
git diff
```

#### Flags
| Flag | Description |
|---|---|
| `--staged`, `--cached` | View differences staged for the next commit |
| `HEAD` | View all changes since the last commit (staged and unstaged) |
| `--stat` | Show line addition and deletion counts per file |

#### Real-World Example
```bash
# Inspect staged changes before committing
git diff --staged
```

---

### git log
Display commit history logs.
```bash
git log --oneline --graph --decorate
```

#### Flags
| Flag | Description |
|---|---|
| `--oneline` | Display each commit on a single line |
| `--graph` | Draw an ASCII graphical representation of commit history |
| `-n <COUNT>` | Limit output to the specified number of commits |

#### Real-World Example
```bash
git log --graph --oneline -n 10
```

---

## 3. Branching & Merging

### git branch
List, create, or delete branches.
```bash
git branch <BRANCH_NAME>
```

#### Flags
| Flag | Description |
|---|---|
| `-a`, `--all` | List both local and remote-tracking branches |
| `-d` | Delete branch safely (fails if branch has unmerged changes) |
| `-D` | Force delete branch regardless of merge status |
| `-m` | Rename current branch |

#### Real-World Example
```bash
# List all branches
git branch -a

# Delete a merged feature branch
git branch -d feature/login-page
```

---

### git switch (legacy equivalent: git checkout)
Switch working branches or create and switch to a new branch.
```bash
git switch <BRANCH_NAME>
```

#### Flags
| Flag | Description |
|---|---|
| `-c <BRANCH>` | Create and switch to a new branch in one command |

#### Real-World Example
```bash
# Create and check out a new feature branch
git switch -c feature/user-profile
```

---

### git merge
Join two or more development histories together into the active branch.
```bash
git merge <BRANCH_NAME>
```

#### Flags
| Flag | Description |
|---|---|
| `--no-ff` | Create a merge commit even when fast-forward is possible |
| `--abort` | Abort an in-progress merge conflict and restore previous state |

#### Real-World Example
```bash
# Merge feature branch into main with a merge commit
git switch main
git merge --no-ff feature/user-profile
```

---

### git rebase
Reapply commits from the current branch on top of another base tip.
```bash
git rebase <UPSTREAM_BRANCH>
```

#### Real-World Example
```bash
# Rebase feature branch on top of latest main
git switch feature/user-profile
git rebase main
```

> [!WARNING]
> Never rebase commits that have already been pushed to a public or shared collaborative branch. Rebasing rewrites commit hashes and disrupts history for other contributors.

---

## 4. Remote Repositories & Collaboration

### git remote
Manage the set of tracked remote repositories.
```bash
git remote -v
```

#### Real-World Example
```bash
# List configured remotes with URLs
git remote -v

# Add a remote repository
git remote add origin https://github.com/<USERNAME>/<REPOSITORY>.git

# Change remote URL
git remote set-url origin git@github.com:<USERNAME>/<REPOSITORY>.git
```

---

### git fetch
Download objects, refs, and branches from a remote repository without altering local branches.
```bash
git fetch <REMOTE>
```

#### Real-World Example
```bash
# Fetch all remote branches and prune deleted remote refs
git fetch origin --prune
```

---

### git pull
Fetch from and integrate with another repository or a local branch.
```bash
git pull <REMOTE> <BRANCH>
```

#### Flags
| Flag | Description |
|---|---|
| `--rebase` | Rebase local commits on top of incoming changes instead of creating merge commits |

#### Real-World Example
```bash
# Pull latest changes cleanly via rebase
git pull --rebase origin main
```

---

### git push
Update remote refs along with associated objects.
```bash
git push <REMOTE> <BRANCH>
```

#### Flags
| Flag | Description |
|---|---|
| `-u`, `--set-upstream` | Set tracking reference for subsequent bare pushes |
| `--force-with-lease` | Safer force push: verifies remote branch has not updated before overwriting |

#### Real-World Example
```bash
# Push new branch and configure upstream
git push -u origin feature/user-profile
```

> [!WARNING]
> **Dangerous Command: `git push --force`**  
> Blind force pushing overwrites remote branch history unconditionally. If another contributor pushed commits in the meantime, their work will be permanently erased from the remote repository.  
> **Safer Alternative**: Always use `git push --force-with-lease`. This ensures Git rejects the push if anyone else updated the remote branch since your last fetch.

---

## 5. Undo, Recovery & Cleaning

### Safe Option 1: git restore (unstage or discard uncommitted changes)
Restore working tree files or discard changes in the staging index.
```bash
# Unstage a file without losing modifications (keeps edits in working tree)
git restore --staged <FILE>

# Discard working tree changes to match HEAD
git restore <FILE>
```

---

### Safe Option 2: git revert (undo committed history safely)
Create a new commit that applies the inverse of an existing commit.
```bash
git revert <COMMIT_HASH>
```

#### Real-World Example
```bash
# Safely revert commit without rewriting history
git revert a1b2c3d
```

---

### Moderate Option: git reset (--soft vs --mixed)
Move branch HEAD to a previous commit without discarding working directory changes.
```bash
# Keep changes staged in the index (ready to recommit)
git reset --soft HEAD~1

# Keep changes unstaged in the working tree (default behavior)
git reset --mixed HEAD~1
```

---

### Destructive Option: git reset --hard
Reset the index and working tree. Any changes to tracked files since `<COMMIT>` are permanently discarded.
```bash
git reset --hard HEAD~1
```

> [!WARNING]
> `git reset --hard` completely destroys uncommitted changes in tracked files and moves branch history backwards. Any unstaged or uncommitted work cannot be recovered.  
> **Safer Alternative**: Stash changes before resetting (`git stash push -m "backup"`), or create a temporary recovery branch (`git branch backup-branch`) before executing a hard reset.

---

### Emergency Recovery: git reflog
Manage reflog information, recording every reference update and HEAD movement in the repository.
```bash
git reflog
```

#### Real-World Example: Recovering a Lost Commit after `reset --hard`
```bash
# 1. View reflog history to find the commit hash before the reset
git reflog
# Output example:
# 3a1b2c4 HEAD@{0}: reset: moving to HEAD~1
# 9f8e7d6 HEAD@{1}: commit: feat: important work

# 2. Restore branch pointer to the lost commit
git reset --hard HEAD@{1}
```

---

### git clean
Remove untracked files and directories from the working tree.
```bash
# Always perform a dry run first!
git clean -nd

# Perform the clean after verifying output
git clean -fd
```

> [!WARNING]
> Untracked files deleted with `git clean -fd` are not tracked by Git and cannot be recovered from history.  
> **Safer Alternative**: Always run `git clean -nd` first to preview exactly what will be removed.

---

## 6. Stashing Temporary Work

### git stash
Stash modified tracked files and staged changes in a dirty working directory to allow switching branches cleanly.
```bash
# Stash current work with an informative label
git stash push -m "<DESCRIPTION>"

# List all existing stashes
git stash list

# Re-apply and remove the most recent stash
git stash pop

# Discard the most recent stash
git stash drop
```

#### Real-World Example
```bash
git stash push -m "WIP: auth middleware"
git switch hotfix/security-patch
# Work on hotfix...
git switch feature/auth
git stash pop
```

---

## 7. Tagging Releases

### git tag
Create, list, or verify signed tags representing release milestones.
```bash
# Create an annotated tag
git tag -a v1.0.0 -m "Release v1.0.0"

# List tags
git tag -l

# Push specific tag to remote
git push origin v1.0.0

# Push all local tags to remote
git push origin --tags
```

---

## 8. `.gitignore` Basics

A `.gitignore` file specifies intentionally untracked files that Git should ignore. Files already tracked by Git are not affected.

### Common Syntax Patterns
```gitignore
# 1. Comments start with hash
# Ignore temporary and log files
*.log
*.tmp
*.swp

# 2. Ignore entire directories (trailing slash)
node_modules/
vendor/
dist/
.idea/
.vscode/

# 3. Ignore root-level configuration files containing credentials
/.env
/.env.local

# 4. Negation: ignore all logs EXCEPT specific file
*.log
!important.log
```

### Stop Tracking an Already-Tracked File
If a file was committed before being added to `.gitignore`, remove it from the index without deleting it from your local disk:
```bash
git rm --cached <FILE>
git commit -m "chore: stop tracking <FILE>"
```

---

## 9. Commit Message Conventions

Adopting standard commit message conventions improves repository readability and enables automated changelog generation.

### Conventional Commits Format
```text
<type>(<scope>): <short imperative description>

[optional body explaining what and why, not how]

[optional footer: e.g., Closes #123]
```

### Common Types
| Type | Purpose | Example |
|---|---|---|
| `feat` | A new user-facing feature | `feat(api): add endpoint for user profile export` |
| `fix` | A bug fix | `fix(auth): prevent session timeout during token renewal` |
| `docs` | Documentation changes only | `docs(readme): update deployment prerequisites` |
| `style` | Formatting changes (whitespace, semi-colons, no code changes) | `style(lint): format codebase according to prettier` |
| `refactor` | Code change that neither fixes a bug nor adds a feature | `refactor(db): optimize connection pool acquisition` |
| `test` | Adding or correcting existing tests | `test(auth): add unit tests for password validator` |
| `chore` | Changes to build process, dependencies, or auxiliary tools | `chore(deps): update dependency packages to latest versions` |

---

## 10. Troubleshooting Common Issues

### Resolving Merge Conflicts
When Git cannot automatically reconcile diverging commits, conflict markers are inserted into files:
```text
<<<<<<< HEAD
const apiUrl = "https://api.internal.local";
=======
const apiUrl = "https://api.staging.example.com";
>>>>>>> feature/api-upgrade
```
1. Open the conflicted files and edit them to the desired final state.
2. Remove all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
3. Stage resolved files:
   ```bash
   git add <RESOLVED_FILE>
   ```
4. Finalize the merge:
   ```bash
   git commit -m "merge: resolve api configuration conflict"
   ```

### Recovering from Detached HEAD
If `git status` reports `HEAD detached at <COMMIT_HASH>`:
```bash
# Create a new branch retaining commits made while detached
git switch -c recovery-branch

# Or return to your main branch discarding detached experiments
git switch main
```
