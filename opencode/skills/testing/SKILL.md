---
name: testing
description: Testing guidelines for backend (pytest) and frontend (Playwright + MSW).
Currently not strictly enforced. 
---

We're currently light on tests. Unless asked, no need to bother. 

## Backend (pytest)

Unit tests for business logic. Integration tests for API endpoints. Use pytest fixtures for database setup. Mock external dependencies.

Commands:
```bash
uv run pytest                              # All tests
uv run pytest -x                           # Stop on first failure
uv run pytest tests/test_routes.py::test_endpoint_clashes  # Single test
```

## Frontend (Playwright + MSW)

E2E tests with Playwright. Use MSW for API mocking.

Test tags: @normal (basic user), @admin (admin user), @fail (error cases)

Commands:
```bash
npx playwright test                        # All tests
npx playwright test --ui                   # UI mode
npx playwright test --grep @normal         # By tag
```

Test files end with `.spec.ts`.
