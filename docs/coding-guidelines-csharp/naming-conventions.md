---
description: C# naming conventions — the master casing summary, known abbreviations, and how the reference is organized.
---

# C# naming conventions

These rules extend the [general naming conventions](../coding-guidelines/general-naming-conventions.md). Where the general rules and these overlap, the general rule is canonical; this page adds the C#-specific cases.

We assume Microsoft's [C# naming and coding guidelines](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions) as the baseline — `PascalCase` for types, methods, properties and constants; `camelCase` for locals and parameters; `I`-prefixed interfaces; the `Async` suffix on awaitable methods. This page documents the points where the Bliss Framework constrains or extends those defaults — including one deliberate deviation from Microsoft's default (fields are **not** `_`-prefixed).

This reference is split across several pages:

- [Layer types](layer-types.md) — Controllers, Managers, Providers, Services, Interfaces, and the project / namespace layout.
- [Side-layer types](side-layer-types.md) — Models, Mappers, Helpers, Options, Constants & Enums, Exceptions, Jobs.
- [Methods & parameters](methods-and-parameters.md) — the verb registry, parameter order (`ctx` first, `CancellationToken` last), plain-camelCase fields, constructors / DI, logging, generated code, comments.
- [Anti-patterns & worked example](anti-patterns-and-example.md).

## Casing summary

| Used for | Casing | Example |
|----------|--------|---------|
| Projects | `Company.Product.Layer` (`PascalCase`, dotted) | `TwinPeaks.DocumentHub.Web`, `TwinPeaks.DocumentHub.Database` |
| Namespaces | Match folder path, `PascalCase` | `TwinPeaks.DocumentHub.Web.Managers` |
| Files | `PascalCase.cs`, one top-level type per file, named after the type | `DocumentsManager.cs`, `IDocumentProvider.cs` |
| Folders | `PascalCase`, plural for collections of a kind | `Controllers/`, `Managers/`, `Models/Documents/` |
| Classes, records, structs, enums | `PascalCase` | `DocumentsManager`, `UserContext`, `ADProviderTypes` |
| Interfaces | `I` + `PascalCase` | `IDocumentsManager`, `IEmailProvider` |
| Methods | `PascalCase`, verb-first, `Async` suffix when awaitable | `GetDocumentsAsync`, `EnsureUserAsync` |
| Properties | `PascalCase` | `DocumentCode`, `SelectedTenant` |
| Public constants | `PascalCase` (name), value is whatever the domain needs | `JobRunTypeCodes.ADSync = "ad_sync"` |
| Private fields | **`camelCase`, no `_` prefix** | `logger`, `documentProvider`, `commonProvider` |
| Local variables | `camelCase`, `var` when the type is obvious | `var rows`, `UserContext ctx` |
| Parameters | `camelCase` | `documentCode`, `ctx`, `cancellationToken` |
| Enum members | `PascalCase` | `EmailProviderType.Smtp` |
| Type parameters | `T` + `PascalCase` | `ResponseModel<TData, TMetadata>` |
| Known abbreviations | kept as a unit, upper for 2-letter, cased for longer | `AD`, `OID`, `GC`, `UTM`, `UUID`, `SHA` |

Formatting baseline (from `.editorconfig`): **tabs, width 2**, max line length 160, final newline, UTF-8. Braces on their own line (Allman). Prefer file-scoped namespaces (`namespace Foo;`) in new files.

### Known abbreviations

The solution's ReSharper settings register a fixed set of abbreviations that stay upper-cased inside identifiers instead of being lower-camel'd: `AD`, `GC`, `OID`, `SHA`, `UTM`, `UUID`. So it is `GetADObjectFullName`, `ProviderOID`, `ToSHA256`, `SelectedTenantUUID` — not `GetAdObjectFullName`, `ProviderOid`. Add a new abbreviation to the `.DotSettings` list rather than casing it ad-hoc, so the whole team's tooling agrees.

## See also

- [General naming conventions](../coding-guidelines/general-naming-conventions.md) — the shared verb registry and the singular/plural rule.
- [C# coding guidelines (this section's index)](./index.md) — one-project-vs-several, layering, `UserContext`, configuration, error handling, jobs.
- [PostgreSQL naming conventions](../coding-guidelines-postgres/naming-conventions.md) — governs every name you see in `DbContext`.
- [Elixir naming conventions](../coding-guidelines-elixir/naming-conventions.md) — the same verb registry and `ctx`-first rule in a `snake_case` world.
- [Microsoft C# coding conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions) — the baseline this page extends.
