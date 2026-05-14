## Summary

<!-- 1-3 bullet points. The "why" matters more than the "what". -->

-
-

## Spec

<!-- Required if this PR touches any path inside `implementation_dirs`
     (see .claude/context/state.json or CLAUDE.md).
     Format: `Spec: <slug>` — the slug must match a dir under
     .specify/specs/<slug>/ or specs/<slug>/. -->

Spec:

## Phase

<!-- Which Spec Kit phase produced these changes?
     constitution | specify | clarify | plan | tasks | analyze | implement | hotfix -->

Phase:

## Security checklist

<!-- Run the `security-checklist` skill before checking these.
     Leave a box unchecked only if N/A — explain why next to it. -->

- [ ] No secrets, tokens, or credentials in code or tests
- [ ] `.env` / `.env.*` not modified (only `.env.example` documents new keys)
- [ ] No new network endpoints undocumented in the plan
- [ ] Input validation on every external boundary touched
- [ ] No new dependencies added (or: justified below with license + maintenance status)

## Test plan

<!-- Bulleted checklist of how to verify the change. CI catches lint/tests;
     reviewers need to know what they should also exercise manually. -->

- [ ]
- [ ]

## Notes for reviewers

<!-- Optional. Trade-offs, things you considered and rejected, follow-ups. -->
