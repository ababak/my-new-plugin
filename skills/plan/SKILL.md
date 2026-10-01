---
name: plan
description: Create a feature plan in docs/plans/<slug>.md before implementing a new feature. Use when the user asks to plan, design or scope a feature.
---

# Plan a feature

1. Read `SPEC.md`, `CLAUDE.md` and existing `docs/adr/` and `docs/plans/` to learn goals, layers and past decisions.
2. Copy `docs/plans/_template.md` to `docs/plans/<slug>.md`. The slug is short kebab-case with no number; never edit another feature's plan.
3. Fill in goal and non-goals, testable acceptance criteria, an assumptions table (assumption | consequence if false), and steps ordered from inner to outer layers (domain, application, infrastructure, presentation, tests). One step is one commit, each with a "done when" check.
4. If a decision is non-obvious (new dependency, API semantics, transaction boundary), propose an ADR in `docs/adr/` instead of burying it in the plan.
5. Show the plan and wait for the user's confirmation. Do not start implementing.
