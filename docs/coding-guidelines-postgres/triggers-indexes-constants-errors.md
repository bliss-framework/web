---
description: PostgreSQL triggers, indexes/constraints, const.* lookup tables, and error functions (one error.raise_NNNNN per code).
---

# Triggers, indexes, constants & errors

## Triggers

**Naming pattern:** `trg_<schema>_<table>_<purpose>` for the trigger; `<schema>.<purpose>_<table>()` (or `calculate_<table>_<thing>()`, `cache_<table>_<event>()`, `notify_<table>_<event>()`) for the function.

```sql
create or replace function triggers.calculate_user_info() returns trigger
    language plpgsql
as $$
begin
    if tg_op = 'INSERT' or tg_op = 'UPDATE' then
        new.nrm_search_data := triggers.calculate_user_info_search_values(new);
        return new;
    end if;
end;
$$;

create trigger trg_auth_calculate_user_info
    before insert or update on auth.user_info
    for each row
    execute function triggers.calculate_user_info();
```

**Split triggers by responsibility:**

- `triggers.calculate_*` — `before insert or update`, populates derived columns (`nrm_search_data`, computed codes)
- `triggers.cache_*` — `after insert/update/delete`, invalidates `auth.user_permission_cache` and similar
- `triggers.notify_*` — `after insert/update/delete`, calls `unsecure.notify_*` which wraps `pg_notify(...)`

Triggers may call `unsecure.*` and `helpers.*` freely but **must not** call `auth.*` (would re-trigger permission checks from inside a permission-modifying transaction).


## Indexes and constraints

| Kind | Pattern | Example |
|------|---------|---------|
| Unique index | `uq_<table-or-concept>[_columns]` | `uq_permission_full_code`, `uq_sys_params (group_code, code)` |
| Regular index | `ix_<table>_<purpose>` | `ix_journal_correlation_id`, `ix_permission_node_path` |
| GIN index | `ix_<table>_<col>` with `using gin` | `ix_journal_keys using gin (keys)` |
| Trigram (GiST) | `ix_trgm_<table>_<purpose>` | `ix_trgm_user_info_search using gist (nrm_search_data gist_trgm_ops)` |
| Partial index | append `where ...` to the index name's purpose, not as a separate prefix | `ix_journal_correlation_id ... where correlation_id is not null` |
| Check constraint | `<table>_<column>_check` (PG default) for simple checks; `<table>_<rule>` for logic constraints | `provider_created_by_check`, `provider_sync_requires_mapping` |
| Primary key | unnamed — let PostgreSQL generate it from the column | `user_id bigint generated always as identity primary key` |

Don't name foreign-key constraints explicitly unless you have a reason to drop them by name later; PG's auto-generated names are fine.

## Constants and enums — use `const.*` tables, not PG enums

PG `CREATE TYPE ... AS ENUM` is rigid: extending it requires `ALTER TYPE`, removing a value requires a full migration dance, and it doesn't carry per-value metadata (titles, descriptions, system-flags).

Use a table in `const.*` instead:

```sql
create table const.token_type (
    code                            text    not null primary key,
    default_expiration_in_seconds   integer,
    is_system                       boolean default false not null
);
```

Foreign keys reference the code column:

```sql
token_type_code text not null references const.token_type,
```

Seed values with `ON CONFLICT DO NOTHING` so reseeding is idempotent:

```sql
insert into const.token_type (code, default_expiration_in_seconds, is_system) values
    ('password_reset',     3600,   true),
    ('email_verification', 86400,  true),
    ('invite',             604800, true),
    ('mfa',                300,    true)
on conflict do nothing;
```

Code values are lowercase snake_case strings, treated as stable identifiers (do not rename them lightly — they end up in caller code).

## Error functions — one per code

All errors flow through `error.*` functions. Each numeric error code is a single dedicated function:

```sql
create or replace function error.raise_30001(_api_key text) returns void
    language plpgsql
as $$
begin
    raise exception 'API key/secret (key: %) combination is not valid or API user has not been found', _api_key
        using errcode = '30001';
end;
$$;
```

Callers `perform error.raise_30001(_api_key)` — never inline `raise exception`. This centralizes wording, makes error codes searchable, and gives every caller a typed signature.

### Code ranges

Reserve numeric ranges by category. The reference implementation uses:

| Range | Category |
|-------|----------|
| 30001–30999 | Security / auth |
| 31001–31999 | Validation |
| 32001–32999 | Permission |
| 33001–33999 | User / group |
| 34001–34999 | Tenant |
| 35001–35999 | Resource access |
| 36001–36999 | Token / config |
| 50001–50999 | Application reserved — informational events |
| 52001–52999 | Application reserved — security events |

Allocate your application's ranges in `const.event_category` so the numeric space stays organized.

### Composite error functions

When the right error code depends on context, write a composite raiser:

```sql
create or replace function internal.throw_no_permission(
    _user_id bigint, _perm_codes text[], _tenant_id integer default 1
) returns void language plpgsql as $$ ...$$;

create or replace function internal.throw_no_permission(
    _user_id bigint, _perm_code text, _tenant_id integer default 1
) returns void language plpgsql as $$ ... $$;
```

PG supports overloading on arity and type; use it sparingly and only for "same semantic op, different input shape" (scalar vs array; with vs without tenant).

