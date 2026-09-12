---
description: PostgreSQL migration-file numbering and naming, semantic number ranges, update-file naming, one-domain-per-file, and file-header/comment conventions.
---

# Migrations & file organization

## Migration files — numbering and naming

Three-digit numeric prefix, snake_case description:

```
000_create_database.sql
001_create_basic_structure.sql
002_create_version_management.sql
004_create_helpers.sql
005_update_common-helpers_v1-1.sql
010_functions_auth_prereq.sql
012_tables_const.sql
013_tables_auth.sql
015_views.sql
016_functions_error.sql
017_functions_triggers.sql
018_functions_public.sql
019_functions_unsecure.sql
020_functions_auth_user.sql
021_functions_auth_group.sql
022_functions_auth_permission.sql
...
029_seed_data.sql
033_triggers_cache_and_notify.sql
047_seed_permissions.sql
099_fix_permissions.sql
```

### Semantic clustering by number range

| Range | Contents |
|-------|----------|
| `000–009` | Database creation, schemas, helpers, helper updates |
| `010–014` | Prereq functions, lookup tables, core tables, stage tables |
| `015` | Views |
| `016` | Error functions |
| `017` | Trigger functions for calculated columns |
| `018` | Public application functions |
| `019` | Unsecure (trusted internal) functions |
| `020–029` | Auth domain functions — one file per subject (user, group, permission, tenant, provider, token, apikey, owner, event) |
| `030–049` | Feature additions (language/translation, resource access, MFA, invitations, etc.) |
| `046–047` | Seed data — translations, permissions |
| `099` | Final permission grants |
| `999-*` | Examples and ad-hoc seed data (not part of the migration set) |

### Update file naming

Incremental updates to a published file use `_update_<topic>_v<major>-<minor>.sql`:

```
004_create_helpers.sql                  (v1.0 of helpers)
005_update_common-helpers_v1-1.sql
006_update_common-helpers_v1-2.sql
007_update_common-helpers_v1-3.sql
008_update_common-helpers_v1-4.sql
009_update_common-helpers_v1-5.sql
013_update_common-helpers_v1-6.sql
```

Each update file begins with `start_version_update('1.6', '...', _component := 'common_helpers')` and ends with `stop_version_update('1.6', _component := 'common_helpers')`.

### One file per domain

In the `020–028_functions_auth_*.sql` cluster, each file covers exactly one subject (the PG analog of "one provider per file"):

```
020_functions_auth_user.sql        — register, enable, disable, lock, unlock, get_user_by_*
021_functions_auth_group.sql       — create_user_group, member CRUD, is_group_member
022_functions_auth_permission.sql  — has_permission, assign_permission, perm sets
023_functions_auth_tenant.sql      — tenant CRUD, tenant_user
024_functions_auth_provider.sql    — provider CRUD, validation
025_functions_auth_token.sql       — token lifecycle
026_functions_auth_apikey.sql      — API key + technical user
027_functions_auth_owner.sql       — ownership predicates
028_functions_auth_event.sql       — user_event CRUD
```

This mirrors the [general rule](../coding-guidelines/general-naming-conventions.md#name-structure) that a provider operates on one primary subject.

## File header and comments

**File header** — block comment describing the file's domain:

```sql
/*
 * Auth User Functions
 * ===================
 *
 * User management: registration, identity, preferences, enable/disable/lock
 *
 * Part of the PostgreSQL Permissions Model v2
 */

set search_path = public, const, ext, stage, helpers, internal, unsecure, auth, triggers;
```

**Function comments** — single-line or short block above the function describing the "why", not the "what":

```sql
-- helpers.path_to_ltree — sanitize a separator-delimited path into an ltree.
-- Inner dots inside a segment (e.g. "report.pdf") become part of the label,
-- not a separator.
create or replace function helpers.path_to_ltree(_path text, _separator text default '/')
    returns ext.ltree
    language plpgsql
    immutable
as $$ ... $$;
```

**Column comments** — for non-obvious JSONB shapes and computed columns:

```sql
comment on column public.journal.keys
    is 'Entity references: {"order": 3, "item": 5}';
comment on column public.journal.data_payload
    is 'Template values and extra data: {"username": "john"}';
```

Default to writing no comment. Add one only when the **why** is non-obvious — a hidden constraint, a workaround for a PG quirk, the rationale for a default value. Don't restate the function body in English.

