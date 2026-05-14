---
name: spec-flow
description: Use when the user wants to start a new feature, plan work, or asks "what's next" in the Spec Kit sequence. Triggers on phrases like "start spec", "new spec", "plan this feature", "next speckit step", "begin a feature", "specify this", or any time the user is unsure which speckit command to run.
---

# Spec Flow

Spec-Driven Development is **mandatory** in this template. Every implementation change must trace back to an approved spec. This skill is the map of which command to run when.

## The seven phases

| # | Command | Output | Human gate |
|---|---------|--------|-----------|
| 0 | `/speckit.constitution` | `.specify/memory/constitution.md` | Review before any spec |
| 1 | `/speckit.specify <desc>` | `specs/<slug>/spec.md` | Read and approve |
| 2 | `/speckit.clarify` | edits `spec.md` | Resolve open questions |
| 3 | `/speckit.plan` | `specs/<slug>/plan.md` | **Set `implementation_dirs` + run `/spec-activate <slug>`** |
| 4 | `/speckit.tasks` | `specs/<slug>/tasks.md` | Review task breakdown |
| 5 | `/speckit.analyze` | `specs/<slug>/analyze.md` | Optional risk pass |
| 6 | `/speckit.implement` | code | Only after `/spec-activate` |

## Where the hook gate sits

Between phase 3 (plan) and phase 6 (implement), **`/spec-activate <slug>`** is what flips the lock — it writes the slug into `.claude/context/state.json`. Until that happens, `spec-guard.sh` blocks every `Write|Edit|MultiEdit` inside `implementation_dirs`. This is intentional: it forces the human to approve the plan before code lands.

## Picking the next command

If the user is unsure what to run:

- No `.specify/memory/constitution.md` yet → start with `/speckit.constitution`.
- Constitution exists, no `specs/<slug>/spec.md` for the current task → `/speckit.specify <description>`.
- `spec.md` exists but has `[NEEDS CLARIFICATION]` markers → `/speckit.clarify`.
- `spec.md` is clean but no `plan.md` → `/speckit.plan`.
- `plan.md` exists and the user is ready to code → confirm `implementation_dirs` are set in `CLAUDE.md` *and* mirrored in `state.json`, then `/spec-activate <slug>`.
- `tasks.md` is needed for breakdown → `/speckit.tasks`.
- About to start a risky change → `/speckit.analyze` first.
- All gates passed → `/speckit.implement`.

## What this skill does NOT do

- Does not run `/speckit.*` commands itself — the user runs them so they read the output.
- Does not bypass `spec-guard` — if a user asks "just edit src/foo.ts real quick", refuse and route them back to `/speckit.specify`.
- Does not edit `state.json` — that is `/spec-activate`'s job.

## When to invoke `worktree-workflow`

Each task within a feature should live in its own worktree. After `/speckit.tasks` produces the task list, hand off to the `worktree-workflow` skill to spin up worktrees per task.
