---
description: PostgreSQL function conventions — the verb registry, the two-jsonb search-function signature, return types, stability/parallelism markers, the public-API type boundary, and schema qualification.
---

# Functions & return types

## Functions

### Verbs — the registry

The general Bliss verb registry applies. The PG-specific shapes:

| Verb | Means | Example |
|------|-------|---------|
| `get_*` | Single-row or multi-row retrieval, complete object as-is | `get_user`, `get_users`, `get_user_by_email` |
| `search_*` | Filtered + paged retrieval, two-jsonb shape (see below) | `search_users(_user_id, _correlation_id, _search_criteria, _search_settings)` |
| `create_*` | INSERT + audit + return the new row | `create_user`, `create_user_group_member` |
| `update_*` | UPDATE + audit + return the updated row | `update_user_data`, `update_tenant` |
| `delete_*` | DELETE (or soft-delete) + audit | `delete_user`, `delete_user_group` |
| `ensure_*` | Idempotent upsert — return the existing or newly-created row | `ensure_user_info`, `ensure_resource_types` |
| `assign_*` / `revoke_*` | Add / remove a relationship row (permission, member) | `assign_permission`, `revoke_permission` |
| `enable_*` / `disable_*` | Flip `is_active` | `enable_user`, `disable_user_group` |
| `lock_*` / `unlock_*` | Flip `is_locked` | `lock_user`, `unlock_user` |
| `set_*_as_*` | Change a categorical state | `set_user_group_as_external`, `set_permission_as_assignable` |
| `has_*` | Boolean check (PG predicate, see below) | `has_permission`, `has_permissions` |
| `is_*` | Boolean test (PG predicate) | `is_group_member`, `is_owner`, `is_resource_owner` |
| `check_*` | Read-only inspection returning verdict | (see general rules) |
| `validate_*` | Boundary check, raises on failure | `validate_provider_is_active`, `validate_token` |
| `verify_*` | Assert a claim made elsewhere | `verify_user_identity` |
| `process_*` | Multi-step batch operation | `process_external_group_members` |
| `resolve_*` | Convert an external identifier (text, uuid) into an internal ID | `internal.resolve_user(_identifier)`, `internal.resolve_tenant(_identifier)` |
| `clear_*` | Bulk delete (typically a cache) | `unsecure.clear_permission_cache` |
| `invalidate_*` | Mark cached data stale without deleting | `unsecure.invalidate_user_group_id_cache` |
| `notify_*` | Wrap `pg_notify(...)` for a specific channel | `unsecure.notify_permission_change` |
| `calculate_*` | Trigger helper that computes a derived column | `triggers.calculate_user_info_search_values` |
| `format_*` | String formatting (template expansion) | `public.format_journal_message` |
| `raise_<code>` | One-shot error raiser | `error.raise_30001(_api_key)` |
| `throw_*` | Composite raiser that picks the right code | `internal.throw_no_permission(_user_id, _perm_codes)` |
| `compute_*` / `compare_*` / `normalize_*` | Pure helpers in `helpers.*` | `helpers.compute_jsonb_hash`, `helpers.compare_jsonb_objects` |

**Singular vs plural in function names** follows the operation: `get_user` (one), `get_users` (many), `has_permission` (one code), `has_permissions(_perm_codes text[])` (an array of codes — different signature).

### `has_*` / `is_*` vs `check_*` vs `validate_*` — PG variant

