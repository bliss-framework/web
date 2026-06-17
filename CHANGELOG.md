# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- **Verb registry**: added `Check` to the standard verb list in `coding-guidelines/general-naming-conventions.md` and the `claude/naming-conventions.{md,txt}` mirrors. Introduced the _Check vs Validate vs Verify vs Is/Has/Can vs Ensure_ comparison table to settle when each verb applies (read-only inspection vs boundary-gate validation vs postcondition assertion vs property-style predicate vs idempotent upsert).
- **JavaScript / web-component coding guidelines**: new top-level section `coding-guidelines-javascript/` with `index.md` (component-shaped layering, what's different vs C#/PG, what stays the same) and `naming-conventions.md` covering casing, file naming, custom-element tag rules, class suffix conventions (`Element` for the custom-element wrapper), TS interface suffixes (`Config` / `Options` / `EventDetail` / `Context` / `Spec`), DOM-specific verbs (`render` / `handle` / `dispatch` / `attach` / `mount` / `observe` / `compute` / `position` / `commit` / `reconcile`), async vs sync conventions, boolean attribute semantics (`bool-default-true` vs `bool-default-false`), HTML attribute ↔ config-key mapping, the consumer-callback hierarchy (`on*` for Svelte-component notifications, `*Callback` for plain-JS config notifications, `before*Callback` for interceptors, `get*Callback` paired with `*Member` for data extractors, plain `*Callback` for behavior providers — with a decision flowchart and a quick test), `CustomEvent` naming (bare strings matching HTML standard), UI vocabulary collisions to watch for (`options` / `value` / `target` / `data` / `name` / `key` / `index`), and two worked examples — `@keenmate/web-multiselect` for the web-component side and `@keenmate/svelte-treeview` for the Svelte-component side, with a shared-conventions summary highlighting what's identical between them. Linked from the language-specific cards grid in `coding-guidelines/general-naming-conventions.md` and wired into `mkdocs.yml` nav.

### Fixed

- **CI/CD**: Repaired the `prod` deployment workflow (`.github/workflows/prod.yml`).
  - Removed broken `${{ inputs.dockerfile-name }}` reference (no `inputs` were defined on the job).
  - Upgraded action versions: `docker/login-action@v2` → `v3`, `docker/build-push-action@v5` → `v6`, `appleboy/ssh-action@v0.1.5` → `v1`.
  - Replaced deprecated `docker-compose` CLI with Docker Compose V2 (`docker compose`).
  - Split the single job into separate `build` and `deploy` jobs so SSH deploy only runs after a successful image push.
  - Dropped the unused `NPM_SCRIPT` build-arg (the Dockerfile is MkDocs-only) and the unnecessary `repository` / `token` parameters on `actions/checkout`.

[Unreleased]: https://github.com/bliss-framework/web/commits/prod
