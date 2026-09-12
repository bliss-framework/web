---
description: C# naming anti-patterns table and a worked controller / manager / provider example.
---

# Anti-patterns & worked example

## Anti-patterns

| Anti-pattern | Why | Use instead |
|--------------|-----|-------------|
| `_camelCase` private fields | Not this codebase's convention; mixing the two is the real cost | Plain `camelCase` + `this.field = field` |
| Async method without `Async` suffix | Breaks the 100%-consistent convention; caller can't tell it awaits | `GetDocumentsAsync` |
| `Get*` that takes `page`/`pageSize` and returns a page | Blurs the Get/Search split | `Search*` returning `PagedResultsModel<T>` |
| `GetIsActive` / `Get`-prefixed predicate | A boolean reads as a property | `IsActive`, `HasPermission` |
| `DoCreate`, `HandleUpdate`, `CreateImpl` for a `private` method | `private` already says private | A real name (`AppendDocumentAdditionalInfoAsync`) |
| Interface for every class reflexively | Ceremony with no seam | Interface only when there's a second impl or a test double |
| `DocumentsReadManager` / `DocumentsWriteManager` split | Horizontal split by verb | Split by sub-subject (`DocumentVersionsManager`) |
| A provider calling another provider | Couples the atomic layer | Orchestrate in the manager |
| Calling `DbContext` from a manager/controller | Bypasses the provider seam | Go through the `*Provider` |
| Hand-editing `Generated/*` or `*.generated.cs` | Overwritten on next `db-gen` run | Fix the SQL function, regenerate |
| `IConfiguration["Smtp:Host"]` string indexing in business code | Untyped, scattered, no default | Bind to `*Options`, inject `IOptions<T>` |
| Secrets in a checked-in `appsettings.*.json` | Leaks into VCS | Environment variables (deploy) / user secrets (dev) |
| `HttpContext` / static current-user below the controller | Hidden state, hard to test | Pass `ctx` as the first argument |
| Building `UserContext` inside a manager | The manager shouldn't know about `HttpContext` | Build it in `CommonController.GetUserContextAsync` |
| String interpolation into a log message | Loses structured properties | `logger.LogInformation("... {username}", ctx.Username)` |
| `Map*`/`To*` method that does I/O | A mapper must be a pure transform | Fetch in a provider; transform in the mapper |
| `*Dto` suffix | Not our convention | `*Model` (or `*Request` / `*Query` by role) |
| `CancellationToken ct` in new hand-written code | House standard is the full name | `CancellationToken cancellationToken` |
| Lower-casing a known abbreviation (`GetAdObject`, `ProviderOid`) | Contradicts the registered abbreviation list | `GetADObject`, `ProviderOID`; register new ones in `.DotSettings` |
| Business literal buried inline (`"ad_sync"`) | Duplicated, un-greppable | A `Constants` member (`JobRunTypeCodes.ADSync`) |

## Worked example — controller, manager, provider

The full trio for one operation. The controller binds HTTP and wraps the envelope; the manager orchestrates; the provider does the atomic DB call; the mapper shapes.

```csharp
// I/O — DocumentsController (TwinPeaks.DocumentHub.Web/Controllers)
[HttpPost("documents")]
public async Task<ResponseModel<PagedResultsModel<Document>>> GetDocumentsAsync(
    [FromBody] GetDocumentsQuery query,
    CancellationToken cancellationToken)
{
    UserContext ctx = await GetUserContextAsync(null, cancellationToken);
    logger.LogInformation("Getting documents for user: {username}", ctx.Username);

    try
    {
        PagedResultsModel<Document> results = await documentManager.GetDocumentsAsync(ctx, query, cancellationToken);
        return new ResponseModel<PagedResultsModel<Document>>(results);
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Error occurred while getting documents for user: {username}", ctx.Username);
        return new ErrorResponseModel<PagedResultsModel<Document>>(null);
    }
}
```

```csharp
// Management — DocumentsManager (TwinPeaks.DocumentHub.Web/Managers)
public async Task<PagedResultsModel<Document>> GetDocumentsAsync(UserContext ctx, GetDocumentsQuery query, CancellationToken cancellationToken)
{
    var results = await documentProvider.SearchDocumentsAsync(ctx, query.Filters, query.Pagination, cancellationToken);
    return results;   // provider already returns the paged, mapped shape
}
```

```csharp
// Providers — DocumentProvider (TwinPeaks.DocumentHub.Web/Providers)
public async Task<PagedResultsModel<Document>> SearchDocumentsAsync(
    UserContext ctx, SearchDocumentsFiltersModel? filters, PaginationFilters? pagination, CancellationToken cancellationToken)
{
    var rows = await dbContext.SearchDocumentsAsync(
        ctx.Username, ctx.User.UserId,
        filters?.SearchText.ToOptional() ?? Optional<string>.None,
        (pagination?.Page).ToOptional(),
        (pagination?.PageSize).ToOptional(),
        (ctx.SelectedTenant?.TenantId).ToOptional(),
        cancellationToken);

    return rows.ToDocumentsPagedResult();   // Side-layer mapper: raw rows → PagedResultsModel<Document>
}
```

Four things in four places: the controller binds it to HTTP and the envelope; the manager decides; the provider does the atomic call; the mapper shapes. Each type owns its slice.
