---
name: python-review
description: Python code review guidelines focusing on modern typing, async pitfalls, error handling, and testing organization
---

# Python Code Review Guide

Only flag issues with a concrete failure mode or a clear deviation from these
conventions. Formatting and most lint is handled by ruff.

## Typing (Python >= 3.12)

- `X | None`, `list`, `dict`, `tuple`, `set`; never `Optional`, `Union`, `List`, `Dict`,
  etc. from `typing`.
- Never `from __future__ import annotations`.
- Pydantic models for API contracts and validation; `TypedDict` only for plain internal
  dict shapes.
- `pathlib` over `os.path`.

## Async

- No blocking calls in async code (`time.sleep`, sync HTTP/DB clients, heavy CPU work);
  use async libraries or `asyncio.to_thread`.
- `asyncio.TaskGroup` over `gather` when one failure should cancel the rest.
- Never swallow `asyncio.CancelledError`; clean up and re-raise.
- Bound concurrent fan-out to external services or the DB (`asyncio.Semaphore`).

## Error Handling

- `raise NewError(...) from e` when translating exceptions.
- No bare `except:` or broad `except Exception` that logs and continues.
- Business errors as custom exception classes, not generic `ValueError`/`RuntimeError`.
- Transactions roll back on error (context manager / `session.begin()`).
- `ExceptionGroup` when a batch operation should report all failures.

## Performance

- Vectorize numeric work with NumPy instead of Python loops.
- Generators for large datasets instead of building full lists.
- `functools.cache`/`lru_cache` only on pure functions; not on methods (holds `self`).
- `collections` (`Counter`, `defaultdict`, `deque`) over hand-rolled equivalents.

## Control Flow

- Early returns over nesting.
- Extract logic duplicated across branches; don't split into helpers for its own sake.
- Functions over ~50 lines or with more than 3 nesting levels warrant a closer look.

## Testing (pytest)

- Classes to group related tests, `@pytest.mark.parametrize` for input matrices.
- `AsyncMock` for async patches.
- Fixtures with `yield` for cleanup.
- Marks (`slow`, `integration`) for filtering.
