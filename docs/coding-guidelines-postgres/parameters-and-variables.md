---
description: PostgreSQL parameter and variable naming — the single/double/triple underscore rules, the standard parameter vocabulary, and RETURNS TABLE(...) return columns.
---

# Parameters & variables

## Parameters and variables — the underscore-prefix rules

This is the single most important PG-specific convention. Get it wrong and PL/pgSQL ambiguity errors will hunt you.

| Prefix | Meaning | Example |
|--------|---------|---------|
| `_` (single) | **Input parameter of a function.** Reserved exclusively for this purpose. | `_user_id bigint`, `_correlation_id text`, `_tenant_id integer default 1` |
| `__` (double) | **Local variable** declared in the `declare` block. Also: **column name in a `returns TABLE(...)` clause.** | `declare __user_id bigint; __permission_full_codes text[];` and `returns TABLE(__user_id bigint, __is_active boolean)` |
| `___` (triple) | **Local variable that would otherwise collide with a `__`-prefixed return column** the function is querying. Used only for disambiguation. | `declare ___user_id bigint;` inside a function that queries another function returning `__user_id`. |

**Why this matters:** PL/pgSQL resolves identifiers ambiguously across "is it a column / is it a variable / is it a parameter" boundaries. The single / double / triple convention removes the ambiguity by encoding the role into the name. A reader can tell at a glance that `_user_id` is an input, `__user_id` is a local-or-result, and `___user_id` is the disambiguated local.

**Single underscore for locals is forbidden in new code.** Some legacy code still has it; leave that alone unless you are rewriting the function, but never introduce a new local named `_foo`.

### Standard parameter names

A small ubiquitous vocabulary, repeated across the codebase:

| Parameter | Type | Meaning |
|-----------|------|---------|
| `_user_id` | `bigint` | The acting user (whose permission is being checked) |
| `_target_user_id` | `bigint` | The user being acted upon |
| `_tenant_id` | `integer default 1` | The acting tenant. Default 1 = admin tenant. |
| `_target_tenant_id` | `integer default null` | The tenant being queried (cross-tenant pattern); null = all (with permission) |
| `_correlation_id` | `text` | Request correlation, flows into `journal` and `user_event` |
| `_created_by` / `_updated_by` / `_deleted_by` | `text` | Actor username (matches the `*_by` columns) |
| `_perm_code` / `_perm_codes text[]` | text / text[] | Permission code(s) for `has_permission` / `has_permissions` |
| `_throw_err` | `boolean default true` | Silent vs throwing variant of a predicate |
| `_request_context` | `jsonb default null` | Optional structured context (IP, user-agent, etc.) for audit |
| `_identifier` | `text` | Generic resolver input — could be an ID, UUID, or code; the resolver figures out which |
| `_search_criteria` | `jsonb default '{}'::jsonb` | Search filters — *what* to find. Unknown keys ignored, missing keys defaulted. |
| `_search_settings` | `jsonb default '{}'::jsonb` | Paging / ordering / behavior — *how* to return the result. |
| `_display_language_code` | `text default 'en'` | Display language for translated labels; only on functions that return labels. |

**Order convention:** actor / audit (`_updated_by`, `_user_id`, `_correlation_id`) first, then the operation target (`_target_user_id`, `_perm_code`), then options (`_request_context`, `_tenant_id`, `_throw_err`) with defaults last so the call site can omit them.

### Return columns

When a function returns a table, the columns are `__`-prefixed:

```sql
create or replace function auth.enable_user(
    _updated_by text,
    _user_id bigint,
    _correlation_id text,
    _target_user_id bigint,
    _request_context jsonb default null,
    _tenant_id integer default 1
)
returns TABLE(__user_id bigint, __is_active boolean, __is_locked boolean)
rows 1
language plpgsql
as $$
begin
    perform auth.has_permission(_user_id, _correlation_id, 'users.enable_user', _tenant_id);
    return query
        update auth.user_info
            set updated_by = _updated_by, updated_at = now(), is_active = true
            where is_system = false and user_id = _target_user_id
            returning user_id, is_active, is_locked;
end;
$$;
```

The caller selects them by the `__`-prefixed name:

```sql
select __user_id, __is_active from auth.enable_user(...);
```

When a calling function needs a local with the same logical name as a returned column, use the triple-underscore disambiguator:

```sql
declare
    ___user_id bigint;
begin
    select __user_id into ___user_id from auth.enable_user(...);
end;
```

