---
name: scaffold
description: Scaffold the Clean Architecture files for the next unchecked step of a feature plan. Use when the user asks to start building, scaffold or implement a planned feature.
---

# Scaffold a feature step

1. Open the feature's `docs/plans/<slug>.md` and take the first unchecked step. If no plan exists, use the `plan` skill first.
2. Create only the files for that step, respecting the dependency rule (domain <- application <- infrastructure/presentation):
   - domain: entities and exceptions, standard library only.
   - application: ports and DTOs, plus one use case class per operation with a single `execute()`.
   - infrastructure: SQLAlchemy repository implementing the port, plus an Alembic migration.
   - presentation: router, Pydantic schemas (never used as domain models), DI wiring.
3. Add tests alongside the code (unit tests with fake repositories, API tests against PostgreSQL).
4. Run `make lint` and `make test`. Mark the step `[x]` in the plan only when both pass.
5. Stop after one step and report; do not commit without the user's approval.
