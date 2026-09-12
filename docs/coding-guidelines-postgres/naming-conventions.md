---
description: PostgreSQL naming conventions — overview, the master casing summary, and how the reference is organized.
---

# PostgreSQL naming conventions

These rules extend the [general naming conventions](../coding-guidelines/general-naming-conventions.md). Where the general rules and these overlap, the general rule is canonical; this page adds the PostgreSQL-specific cases.

The reference implementation cited throughout — `postgresql-permissions-model` — is the canonical example. When in doubt, do what it does.

This reference is split across several pages:

- [Schemas & structure](schemas.md) — the fixed schema set and what lives in each.
- [Tables, columns & views](tables-columns-views.md) — singular vs plural, identifiers, audit columns, booleans, `nrm_`, JSONB.
- [Functions](functions.md) — the verb registry, the two-jsonb search shape, return types, stability markers, the public-API type boundary, schema qualification.
- [Parameters & variables](parameters-and-variables.md) — the single / double / triple underscore rules and the standard parameter vocabulary.
- [Triggers, indexes, constants & errors](triggers-indexes-constants-errors.md).
- [Migrations & file organization](migrations-and-files.md).
- [Anti-patterns & worked example](anti-patterns-and-example.md).

## Casing summary

| Used for | Casing | Example |
|----------|--------|---------|
| SQL keywords (`select`, `from`, `where`, `create or replace function`) | **lowercase** | `select * from auth.user_info where is_active = true` |
| Schema names | snake_case, short | `auth`, `unsecure`, `internal`, `helpers`, `const`, `error`, `triggers`, `stage`, `ext` |
| Table names | snake_case, **singular** | `auth.user_info`, `auth.user_group_member`, `const.token_type` |
| View names | snake_case, **plural** | `auth.active_user_groups`, `auth.user_group_members`, `auth.effective_permissions` |
| Column names | snake_case | `user_id`, `created_at`, `nrm_search_data` |
| Function names | snake_case, `[verb]_[noun]` | `create_user`, `get_user`, `has_permission`, `enable_user_group` |
| Function parameters | `_snake_case` (single leading underscore) | `_user_id`, `_correlation_id`, `_tenant_id` |
| Local variables (PL/pgSQL) | `__snake_case` (double leading underscore) | `__user_id`, `__permission_full_codes text[]`, `__expiration_date` |
| Return columns of `RETURNS TABLE(...)` | `__snake_case` (double leading underscore) | `returns TABLE(__user_id bigint, __is_active boolean)` |
| Locals that clash with a `__` return column | `___snake_case` (triple leading underscore) | `___user_id` when querying a function that returns `__user_id` |
| Trigger names | `trg_<schema>_<table>_<purpose>` | `trg_auth_calculate_user_info`, `trg_cache_user_group_member_delete` |
| Unique indexes | `uq_<table>_<purpose>` | `uq_permission_full_code`, `uq_sys_params` |
| Regular indexes | `ix_<table>_<purpose>` | `ix_journal_correlation_id`, `ix_permission_node_path` |
| Trigram / GIN indexes | `ix_trgm_<table>_<purpose>` | `ix_trgm_user_info_search` |
| Constants in `const.*` (codes) | snake_case `text` codes, not integers | `'normal'`, `'authenticated'`, `'password_reset'` |
| Error codes | 5-digit numeric, range-grouped | `30001`, `33020`, `52108` |

### SQL keywords are lowercase

`select`, `from`, `inner join`, `where`, `case when`, `returns table(...)`, `create or replace function`, `language plpgsql`, `language sql` — all lowercase. The shouting `SELECT * FROM ...` style is a relic of monospaced terminals and DataGrip exports; modern PostgreSQL source files are easier to read in lowercase.

If you are editing an old file that uses uppercase (some legacy `015_views.sql`-style exports do), leave it alone; new code is lowercase.


## See also

- [General naming conventions](../coding-guidelines/general-naming-conventions.md) — the shared verb registry and singular/plural rules.
- [General coding structure](../coding-guidelines/layers-of-application.md) — the three-layer model.
- [PostgreSQL coding guidelines (this section's index)](index.md) — schemas as layers, the public/internal/unsecure rule, multi-tenant access, version management.
- Reference implementation: `postgresql-permissions-model` — the codebase these conventions were extracted from.
