---
description: C# Side-layer type naming — Models, Mappers, Helpers, Options, Constants & Enums, Exceptions, and Jobs.
---

# Side-layer types — Models, Mappers, Helpers, Options, Constants, Jobs

## Models — `<Thing>Model` / `<Thing>Request` / `<Thing>Query`

- **Suffix by role**: `*Model` for a general data container (`DocumentModel`, `DocumentDetailModel`), `*Request` for a bound request body when the word "request" reads better (`AssignDocumentsOwnerRequest`), `*Query` for a search/filter input (`GetDocumentsQuery`). `*Dto` is not our convention — use `*Model`.
- **Immutable read model** → `record` or `{ get; init; }` class. **Mutable bound model** → `{ get; set; }` auto-properties (model binding needs setters).
- **`required` and non-null defaults** communicate what the model guarantees; prefer them over a comment.
- **Audit fields** come from the `AuthoredModel` base (`Created`, `CreatedBy`, `Modified`, `ModifiedBy`) — don't re-declare them.
- **Generated row models** (`Generated/Models/CreateDocumentModel`) are named `<StoredFunctionName>Model` by `db-gen` — see [Generated code](methods-and-parameters.md#generated-code-see-postgresql). Application models are distinct from these; a mapper bridges the two.

## Mappers — `<Subject>Mappers`, `To<Target>` methods

- **`static` class**, named `<Subject>Mappers` (`DocumentMappers`, `TypedViewMappers`).
- **Methods are `To<Target>` / `To<Target>Models`**, usually extension methods on the source type: `rows.ToUpdatedDocumentModels()`, `row.ToUserModel()`. Overloads with the same name for different source types are expected.
- **No `Async`, no `ctx`, no I/O.** A `map_*` name that does a fetch-and-transform is a lie — put the fetch in a provider and let the mapper transform the result. See [the general Map verb](../coding-guidelines/general-naming-conventions.md#used-verbs).

## Helpers — `<Domain>Helper(s)`

- **`static` class**, named `<Domain>Helper` or `<Domain>Helpers` (`StringHelpers`, `HashHelper`, `ActiveDirectoryHelpers`, `NpgsqlHelpers`).
- **Stateless, no side effects beyond the obvious.** A helper that touches config, HTTP, or a DB is misfiled — it's a Service or a Provider.
- **Truly generic helpers live in `*.Common`** so they travel; feature-specific ones stay in `*.Web/Helpers`.
- **Extension methods** for framework types go in `<Type>Extensions` classes (`StringExtensions`, `HttpContextExtensions`, `FormFileExtensions`), one extended type per class.

## Options — `<Section>Options`

- **One class per configuration section**, suffixed `Options`: `SmtpOptions`, `ActiveDirectoryOptions`, `JwtOptions`.
- **Bind with `nameof`** where the section name matches the class (`GetSection(nameof(SmtpOptions))`); use an explicit string only when it doesn't (`GetSection("ADOptions")`).
- **Every property has a sensible default** so a missing value is diagnosable. Consume via `IOptions<T>.Value`, read once in the constructor.

## Constants and Enums

- **Constants** — `static class` under `Constants/`, one file per domain (`JobRunTypeCodes`, `SettingsKeys`, `AppClaimTypes`). Member names are `PascalCase`; the *value* is whatever the domain dictates — frequently a `snake_case` database code: `public const string ADSync = "ad_sync";`. The C# name follows C# rules; the string value follows the database's.
- **Enums** — `PascalCase` type and members, under `Enums/`, for closed sets that don't round-trip through the database as free text (`ADProviderTypes`, `EmailProviderType`). If a value is persisted as a code string, prefer a constant over an enum so the stored value is explicit.

## Exceptions — `<Reason>Exception`

Custom exceptions are `PascalCase` ending in `Exception`, derive from `Exception`, and take a message: `NotFoundException`, `NoAvailableTenantException`, `SelectedTenantNotFoundException`. Throw them from managers/providers for domain failures; they surface as an error response via `CatchMiddleware`. See [error handling](./index.md#exceptions-and-the-catch-middleware).

## Jobs — `<Purpose>Job`

Quartz jobs are `PascalCase` ending in `Job`, implement `IJob`, and expose `public static readonly JobKey Key = new JobKey(nameof(XxxJob))`: `ADSyncJob`, `EmailQueueProcessorJob`, `OrphanedFilesRemovalJob`. The name states the maintenance purpose, not the schedule.
