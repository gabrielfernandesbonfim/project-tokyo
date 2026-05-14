---
description: Commit pending changes as a checkpoint (no push). Optional message via $ARGUMENTS.
---

Create a local checkpoint commit of the current working tree. This is a save-point — not a push, not a tag, not a PR.

Steps:

1. Run `git status` to see what would be staged. If the tree is clean, report "Nothing to checkpoint" and stop.

2. If `$ARGUMENTS` is non-empty, use it as the commit subject. Otherwise generate a one-line subject from the changes (≤60 chars, imperative mood, no trailing period). Prefix it with `chore(checkpoint):`.

3. **Do NOT add files that are gitignored or that look like secrets** — verify nothing matching `.env`, `*.pem`, `*.key`, `credentials.json`, or paths under `secrets/` made it into `git status`. If anything sensitive is staged or untracked, stop and warn the user.

4. Stage the intended files explicitly by name (no `git add -A`, no `git add .`). Show the user what will be added before committing.

5. Commit:
   ```
   git commit -m "chore(checkpoint): <subject>

   Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
   ```

6. **Do NOT push.** This is a local checkpoint. Print the new commit hash and remind the user to run `git push` themselves when ready.
