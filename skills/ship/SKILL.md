---
name: ship
description: Verify and commit finished work for a feature plan. Use when the user asks to ship, finish, wrap up or commit a feature.
---

# Ship a feature

1. Run `make lint` and `make test`. Stop and report if either fails.
2. Compare the plan in `docs/plans/<slug>.md` with the code: every step is `[x]`, acceptance criteria are met, and any new decision has an ADR.
3. Set `Status: done` in the plan.
4. Show `git status` and the proposed commit message. Commit only after the user explicitly approves ("ok, go"); never push.
5. On a `feature-*` branch (check with `git branch --show-current`), append `timestamp short-hash branch: description` to `LOG.md` after the commit.
