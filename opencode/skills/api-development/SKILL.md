---
name: api-development
description: API development patterns for FastAPI backend and TypeScript client
---

## Backend Routes

- Use FastAPI dependency injection:
  - really strive to move any checks/validation that occur at least twice into a
  dependency. 
- Return Pydantic models for responses
- Implement proper error handling with HTTPError
- All endpoints documented with OpenAPI decorators
- Routes must always end with '/'

## Fast API project structure

- Routes are the entry point, and should be stable. Breaking changes to a route should
be announced. (modifying parameters, deleting them, etc.)
- Routes should validate all necessary data either with dependencies or directly in the
  route body. Then, for simple operations it can call directly the crud layer, or, for
more complex ones, the service layer.
- Service layer: complex operations requiring business logic. May call crud. When
calling crud on objects, prefer passing the ORM reference instead of an id/uuid
- Crud layer: simple CRUD operations interacting with the database
- utils layer: should not depend on DB objects. 

## Frontend Client

Auto-generated from OpenAPI spec (`npm run openapi`). Use generated client in `$lib/api/openapi.gen.ts`.

### Client Generation

- **Configuration is already set up** - Never modify `openapi-ts.config.ts`
  - The config reads from `http://localhost:8000/openapi.json`
  - The FastAPI backend is always running locally
  - Simply run `npm run openapi` in the frontend directory
- The server exports its OpenAPI spec at `/openapi.json` automatically
- After adding/changing backend endpoints, regenerate the client to update TypeScript types
- Generated files are in `src/lib/client/` - never edit these manually
