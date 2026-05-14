# Harness Architecture

How the Claude Code harness in this template enforces Spec-Driven Development and a security baseline that the agent cannot remove from inside a session.

Audience: anyone forking or maintaining `project-tokyo`. End-users following `QUICKSTART.md` do not need to read this.

---

## 1. Goals

1. **Spec Kit is mandatory, not honor-system.** Writes inside implementation directories are blocked unless a spec has been explicitly activated.
2. **The agent cannot disable its own enforcement.** Hook files and the project `settings.json` are write-locked from within Claude sessions.
3. **Stack-neutral.** The same harness works for a CLI, a web app, a data pipeline, a service. Project-specific paths live in JSON state, not in hook code.
4. **Continuity across sessions.** A short, sanitized history is committed; full per-session logs are local and pruned by file count.

---

## 2. Defense in depth

Five layers, each independent of the others:

| Layer | Mechanism | Bypassable by the agent? |
|------|-----------|---------------------------|
| L1 | `.claude/settings.json` deny lists | Yes if agent could edit settings.json — see L3 |
| L2 | PreToolUse hooks (`security.sh`, `spec-guard.sh`) | No — they exit 2 and surface stderr to the agent |
| L3 | `harness-lock.sh` PreToolUse hook | No — locks `.claude/hooks/*` and `.claude/settings.json` from in-session Edit/Write |
| L4 | `pre-commit` + gitleaks (local dev) | No — runs in the operator's shell |
| L5 | CI: gitleaks + spec-check workflow (`.github/workflows/`) | No — runs in GitHub Actions, not in the agent |

L1 is convenience (fast denial without invoking a script). L2 enforces what L1 can't and catches a broader pattern surface, but neither stops a determined agent that owns the same UID — see §10 for the honest limits. L3 prevents the agent from quietly turning off L1+L2. L4 catches mistakes before push. L5 is the final backstop on shared history.

---

## 3. State machine

`.claude/context/state.json` is the single source of runtime truth for the harness:

```json
{
  "schema_version": 1,
  "active_spec": null,
  "active_phase": null,
  "active_worktree": null,
  "implementation_dirs": [],
  "session_retention_count": 20,
  "last_session": null
}
```

- `active_spec` — slug of the spec that has been approved for implementation. Only `/spec-activate` mutates this.
- `active_phase` — optional free-text phase label (`plan`, `tasks`, `implement`, etc.). Cosmetic — used in HISTORY lines.
- `active_worktree` — populated by the `worktree-workflow` skill so `/session-resume` can recover it after compaction.
- `implementation_dirs` — list of repo-relative paths that `spec-guard` treats as protected. Mirrors the YAML block in `CLAUDE.md`. When empty, `spec-guard.sh` falls back to `src/ lib/ app/ pkg/ internal/ cmd/ api/`.
- `session_retention_count` — how many files `session-start.sh` keeps in `.claude/context/sessions/recent/`. Default 20.
- `last_session` — ISO timestamp written by `session-start.sh` on each session boot.

---

## 4. Hook contracts

All hooks live in `.claude/hooks/`, are POSIX bash, depend on `jq`, exit 0 to allow / exit 2 to block.

### `security.sh` (PreToolUse: `Read|Edit|Write|MultiEdit`, `Bash`)
Blocks reads/edits of `.env`, `*.pem`, `*.key`, `credentials.json`, anything under `secrets/`, and dangerous Bash patterns: force-push, `reset --hard`, `sudo`, `eval`, `curl|sh`, `wget|sh`, and various `rm -rf` shapes. Allow-lists `*.env.example`.

### `spec-guard.sh` (PreToolUse: `Edit|Write|MultiEdit`)
For each Write/Edit/MultiEdit, computes the repo-relative path. If it falls under `implementation_dirs` and `active_spec` is unset (or points at a missing spec.md), blocks. Allow-list covers docs, tests, config files, and any `*.md`.

### `harness-lock.sh` (PreToolUse: `Edit|Write|MultiEdit`)
Blocks any write whose target matches `.claude/hooks/*` or `.claude/settings.json`. This is what makes L1+L2 trustworthy: the agent has no in-session path to disable them.