The general [Check vs Validate vs Verify vs Is/Has/Can rule](../coding-guidelines/general-naming-conventions.md#check-vs-validate-vs-verify-vs-ishascan) applies. In PG specifically:

| Function shape | Returns | Raises? | Use |
|----------------|---------|---------|-----|
| `is_*(...)` / `has_*(...)` | `boolean` | Optionally — most take a `_throw_err boolean default true` parameter | Predicate. With `_throw_err := false` for silent check, default true for "fail loudly". |
| `check_*(...)` | `boolean` or small detail | Never | Pure inspection. Returns the verdict; caller decides what to do. |
| `validate_*(...)` | `void` (or row) | Yes — calls `error.raise_NNNNN(...)` on failure | Boundary gate. Use at the top of an `auth.*` function to reject bad input. |
| `verify_*(...)` | `boolean` or `void` | Yes on failure | Postcondition / claim assertion. `verify_user_identity` checks that a presented identity matches a stored one. |
| `ensure_*(...)` | the row | No — creates if missing | Idempotent upsert. Returns the row whether it pre-existed or was just created. |

The `_throw_err boolean default true` parameter on `has_*` is a PG-specific convenience: most callers want the throw-on-failure shape (one less `if` block), but a few need a silent check. Default to true; pass `:= false` at the call site to opt out.

### Search functions — `_search_criteria` and `_search_settings`

`search_*` functions take their filters and presentation options as **two `jsonb` parameters** instead of a positional list of `_filter`, `_page_size`, `_page_number`, `_order_by`, … . Every project-owned search function follows the same signature:

```sql
create or replace function auth.search_users(
    _user_id               bigint,
    _correlation_id        text,
    _display_language_code text    default 'en',           -- only when the result carries labels
    _search_criteria       jsonb   default '{}'::jsonb,    -- WHAT to find   (filters)
    _search_settings       jsonb   default '{}'::jsonb,    -- HOW to return it (paging, ordering)
    _tenant_id             integer default 1
)
returns TABLE(__user_id bigint, __username text, __total_count bigint)
language plpgsql
as $$ ... $$;
```

The split is about **why a value changes**, not where it comes from:

| Parameter | Carries | Example |
|-----------|---------|---------|
| `_search_criteria` | **What to find** — filters only | `{"text": "novak", "status": "failed", "nace": "J", "active_only": true}` |
| `_search_settings` | **How to return it** — paging, ordering, behavior toggles | `{"page": 1, "page_size": 100, "order_by": "generated_at", "order_dir": "desc", "search_in_attachments": true}` |

Identity and presentation parameters stay **positional** — they are not search inputs:

- `_user_id`, `_correlation_id`, `_tenant_id` — identity / audit, exactly as on every other `auth.*` function.
- `_display_language_code` — positional, present **only** when the function returns human-readable labels to translate. Omit it for ID-only / raw-data searches.

**Why two jsonb bags instead of positional filter params:**

- **Signature stability.** Adding a new filter or a new sort option is an additive change to a documented key set, not a new positional parameter. The function signature — and therefore every caller, every code generator, and every `grant` — stays untouched. This is [Be replaceable](../consistency-is-bliss.md#be-replaceable) applied to the call boundary: the contract you publish today survives the next ten filters.
- **Criteria vs settings is a real seam.** "Find failed jobs in sector J" (criteria) and "page 2, 100 per page, newest first" (settings) change for different reasons, are built by different parts of the UI, and are often cached/persisted separately. Keeping them in two bags keeps each one readable.

**Parse leniently** — the function is forgiving about what arrives:

- **Unknown keys are ignored.** Never raise on an unrecognized filter; a newer client may send keys an older function doesn't read yet.
- **Missing keys fall back to defaults**, read through a guarded extraction:

```sql
declare
    __page      integer := coalesce((_search_settings->>'page')::int, 1);
    __page_size integer := least(coalesce((_search_settings->>'page_size')::int, 100), 1000);
    __order_by  text    := coalesce(_search_settings->>'order_by', 'created_at');
    __text      text    := nullif(_search_criteria->>'text', '');
begin
    ...
```

- **Whitelist `order_by` / `order_dir`.** Never interpolate them straight into dynamic SQL. Map the incoming key to a known column or expression, reject (or default) anything else, and `least(...)`-clamp `page_size` to a sane maximum.
- **Default both bags to `'{}'::jsonb`** so `search_users(_user_id, _correlation_id)` is a valid "first page, default order, no filters" call.

Document the recognized keys of each bag in a comment above the function — since the signature no longer lists them, that comment **is** the contract.


## Return types

| Shape | Use |
|-------|-----|
| `returns void` | Mutations whose result the caller doesn't need (notifications, cache clears, error raisers) |
| `returns <scalar>` | Predicates (`returns boolean`), id factories (`returns bigint`), formatters (`returns text`) |
| `returns TABLE(__col …)` | Functions returning structured rows. Most common shape for `auth.*` mutations and reads. |
| `returns SETOF <table>` | Functions returning rows of an existing table type unchanged | `returns SETOF auth.permission_assignment` |
| `returns SETOF <composite>` | When all columns of a single composite type are returned | `returns SETOF __version` |
| `returns <composite>` | Single row of a composite/table type | `returns const.sys_param` |

Prefer `TABLE(...)` over `SETOF record` — anonymous record returns require the caller to specify column types at the call site and break tooling.

### `rows N` cardinality hint

When you know the function returns at most one row, add `rows 1`. The planner uses it; readers use it as documentation.

```sql
returns TABLE(__user_id bigint, __is_active boolean)
rows 1
```

## Stability and parallelism

| Marker | Use |
|--------|-----|
| `immutable` | Pure, deterministic, no side effects, no table access. Helpers like `helpers.is_empty_string`, `helpers.compute_jsonb_hash`. |
| `stable` | Returns the same result within a single statement; may read tables. Predicates like `auth.has_permission`. |
| `volatile` (default) | Anything that writes, or whose result can vary within a statement. Mutations, audit writes, cache clears. |
| `parallel safe` | Safe to run in parallel workers. Add to pure helpers. |
| `cost N` | Hint to the planner. `cost 1` for trivial helpers, `cost 0.1` for very-fast hash/string ops, leave default (`100`) otherwise. |

```sql
create or replace function helpers.is_empty_string(_text text)
    returns boolean
    language sql
    immutable
    parallel safe
    cost 1
as $$ select _text is null or _text = ''; $$;
```

## Public-API types — the boundary rule

**Functions in `public.*` and `auth.*` (the application-callable API surface) must use only stock PostgreSQL types and `jsonb` in their parameters and return columns.** Never expose extension types — `ext.ltree`, `ext.ltree[]`, `ext.uuid`, `ext.tsvector`, etc.

```sql
-- BAD: public API leaks ext.ltree
create or replace function auth.get_permission_by_path(_path ext.ltree)
    returns TABLE(__path ext.ltree, ...) ...

-- GOOD: text in, text out; convert internally
create or replace function auth.get_permission_by_path(_path text)
    returns TABLE(__path text, ...)
    language plpgsql
as $$
declare
    __lt ext.ltree := ext.text2ltree(_path);
begin
    return query
        select node_path::text, ... from auth.permission where node_path = __lt;
end;
$$;
```

**Why:** downstream code generators and client libraries (Elixir Ecto, Go pgx, TypeScript clients) cannot map extension types and fail with `dbType '_ltree' not found` or similar. Tables, `internal.*`, `unsecure.*`, `helpers.*`, and `triggers.*` may use extension types freely.

## Always use fully qualified schema names

```sql
-- GOOD
select * from auth.user_info where user_id = _target_user_id;
perform auth.has_permission(_user_id, _correlation_id, 'users.enable_user', _tenant_id);
perform error.raise_30001(_api_key);
__lt := ext.text2ltree(_path);

-- BAD — depends on search_path being right at call time
select * from user_info where user_id = _target_user_id;
perform has_permission(...);
perform raise_30001(_api_key);
```

`search_path` is per-session and can be different in production vs. local vs. inside a trigger vs. inside a function. Fully qualifying every identifier removes the variable. The set-search-path-at-top-of-file pattern is used in the reference implementation but does not replace this rule — it provides defaults for the migration script, not for the resulting functions.

