---
name: db-ops
description: Database patterns using SQLAlchemy async with PostgreSQL/PostGIS, including migrations.
---

## Migrations

```bash
uv run alembic revision --autogenerate -m "description"
uv run alembic upgrade head
uv run alembic downgrade -1 # unapply migration, do not run unless authorized. 
uv run alembic current # Current revision
uv run alembic history # History. 
```
Be careful with migrations. When changing git branches, de DB might not be versioned
accordingly. If a migration fails, stop first to ask questions. Check current/history
etc. 

## CRUD Operations

- Use SQLAlchemy async sessions
- Implement proper error handling
- Use Pydantic models for validation
- Follow repository pattern in `/app/crud/`

## Directories

- `/app/core/` - Configuration, database, security
- `/app/api/routes/` - API endpoints
- `/app/schemas/` - Pydantic models
- `/app/crud/` - Database operations