### `session-start.sh` (SessionStart) — installed via bootstrap
Prunes `.claude/context/sessions/recent/` to `session_retention_count`, creates `recent/YYYY-MM-DD.md` if missing, writes `.session-start-ref` (the HEAD commit at session boot) so `session-end.sh` can compute a diff range, updates `last_session`, and prints the last `HISTORY.md` line for context.

### `session-end.sh` (Stop) — installed via bootstrap
If any commits or file changes happened since `.session-start-ref`, appends a single sanitized line to `HISTORY.md`:

```
2026-05-14 16:42 | spec=auth-rewrite | phase=implement | files=3 | commits=ab12cd,ef34gh | note=
```

Empty sessions (Q&A with no disk changes) are skipped to keep HISTORY signal-dense.

### `pre-compact.sh` (PreCompact) — installed via bootstrap
Dumps `state.json`, `git status --short`, and `git log --oneline -10` to `.claude/context/sessions/precompact-snapshot.md` (gitignored). `/session-resume` reads this preferentially if it is newer than the most recent log.

---

## 5. Bootstrap dance

`harness-lock` creates a chicken-and-egg problem for any new hook the agent wants to add: it cannot write into `.claude/hooks/`.

The convention is:

1. Agent writes the new hook script(s) and any settings.json snippet under `docs/harness/bootstrap/`. `INSTALL.md` documents the steps.
2. The human operator runs `mv` + `chmod` + edits `settings.json` in their editor, outside Claude.
3. After verification, the bootstrap files can be deleted.

This is the same dance the operator follows when installing the original template — see `docs/harness/bootstrap/INSTALL.md` for the session-lifecycle hooks.

---

## 6. Session history vs session logs

Two distinct artifacts:

- **`HISTORY.md`** — committed, one line per session, sanitized, append-only. The long-tail record. Grows ~500KB after a decade — cheap.
- **`recent/*.md`** — gitignored, per-day Markdown, may contain notes the agent or operator added by hand. Pruned by file count. The short-term scratchpad.

`HISTORY.md` is what survives forever. `recent/` is ephemeral.

---

## 7. Settings precedence

Claude Code merges settings in order: enterprise → user → project → local. The template uses these slots deliberately:

- **Project (`.claude/settings.json`)** — safety baseline (denies + hooks). Committed. Every clone inherits it.
- **User (`~/.claude/settings.json`)** — per-machine prefs (model default, thinking budget, compaction window). Copy from `docs/claude-settings-user.json`.
- **Local (`.claude/settings.local.json`)** — temporary overrides (e.g., enabling Claude.ai connectors for one project). Gitignored.

If a deny appears at the project level, no user/local setting can override it. This is intentional.

---

## 8. CI gate

`.github/workflows/spec-check.yml` runs on every PR. It reads the PR diff and the active `state.json`, and fails the build if any file inside `implementation_dirs` is modified without a matching `.specify/specs/<slug>/spec.md` (or `specs/<slug>/spec.md`) existing in the same PR. This is the L5 backstop — even if a contributor disables the local hooks, the merge gate holds.

---

## 9. Maintenance

To add a new hook:

1. Stage the script under `docs/harness/bootstrap/your-hook.sh`.
2. Update `INSTALL.md` with the move + chmod + settings.json snippet.
3. Open a PR. CODEOWNERS requires a maintainer review for `.claude/`, `.specify/memory/constitution.md`, and `docs/harness-architecture.md`.
4. After merge, the operator runs the bootstrap install once per machine.

To remove a hook: edit `.claude/settings.json` outside Claude, then delete the file.

To change `implementation_dirs`: update both the YAML in `CLAUDE.md` *and* the `implementation_dirs` array in `state.json`. They are not auto-synced.

---

## 10. Honest limits and escalation path

The five layers above are speed bumps for the agent's own mistakes. They are not a sandbox. This section states what is and is not protected, and the realistic escalation paths.

### What the harness protects against

