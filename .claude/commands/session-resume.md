---
description: Load the last session summary and surface what was in progress.
---

Reconstruct where the previous session left off. Be brief — this is for continuity, not a debrief.

Steps:

1. If `.claude/context/sessions/precompact-snapshot.md` exists and is newer than the most recent log in `.claude/context/sessions/recent/`, prefer it: read it and report the snapshot timestamp. Otherwise skip.

2. Read the last entry of `.claude/context/sessions/HISTORY.md`:
   ```bash
   grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' .claude/context/sessions/HISTORY.md | tail -1
   ```
   Report the timestamp, spec, phase, file count, and commit list.

3. Read the most recent file in `.claude/context/sessions/recent/` (by mtime). Skim it for notes the operator may have added by hand. Surface anything that looks like a TODO, open question, or "next step".

4. Cross-check `.claude/context/state.json`:
   - `active_spec` — still set? If yes, recall its phase
   - `active_worktree` — still set? If yes, mention the worktree path
   - If state and the last log disagree (e.g., state says spec X but last commits were on Y), flag it

5. Output a 3-5 line summary, then ask the user: "Continue with X, or pivot?"

Do not begin implementation work as part of this command — only report.
