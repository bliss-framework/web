---
description: Naming conventions for PostgreSQL — schemas, tables, columns, functions, parameters, return columns, triggers, indexes, error functions, migration files, and the underscore-prefix variable rules.
---

# PostgreSQL naming conventions

These rules extend the [general naming conventions](../coding-guidelines/general-naming-conventions.md). Where the general rules and these overlap, the general rule is canonical; this page adds the PostgreSQL-specific cases.

The reference implementation cited throughout — `postgresql-permissions-model` — is the canonical example. When in doubt, do what it does.

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
| Local variables (PL/pgSQL) | `__snake_case` (double leading underscore) | `__user_id`, `__perms text[]`, `__expiration_date` |
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

## Schemas

A small, fixed set. Don't invent new schemas casually — each one is an access boundary the application has to grant on.

| Schema | Role | What lives here |
|--------|------|-----------------|
| `public` | Application-level "public" | Cross-cutting infrastructure (`__version`, `journal`, version-tracking functions, `format_journal_message`, app-specific public functions). Always permission-checks where appropriate. |
| `auth` | Authorization domain + public API | All `auth.user_info`, `auth.tenant`, `auth.permission`, `auth.permission_assignment` tables AND the `auth.*` functions that wrap them with permission checks. The application's primary entry point. |
| `unsecure` | Trusted internal implementation | Functions that perform mutations without permission checks. Called only by `auth.*` and by triggers. Never granted to the application role directly. |
| `internal` | Trusted helpers | Resolvers (`resolve_user`, `resolve_tenant`, `resolve_cross_tenant_access`), throwers (`throw_no_permission`), validators. Stateless, no mutation. |
| `helpers` | Pure utilities | String normalization, jsonb operations, ltree manipulation. Marked `immutable` / `stable` / `parallel safe`. |
| `const` | Lookup tables | `const.token_type`, `const.user_type`, `const.event_code`, `const.sys_param`. FK target instead of `CHECK` enums. |
| `error` | Error functions | One `error.raise_NNNNN(...)` per error code. Centralized message wording. |
| `triggers` | Trigger functions | Trigger function bodies, separated from the tables they fire on for clarity. |
| `stage` | Batch / ETL staging | Tables that hold imported rows before they are processed into the canonical schemas. |
| `ext` | External extensions | `ltree`, `uuid-ossp`, `unaccent`, `pg_trgm`. Pinned here so `search_path` is predictable. |

If you need an application-specific schema (`billing`, `inventory`, …), follow the same split: `billing` for tables and public functions, `billing_unsecure` (or place internals in the global `unsecure`) for trusted internals, reuse the global `helpers` / `error` / `triggers`.

## Tables

**Singular form.** A table represents one row's worth of concept: `user_info`, `tenant`, `permission`, `user_group_member`. Plural is reserved for views.

**No `tbl_` / `t_` prefix.** The schema name (`auth.user_info`) already disambiguates from functions.

**Reserved-word collisions are resolved with a suffix, not abbreviations.** `user` is reserved, so the table is `auth.user_info`, not `auth.usr` or `auth.user_`. The columns inside it are still `user_id`, `username`, `email` — only the table name carries the suffix.

**Composite-concept tables use the hierarchy rule from the general guidelines.** Primary noun first, secondary second:

- `auth.user_group_member` — primary `user_group`, secondary `member`
- `auth.permission_assignment` — primary `permission`, secondary `assignment`
- `auth.user_group_mapping` — primary `user_group`, secondary `mapping`

The function operating on a secondary object **names both** unless the provider context makes it unambiguous: `auth.create_user_group_member(...)`, not `create_member(...)`.

## Columns

### Identifiers

- Primary key column: `<table-singular>_id`, e.g. `user_id` in `auth.user_info`, `tenant_id` in `auth.tenant`. **No bare `id`.**
- Type: `bigint generated by default as identity` for high-volume / app-facing rows (users, journal); `integer generated always as identity` for low-volume reference rows (tenants, permissions, const tables).
- `generated always` blocks application-side inserts of an `id` value; `generated by default` allows them (necessary when seeding fixed IDs). Pick the stricter option unless you need otherwise.
- Foreign-key column name **equals the target's PK column name**: `user_id`, `tenant_id`, `provider_code`. When a table has multiple FKs to the same target, prefix with the role: `created_by_user_id`, `assigned_user_id`.
- Codes as identifiers: `const.*` lookups use `code text primary key`, and referencing columns are `<concept>_code` — `user_type_code`, `token_type_code`, `provider_code`.

### Audit columns (universal — every table)