- **Naïve reads/edits** of `.env`, `*.pem`, `*.key`, `credentials.json`, `secrets/**` via the Read/Edit/Write tools — caught by L1 deny + L2 `security.sh` Read branch.
- **Naïve Bash references to `.env`** in any allowlisted binary (`cat .env`, `cp .env /tmp/x`, `rg . .env`, `python3 -c "open('.env').read()"`, `curl -d @.env`, `> .env`, `env > .env.local`) — caught by L2 `security.sh` Bash branch's `.env`-substring guard.
- **Dangerous commands**: `rm -rf /`, `rm -rf ~`, `rm -rf .git`, `git push --force`, `git reset --hard`, `sudo`, `eval`, `curl|sh`, `wget|sh`, `npm publish` — caught by L1 + L2 Bash branch.
- **Agent disabling its own enforcement**: `Edit/Write` on `.claude/hooks/*` or `.claude/settings.json` — caught by L3 `harness-lock`.
- **Committing a secret**: caught by L4 pre-commit gitleaks (local) + L5 CI gitleaks.
- **Writing implementation code without an approved spec**: caught by L2 `spec-guard` (local) + L5 CI `spec-check` (PR gate).

### What the harness does NOT protect against

The agent runs as your UID with shell access. Anything achievable through *that* UID via a Turing-complete interpreter is in scope.

| Bypass | Why it works |
|---|---|
| **Variable obfuscation** — `p=.e; cat "${p}nv"` | Hook string-matchers never see the literal `.env` substring before bash expands it. No string-only rule defeats this. |
| **Indirect copy** — `cp .env /tmp/x; Read /tmp/x` | `cp` is allowlisted; `/tmp/x` has no deny rule. The block on `.env` doesn't transfer to its copy. *(Mitigation in place: the `.env` substring guard catches the `cp` source argument.)* |
| **Script-in-a-script** — Write a script that does the read, then `bash /tmp/script.sh` | The script's *contents* aren't shown to hooks; only the command running it. The script is opaque. |
| **Env var dump** — `env > /tmp/dump` after some other process sourced `.env` | If a child process inherits secrets via environment, dumping its env leaks them. Not in our typical agent path but reachable. |
| **Git plumbing on prior history** — `git log --all -p`, `git show <sha>:.env` | If `.env` was ever committed and the commit still exists in any ref, it's recoverable. gitleaks catches the commit; it doesn't catch the recovery. |
| **Network exfil via allowed binaries** — `gh secret list`, `gh api`, `git push` to a different remote | All allowlisted; no per-call destination check. |

These are inherent to running the agent as a same-UID process. The harness can keep raising the cost (catch more shapes, log more, lock more files), but cannot reach zero from inside the process.

### Recommended operator action — kernel-level baseline

Apply this once per clone, immediately after creating `.env.local`:

```bash
chmod 0600 .env .env.local 2>/dev/null || true
```

Same-UID processes can still read these (UID matches), but anyone else on the box cannot — relevant on shared dev machines or if you later run a second account.

### Escalation path 1 — separate UID

A second user account on the same machine. The agent runs as that account; `.env*` files are owned by you, not the group.

```bash
sudo useradd -m claude-agent
sudo usermod -a -G developers gabriel
sudo usermod -a -G developers claude-agent

cd ~/projects/<your-project>
chown -R gabriel:developers .
chmod 660 $(git ls-files)        # group-readable
chmod 600 .env .env.local        # owner-only

# Run Claude as that user:
sudo -u claude-agent claude
```

Now the kernel refuses `.env` reads from the agent regardless of which hook fires. Workflow cost: ~5 min setup, an `sudo -u` prefix to invoke. Limits: still shares `/etc`, network, anything world-readable in your home.

### Escalation path 2 — devcontainer

The whole Claude session runs inside a container with only the repo bind-mounted. The agent literally has no view of `/home`, `~/.aws`, `~/.ssh`, etc.

`.devcontainer/devcontainer.json`:

```json
{
  "image": "mcr.microsoft.com/devcontainers/typescript-node:24",
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind"
  ],
  "remoteUser": "node",
  "runArgs": ["--cap-drop=ALL", "--security-opt=no-new-privileges"],
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code"
}
```

Open in VS Code → "Reopen in Container" → run `claude` from inside. Combine with `--network` rules (or run `--network=none` and proxy specific traffic through the host) for egress restriction.

### When to escalate

The default harness (no UID isolation, no container) is appropriate when:

- Solo developer, personal machine, only your own secrets in `.env.local`.
- Worst-case leak is a developer credential you can rotate in minutes.
- You read every PR before merging.

Escalate to a separate UID when:

- The machine is shared with anyone else.
- `.env.local` contains a production credential you cannot rotate cheaply.

Escalate to a container when:

- The project handles regulated data (PII, payment, health).
- You want network egress restriction.
- Multiple agents/sessions run in parallel and isolation between them matters.
