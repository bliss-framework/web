---
description: C# method and parameter naming — the verb registry, parameter order (ctx first, CancellationToken last), plain-camelCase fields, constructors / DI, logging, generated code, and comments.
---

# Methods, parameters & conventions

## Methods — verbs and shapes

The general [Bliss verb registry](../coding-guidelines/general-naming-conventions.md#used-verbs) applies. The C# shapes:

| Verb | Returns | Example |
|------|---------|---------|
| `Get*` | One entity, or a full (unpaged) set; `T?` or throw when absent | `GetDocumentAsync`, `GetUserAvailableTenantsAsync` |
| `Search*` | Paged results — takes filters + paging, returns `PagedResultsModel<T>` | `SearchDocumentsAsync` |
| `Create*` | Insert; returns the new entity (often `T?`) | `CreateDocumentAsync` |
| `Update*` | Update; returns the updated entity or `Task` | `UpdateDocumentAsync` |
| `Delete*` | Delete; returns the deleted entity or `Task` | `DeleteDocumentAsync` |
| `Ensure*` | Idempotent upsert — create if missing, return the entity | `EnsureUserAsync`, `EnsureDocumentContentTextAsync` |
| `Process*` | Multi-step batch operation | `ProcessImportFileAsync` |
| `Parse*` | Input parsing (CSV, Excel, tokens) | `ParseAsync` (on a parsing provider) |
| `Map* / To*` | Side-layer transform (mapper) | `ToUserModel`, `ToScopeModels` |
| `Send*` | Email / SMS / notification dispatch | `SendEmailAsync`, `SendSmsAsync` |
| `Check* / Validate* / Verify*` | See the [general Check-vs-Validate-vs-Verify table](../coding-guidelines/general-naming-conventions.md#check-vs-validate-vs-verify-vs-ishascan) | `CheckPermission`, `ValidateToken`, `VerifySignature` |
| `Is* / Has* / Can* / Should*` | `bool` (or `Task<bool>`) predicate, reads like a property | `IsTenantAvailableForUserAsync`, `HasPermission` |

Shape rules:

- **Every awaitable method ends in `Async`.** No exceptions — apply it 100% consistently and let code review keep it that way.
- **`Get*` for the complete set, `Search*` for paged.** A method that takes `page`/`pageSize` and returns a `PagedResultsModel<T>` is a `Search*`, not a `Get*`. This matches the [PostgreSQL `get_` vs `search_` split](../coding-guidelines-postgres/naming-conventions.md).
- **Boolean predicates read as properties** — `IsActive`, `HasPermission`, `CanEdit`. Don't prefix a predicate with `Get` (`GetIsActive`).
- **`Map*`/`To*` is reserved for pure mappers.** Don't name a fetch-and-transform method `Map*`.
- **No `Do*` / `Handle*` / `_impl` decoration on private methods.** `private` already says private; give it a real name (`AppendDocumentAdditionalInfoAsync`, not `DoAppend`).

### The `My`/current-user shape

When a method is specifically about the calling user and the caller can't vary the target, a `My`-free name that reads off `ctx` is preferred (`GetClientUserContextAsync(ctx, …)`). When you genuinely need both "for me" and "for an arbitrary user" variants, distinguish them by an explicit parameter, not by two differently-named methods for the same operation.

## Parameters

### `ctx` is the first argument

`UserContext` (named `ctx` everywhere) is the first parameter of every controller-to-manager-to-provider call. Always — even when today's body doesn't read every field. Consistency at the call site outweighs parameter parsimony.

```csharp
Task<UpdatedDocument?> CreateDocumentAsync(UserContext ctx, DocumentUpdateModel model, CancellationToken cancellationToken);
Task<DocumentDetailModel> GetDocumentDetailAsync(UserContext ctx, string documentCode, CancellationToken cancellationToken);
```

### `CancellationToken` is the last argument

Every `async` method takes a `CancellationToken` as its **last** parameter and passes it straight through to the calls it makes. Name it **`cancellationToken`** — the full name is the house standard. The abbreviated `ct` appears in some older code and in the generated `DbContext`; prefer `cancellationToken` in hand-written code. Give it a `= default` only where the method is genuinely called both with and without one.

### Parameter order

After `ctx`:

1. **Identifier of the entity acted upon** — `documentCode`, `userId`, `tenantId`.
2. **Required data** — the model to insert, the search text, the file.
3. **Filters and options** — filter bundles, flags.
4. **Pagination** — `page`, `pageSize`.
5. **`CancellationToken`** — always last.

This mirrors the [PostgreSQL parameter order](../coding-guidelines-postgres/naming-conventions.md); a database provider that passes through to `DbContext` is a near-direct forwarding of the same order.

### Standard parameter names

| Parameter | Type | Meaning |
|-----------|------|---------|
| `ctx` | `UserContext` | The actor / request context |
| `documentCode`, `userId`, `<entity>Id` | `string` / `long` / `int` | The thing being acted on |
| `model` | a `*Model` | A bound request/update body |
| `query` | a `*Query` | A search/filter input |
| `page`, `pageSize` | `int?` | Pagination |
| `cancellationToken` | `CancellationToken` | Cooperative cancellation, always last |

## Private fields (plain camelCase)

This is the one deliberate departure from Microsoft's default style, and it is applied consistently across the codebase — plain `camelCase` is the model; any `_`-prefixed fields are the exception to migrate:

- **Private instance fields are `camelCase` with no underscore prefix**: `logger`, `documentProvider`, `commonProvider` — not `_logger`, `_documentProvider`.
- **Assign them with an explicit `this.`** in the constructor to disambiguate from the same-named parameter:

```csharp
public DocumentsManager(
    ILogger<DocumentsManager> logger,
    IDocumentProvider documentProvider,
    CommonProvider commonProvider)
{
    this.logger = logger;
    this.documentProvider = documentProvider;
    this.commonProvider = commonProvider;
}
```

- **`private const`** stays `PascalCase` (`private const string ProviderCode = "aad";`).
- Pick one and hold it: a class must not mix `_field` and `field`. New code uses plain `camelCase`.

## Constructors and dependency injection

- **Classic constructors**, with the `ILogger<T>` first and the `: base(...)` call last where a base class needs it. Primary constructors are not the house style in this codebase — match what surrounds you.
- **Inject interfaces where they exist** (`IDocumentProvider documentProvider`), concrete types where they don't (`CommonProvider commonProvider`).
- **One field per dependency, `readonly`**, assigned once in the constructor. No property injection, no service locator.

## Logging

One convention, project-wide, via Serilog `ILogger<T>` injected as `logger`:

```csharp
logger.LogInformation("Getting documents for user: {username}", ctx.Username);
logger.LogError(ex, "Error occurred while getting documents for user: {username}", ctx.Username);
```

- **Structured placeholders in `{camelCase}`**, never string interpolation into the message template — the properties must stay queryable.
- **`LogError` passes the exception first**, then a message beginning "Error occurred while …".
- **Levels**: `Trace` (provider DB detail) · `Debug` (operation start) · `Information` (user action / state change) · `Warning` (degraded but proceeding) · `Error` (operation failed).

## Generated code (see PostgreSQL)

`Generated/DbContext.cs`, `Generated/Models/*`, `Generated/Processors/*`, and any `*.generated.cs` are produced by `db-gen`. Their names are driven entirely by the [PostgreSQL naming conventions](../coding-guidelines-postgres/naming-conventions.md):

| SQL | C# |
|-----|-----|
| Function `public.create_document(...)` | `DbContext.CreateDocumentAsync(...)` → `List<CreateDocumentModel>` |
| — result row | `Generated/Models/CreateDocumentModel` (`[DbColumnMapping]` per column) |
| — row parser | `Generated/Processors/CreateDocumentProcessor.Process(...)` |
| Function `const.get_business_units(...)` | `DbContext.ConstGetBusinessUnitsAsync(...)` |

Don't rename, wrap, or hand-edit a generated member because you dislike its name. If the name is wrong, fix the SQL function and regenerate.

## Comments

Default to no comment. Add one only when the **why** is non-obvious — a hidden constraint, a workaround for a library quirk, the rationale for a particular default. Don't restate the method body in English. Delete commented-out code; ship it, file an issue, or remove it. The `Autogenerated using db-gen` headers are load-bearing — leave them.