```sql
created_at timestamp with time zone default now()           not null,
created_by text                     default 'unknown'::text not null,
updated_at timestamp with time zone default now()           not null,
updated_by text                     default 'unknown'::text not null,
```

- Always `timestamp with time zone` (`timestamptz`). Never naked `timestamp`.
- `created_by` / `updated_by` are **strings** (username / system actor), not user-id FKs. This survives user deletion, allows `'system'` / `'trigger'` / `'unknown'` sentinels, and keeps the audit trail readable.
- `'unknown'` default exists for backfills and trigger inserts that genuinely don't know the actor; production paths should always pass a real value.
- A few link tables omit `updated_by` / `updated_at` because they have no mutable columns (`tenant_user`, `permission_assignment`, `perm_set_perm`, `user_group_member`, `user_group_mapping`). That is fine — every mutation deletes-and-reinserts the link.

### Booleans — `is_`, `has_`, `allows_`, `should_`

| Prefix | Meaning | Example |
|--------|---------|---------|
| `is_` | Current state | `is_active`, `is_deleted`, `is_locked`, `is_verified`, `is_system` |
| `has_` | Possession | `has_mfa`, `has_password` |
| `allows_` | Configuration permission | `allows_group_sync`, `allows_group_mapping`, `allows_self_registration` |
| `should_` | Policy / preference | `should_send_welcome_email` |

Do not name a boolean `active`, `deleted`, `locked` — the prefix carries information about how to read it.

**Exception, for parity with HTML / external systems:** if a column reflects a flag from an external system (LDAP, OAuth provider), keep the external name unprefixed (`enabled`, `verified`) so the mapping is obvious. This is the SQL equivalent of the [JavaScript data-model-booleans rule](../coding-guidelines-javascript/naming-conventions.md#data-model-booleans-follow-html-convention) — domain shapes follow the source, not the convention.

### Normalized / computed columns — `nrm_` prefix

When the same data needs a searchable (lowercased, accent-stripped) form, store it as a generated column with a `nrm_` prefix:

```sql
nrm_username    text generated always as (lower(username)) stored not null,
nrm_search_data text,  -- updated by trigger from helpers.normalize_text(...)
```

`nrm_search_data` is typically too complex for `generated always`; it's filled by a `before insert or update` trigger calling a `triggers.calculate_<table>_search_values(...)` helper.

Index those columns with `ix_trgm_<table>_search using gist (nrm_search_data gist_trgm_ops)` for substring matching, or with `ix_<table>_<col>` for equality.

### JSONB columns

Bare nouns: `settings`, `preferences`, `custom_data`, `data_payload`, `keys`, `request_context`. No `_json` or `_jsonb` suffix — the column type already says that.

For partial-merge semantics (pass only the keys you change; pass `null` to remove a key), document the behavior in the function that updates the column, not in the column name.

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

## Parameters and variables — the underscore-prefix rules

This is the single most important PG-specific convention. Get it wrong and PL/pgSQL ambiguity errors will hunt you.

| Prefix | Meaning | Example |
|--------|---------|---------|
| `_` (single) | **Input parameter of a function.** Reserved exclusively for this purpose. | `_user_id bigint`, `_correlation_id text`, `_tenant_id integer default 1` |
| `__` (double) | **Local variable** declared in the `declare` block. Also: **column name in a `returns TABLE(...)` clause.** | `declare __user_id bigint; __perms text[];` and `returns TABLE(__user_id bigint, __is_active boolean)` |
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

## Views

**Plural form** — a view is "many rows of the concept": `auth.active_user_groups`, `auth.user_group_members`, `auth.effective_permissions`.

No `v_` / `view_` prefix.

Column aliases in views are bare snake_case (no `__` prefix; `__` is reserved for function return columns and locals).

Views used by notification triggers to resolve "who cares about this change" follow `notify_<source>_<target>` (e.g. `auth.notify_group_users` returns the user_ids affected by a group-permission change).

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
| Calling `auth.foo()` from `auth.bar()` | Double permission check, transactional weirdness | Extract shared logic into `unsecure.bar()`; call from both `auth.*` functions |
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

## See also

- [General naming conventions](../coding-guidelines/general-naming-conventions.md) — the shared verb registry and singular/plural rules.
- [General coding structure](../coding-guidelines/layers-of-application.md) — the three-layer model.
- [PostgreSQL coding guidelines (this section's index)](./index.md) — schemas as layers, the public/internal/unsecure rule, multi-tenant access, version management.
- Reference implementation: `postgresql-permissions-model` — the codebase these conventions were extracted from.
