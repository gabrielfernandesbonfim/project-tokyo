---
name: worktree-workflow
description: Use when the user wants to start, resume, finish, or clean up a task in this Spec-Kit project. Triggers on phrases like "start task", "create worktree", "new feature branch", "finish task", "merge task", "close task", "rollback feature". Covers branch naming, worktree creation, merge strategy, and cleanup.
---

# Worktree Workflow

Every task runs in an isolated worktree. No exceptions.

## Branch naming (from constitution)

- Feature: `feature/{number}-{kebab-name}`
- Task inside a feature: `feature/{number}-{feature-name}/{number}-{task-name}`
- Hotfix: `hotfix/{description}`
- Release: `release/{version}`

## Start a task

```bash
# From the main repo
git worktree add ../{project}-{feature}-{task} -b feature/{feature-number}-{feature-name}/{task-number}-{task-name}
cd ../{project}-{feature}-{task}
```

The directory is outside the main repo to keep editors, indexers, and watchers clean.

## Finish a task

Before merging, the task must satisfy the `security-checklist` skill and pass lint + tests.

```bash
# From inside the task worktree, ensure everything is committed
git status

# Switch to the feature branch in the main repo
cd ../{project}
git checkout feature/{feature-number}-{feature-name}

# Merge with --no-ff to preserve task history
git merge feature/{feature-number}-{feature-name}/{task-number}-{task-name} --no-ff \
  -m "task({task-number}): {task-name}"
```

## Clean up

```bash
git worktree remove ../{project}-{feature}-{task}
git branch -d feature/{feature-number}-{feature-name}/{task-number}-{task-name}
```

If `git branch -d` refuses (unmerged changes), investigate — do not force delete without confirming the work is on the feature branch.

## Close a feature

```bash
# Tag for rollback reference
git tag v{feature}-done

# Open PR into main
gh pr create \
  --title "feat({feature-number}): {feature-name}" \
  --body "Closes #{issue-number}" \
  --base main \
  --head feature/{feature-number}-{feature-name}
```

Never auto-merge to main. Review and approve manually.

## Rollback

- Rollback a feature: `git revert` on the merge commit into main.
- Never `git reset --hard` on main.
- The `v{feature}-done` tag is the reference point.

## What NOT to do

- Do not skip the worktree (never work directly on the feature branch inside the main repo).
- Do not `git merge` without `--no-ff` — fast-forward hides the task boundary.
- Do not remove the worktree before confirming the merge succeeded.
