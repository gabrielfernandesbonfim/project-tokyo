---
description: Mark a spec as active so spec-guard allows writes in implementation dirs.
---

Activate spec **$1** as the working spec for this branch.

Steps:

1. Resolve the spec path. It must exist at one of:
   - `.specify/specs/$1/spec.md` (post-init)
   - `specs/$1/spec.md` (pre-init)
   If neither exists, abort and tell the user to run `/speckit.specify` first or correct the slug.

2. Confirm with the user before mutating state if the slug looks like a typo (e.g., differs by 1 char from an existing slug). For obvious matches, proceed.

3. Update `.claude/context/state.json`:
   ```bash
   tmp=$(mktemp)
   jq --arg s "$1" '.active_spec = $s' .claude/context/state.json > "$tmp" \
     && mv "$tmp" .claude/context/state.json
   ```

4. Print:
   - The new `active_spec`
   - Path to the spec file
   - A reminder: writes inside `implementation_dirs` are now unblocked for this slug only

Do NOT activate a spec that has not been reviewed and approved by the user — activation is the explicit go-ahead for implementation writes.
