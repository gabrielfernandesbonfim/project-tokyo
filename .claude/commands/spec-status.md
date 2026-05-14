---
description: Show the active spec, current phase, and pending tasks at a glance.
---

Report the current Spec Kit state. Be terse — this is a status check, not a tutorial.

Steps:

1. Read `.claude/context/state.json`. If `active_spec` is null, say "No active spec" and stop.

2. Resolve the spec dir (`.specify/specs/<slug>/` or `specs/<slug>/`). If missing, report the inconsistency and suggest `/spec-activate <existing-slug>`.

3. From the spec dir, surface:
   - `active_phase` from state.json
   - First line of `spec.md` (title)
   - If `plan.md` exists: report it does and offer to read on request
   - If `tasks.md` exists: count tasks by status (use grep on checkbox markers `- [ ]` / `- [x]`). Print: `tasks: X done / Y total`.
   - If `analyze.md` exists: report it does
   - If neither plan.md nor tasks.md exists: state which speckit step is next

4. Recent commits touching this spec dir:
   ```bash
   git log --oneline -5 -- .specify/specs/$slug specs/$slug 2>/dev/null
   ```

5. Output as a single compact block — no headers, no narrative, just facts.
