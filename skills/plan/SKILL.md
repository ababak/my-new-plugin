---
name: plan
description: Create a feature plan in docs/plans/<slug>.md before implementing a new feature. Interviews the user to fill every gap and never assumes anything without confirmation. Use when the user asks to plan, design or scope a feature.
---

# Plan a feature

Core rule: never assume. Every fact in the plan must come from the user's answers, `SPEC.md`, `CLAUDE.md`, existing ADRs or the code. If a fact is missing or ambiguous, ask; do not fill it in with a guess, a "reasonable default" or a placeholder.

1. Read `SPEC.md`, `CLAUDE.md` and existing `docs/adr/` and `docs/plans/` to learn goals, layers and past decisions. Use this only to make questions sharper and to avoid asking what is already answered.
2. Interview the user before writing anything:
   - Ask with the question tool, in small batches (2-4 questions), most blocking questions first. Offer options where the choice is finite; always allow free-form answers.
   - Cover at least: the feature goal and the problem it solves; explicit non-goals; the slug and branch name; entities, fields and validation rules; use cases and API endpoints (paths, methods, status codes, error cases); persistence (tables, migrations, constraints, transaction boundaries); auth/permissions; new dependencies; testable acceptance criteria; known risks and open questions; related ADRs.
   - After each batch, check the answers for new gaps, contradictions and vague wording ("fast", "etc.", "as usual"), and ask follow-ups. Repeat until no gap is left.
   - If the user answers "don't know" or "you decide", do not decide silently: propose concrete options with trade-offs and get an explicit choice, or record the item under "Ризики / відкриті питання" as unresolved.
3. Before drafting, show a short summary of everything you understood (goal, scope, decisions) and ask the user to confirm or correct it. Do not draft until confirmed.
4. Copy `docs/plans/_template.md` to `docs/plans/<slug>.md`. The slug is short kebab-case with no number; never edit another feature's plan.
5. Fill in goal and non-goals, testable acceptance criteria, an assumptions table (assumption | consequence if false), and steps ordered from inner to outer layers (domain, application, infrastructure, presentation, tests). One step is one commit, each with a "done when" check.
   - Put only confirmed facts in the plan. Anything not confirmed goes into the assumptions table marked "unconfirmed" or into open questions; never state it as fact.
   - Leave no template placeholders (`<...>`, `…`) in the result.
6. If a decision is non-obvious (new dependency, API semantics, transaction boundary), propose an ADR in `docs/adr/` instead of burying it in the plan.
7. Show the plan, list any remaining unconfirmed items, and wait for the user's confirmation. Do not start implementing.
