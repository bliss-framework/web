---
description: PostgreSQL naming anti-patterns table and a complete worked auth.* / unsecure.* mutation example.
---

# Anti-patterns & worked example

## Anti-patterns

| Anti-pattern | Why | Use instead |
|--------------|-----|-------------|
| `UPPERCASE SQL KEYWORDS` in new code | Harder to read, drift from convention | `select`, `from`, `where`, `create or replace function`, ... |
| `_foo` as a local variable | Reserved for input parameters | `__foo` (or `___foo` if it collides with a return column) |
| Foreign key column named just `id` | Ambiguous in joins | `user_id`, `tenant_id`, `<target-pk-name>` |
| `tbl_user`, `t_user`, `usr` | Decoration / abbreviation | `user_info` (suffix if reserved word collision); `user` only if not reserved |
| `vw_users`, `v_users` | Decoration | `users` |
| `bool` column named `active`, `deleted` | Missing predicate prefix | `is_active`, `is_deleted` |
| `timestamp` (no time zone) | Loses zone information | `timestamp with time zone` (`timestamptz`) |
| `id bigserial primary key` | `serial` is legacy | `id bigint generated always as identity primary key` |
| Inline `raise exception '...'` | Wording / code drift across callers | `perform error.raise_NNNNN(...)` |
| `CHECK (status IN ('a','b','c'))` | Brittle to extend | `status_code text not null references const.<concept>_type` |
| Calling `auth.foo()` from `auth.bar()` | Double permission check, transactional weirdness | Extract shared logic into `internal.bar()` (or `unsecure.bar()` if it's auth/authz-sensitive); call from both wrappers |
| Ordinary business mutation in `unsecure.*` | `unsecure` is reserved for auth/authz internals only | Put it in `internal.*` — reached via a permission-checked wrapper or a trusted job |
| `select * from user_info` (unqualified) | search_path dependent | `select * from auth.user_info` |
| `returns setof record` | Caller must specify column types | `returns TABLE(__col1 type, __col2 type, ...)` |
| `ext.ltree` in an `auth.*` parameter | Client libraries cannot map extension types | Accept `text`, convert internally with `ext.text2ltree(...)` |
| Re-implementing `internal.resolve_cross_tenant_access` logic inline | DRY violation; rules diverge | Call the resolver |
| `search_x(_filter, _page_size, _page_number, _order_by, ...)` positional | Every new filter or sort option churns the signature and every caller | Two jsonb bags: `_search_criteria` (filters) + `_search_settings` (paging/order) |
| Interpolating `_search_settings->>'order_by'` into dynamic SQL | SQL injection / invalid-column errors | Whitelist the key → column/expression mapping; default on miss |
| `raise`-ing on an unknown `_search_criteria` key | Breaks forward compatibility with newer clients | Ignore unknown keys; default missing ones |
| `enum` type for a reference list | Hard to extend, no metadata | `const.<concept>_type` table + FK |
| Down-migration script | Forward-only is the convention | Write the next forward script |

## Worked example — a complete `auth.*` mutation

The shape every `auth.*` function follows:

```sql
create or replace function auth.assign_permission(
    _created_by text,
    _user_id bigint,
    _correlation_id text,
    _user_group_id integer,
    _target_user_id bigint,
    _perm_set_code text,
    _perm_code text,
    _request_context jsonb default null,
    _tenant_id integer default 1
)
returns SETOF auth.permission_assignment
language plpgsql
as $$
declare
    __assignment auth.permission_assignment;
begin
    -- 1. Permission check (always first; raises 32xxx on failure)
    perform auth.has_permission(_user_id, _correlation_id, 'permissions.assign_permission', _tenant_id);

    -- 2. Delegate to unsecure for the actual work
    return query
        select * from unsecure.assign_permission(
            _created_by, _user_id, _correlation_id,
            _user_group_id, _target_user_id, _perm_set_code, _perm_code,
            _request_context, _tenant_id
        );
end;
$$;
```

And the matching `unsecure.*` worker:

```sql
create or replace function unsecure.assign_permission(
    _created_by text, _user_id bigint, _correlation_id text,
    _user_group_id integer, _target_user_id bigint,
    _perm_set_code text, _perm_code text,
    _request_context jsonb default null, _tenant_id integer default 1
)
returns SETOF auth.permission_assignment
language plpgsql
as $$
declare
    __assignment auth.permission_assignment;
begin
    -- input validation via error.raise_*
    if _target_user_id is null and _user_group_id is null then
        perform error.raise_31001();  -- "either user group id or target user id must not be null"
    end if;

    -- the actual mutation
    insert into auth.permission_assignment (...) values (...) returning * into __assignment;

    -- cache invalidation (delegated, not inlined)
    perform unsecure.invalidate_user_group_id_cache(_target_user_id, _tenant_id);

    -- audit journal
    perform public.create_journal_message_for_entity(
        _created_by, _correlation_id, 50101, /* event_id */
        jsonb_build_object('user', _target_user_id, 'permission', _perm_code),
        _request_context, _tenant_id
    );

    return next __assignment;
end;
$$;
```

The trigger does the rest — `trg_notify_permission_assignment` fires `after insert` on `auth.permission_assignment` and calls `unsecure.notify_permission_change(...)`, which wraps `pg_notify('permission_changes', ...)`. The application's backend has a `LISTEN permission_changes` worker that resolves affected users via `auth.notify_permission_users`.

This example delegates to `unsecure.*` because assigning permissions **is** auth/authz work. For an ordinary business domain the worker lives in `internal.*` instead — the wrapper shape is identical (`perform auth.has_permission(...)` then delegate), only the target schema differs. See [the calling rules](./schemas.md#calling-rules).

