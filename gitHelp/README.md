# Git Helpers and Workflow Recipes

This directory contains command references, standard configurations, and workflow recipes for version control using Git.

---

## Documents in This Folder

- [**`git-global-configure.md`**](git-global-configure.md): Configuring commit author identity (`user.name` and `user.email`), privacy proxy emails, default branch settings (`init.defaultBranch`), line-ending conversions (`core.autocrlf`), pull rebase strategies, and productivity aliases.
- [**`git-help.md`**](git-help.md): Comprehensive command reference for repository setup, daily staging/committing workflows, branching, remote collaboration, undo and recovery recipes (`restore`, `revert`, `reset`, `reflog`), `.gitignore` rules, and commit message conventions.

---

## How to Use These Guides

1. **Initial Setup**: Run global identity and default branch configuration on any new development machine or CI/CD runner before creating commits.
2. **Credential Safety**: Never embed authentication tokens or passwords in remote repository URLs; use SSH keys or a system credential helper.
3. **Recovery Procedures**: When undoing mistakes, prefer safe non-destructive commands (`git restore`, `git revert`) over destructive commands (`git reset --hard`, `git push --force`).
