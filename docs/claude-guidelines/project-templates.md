# Project Templates

!!! info "Guideline Metadata"
    **Version**: 1.0.0
    **Last Modified**: 2025-01-19T00:00:00Z
    **Category**: Implementation Guidelines
    **Priority**: High

Standardized project structures and setup templates for different technology stacks.

## CLAUDE.md Template

Every project should include a `CLAUDE.md` file at the root:

```markdown
# CLAUDE.md

This project follows the Bliss Framework Claude Guidelines.
See: https://bliss-framework.org/claude-guidelines/

## Project Overview
[Brief description of what this project does]

## Technology Stack
- **Language**: TypeScript/C#/Elixir
- **Framework**: SvelteKit/ASP.NET Core/Phoenix
- **Database**: PostgreSQL/SQLite/MongoDB
- **Testing**: Vitest/xUnit/ExUnit

## Architecture
This project follows the three-layer architecture:
- **IO Layer**: [Controllers/Routes location]
- **Management Layer**: [Managers location]
- **Provider Layer**: [Providers location]
- **Side Layer**: [Models, Mappers, Helpers location]

## Commands

### Development
```bash
# Start development server
[command]

# Run tests
[command]

# Lint code
[command]

# Type check
[command]
```

### Build
```bash
# Build for production
[command]

# Build Docker image
[command]
```

## Project-Specific Guidelines
[Any project-specific deviations or additions to standard guidelines]

## Database Schema
[Link to schema documentation or brief overview]

## API Documentation
[Link to API docs or brief overview of endpoints]
```

## SvelteKit Template

### Project Structure
```
project-name/
├── src/
│   ├── routes/                 # SvelteKit routes (IO Layer)
│   │   ├── api/               # API endpoints
│   │   │   ├── users/
│   │   │   │   ├── +server.ts
│   │   │   │   └── [id]/
│   │   │   │       └── +server.ts
│   │   │   └── orders/
│   │   └── (app)/             # App routes
│   │       ├── dashboard/
│   │       └── profile/
│   ├── lib/
│   │   ├── managers/          # Management Layer
│   │   │   ├── user-manager.ts
│   │   │   └── order-manager.ts
│   │   ├── providers/         # Provider Layer
│   │   │   ├── database/
│   │   │   │   ├── user-provider.ts
│   │   │   │   └── order-provider.ts
│   │   │   └── external/
│   │   │       └── email-provider.ts
│   │   ├── models/            # Side Layer
│   │   │   ├── user.ts
│   │   │   └── order.ts
│   │   ├── mappers/
│   │   │   └── user-mapper.ts
│   │   ├── helpers/
│   │   │   ├── validation-helper.ts
│   │   │   └── date-helper.ts
│   │   ├── constants/
│   │   │   └── app-constants.ts
│   │   └── components/        # UI Components
│   │       ├── ui/            # Generic UI
│   │       └── domain/        # Domain-specific
│   ├── app.html
│   └── app.d.ts
├── tests/
├── static/
├── package.json
├── vite.config.js
├── svelte.config.js
├── tsconfig.json
├── CLAUDE.md
└── README.md
```

### Key Files

#### `src/routes/api/users/+server.ts`
```typescript
import { json, type RequestHandler } from '@sveltejs/kit';
import { UserManager } from '$lib/managers/user-manager.js';

export const GET: RequestHandler = async ({ url }) => {
    const userManager = new UserManager(/* inject dependencies */);

    const page = parseInt(url.searchParams.get('page') ?? '1');
    const result = await userManager.getUsers({ page });

    if (!result.success) {
        return json({ error: result.error }, { status: 400 });
    }

    return json(result.data);
};

export const POST: RequestHandler = async ({ request }) => {
    const userManager = new UserManager(/* inject dependencies */);

    const userData = await request.json();
    const result = await userManager.createUser(userData);

    if (!result.success) {
        return json({ error: result.error }, { status: 400 });
    }

    return json(result.data, { status: 201 });
};
```

#### `package.json` Scripts
```json
{
    "scripts": {
        "dev": "vite dev",
        "build": "vite build",
        "preview": "vite preview",
        "test": "vitest",
        "test:ui": "vitest --ui",
        "lint": "eslint .",
        "lint:fix": "eslint . --fix",
        "type-check": "svelte-check --tsconfig ./tsconfig.json"
    }
}
```

## Node.js/Express API Template

### Project Structure
```
project-name/
├── src/
│   ├── controllers/           # IO Layer
│   │   ├── user-controller.ts
│   │   └── order-controller.ts
│   ├── routes/               # IO Layer
│   │   ├── users.ts
│   │   └── orders.ts
│   ├── middleware/           # IO Layer
│   │   ├── auth-middleware.ts
│   │   └── validation-middleware.ts
│   ├── managers/             # Management Layer
│   │   ├── user-manager.ts
│   │   └── order-manager.ts
│   ├── providers/            # Provider Layer
│   │   ├── database/
│   │   └── external/
│   ├── models/               # Side Layer
│   ├── mappers/
│   ├── helpers/
│   ├── constants/
│   └── app.ts               # Application entry
├── tests/
├── package.json
├── tsconfig.json
├── CLAUDE.md
└── README.md
```

### Key Files

#### `src/app.ts`
```typescript
import express from 'express';
import { userRoutes } from './routes/users.js';
import { orderRoutes } from './routes/orders.js';
import { errorHandler } from './middleware/error-handler.js';

const app = express();

app.use(express.json());
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);
app.use(errorHandler);

export { app };
```

#### `src/controllers/user-controller.ts`
```typescript
import { Request, Response } from 'express';
import { UserManager } from '../managers/user-manager.js';

export class UserController {
    constructor(private userManager: UserManager) {}

    async getUsers(req: Request, res: Response) {
        const page = parseInt(req.query.page as string) || 1;
        const result = await this.userManager.getUsers({ page });

        if (!result.success) {
            return res.status(400).json({ error: result.error });
        }

        res.json(result.data);
    }

    async createUser(req: Request, res: Response) {
        const result = await this.userManager.createUser(req.body);

        if (!result.success) {
            return res.status(400).json({ error: result.error });
        }

        res.status(201).json(result.data);
    }
}
```

## C# Web API Template

### Project Structure
```
ProjectName/
├── Controllers/              # IO Layer
│   ├── UsersController.cs
│   └── OrdersController.cs
├── Managers/                 # Management Layer
│   ├── UserManager.cs
│   └── OrderManager.cs
├── Providers/                # Provider Layer
│   ├── Database/
│   │   ├── UserProvider.cs
│   │   └── OrderProvider.cs
│   └── External/
│       └── EmailProvider.cs
├── Models/                   # Side Layer
│   ├── User.cs
│   └── Order.cs
├── Mappers/
│   └── UserMapper.cs
├── Helpers/
│   └── ValidationHelper.cs
├── Constants/
│   └── AppConstants.cs
├── Program.cs
├── appsettings.json
├── CLAUDE.md
└── README.md
```

### Key Files

#### `Controllers/UsersController.cs`
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly UserManager _userManager;

    public UsersController(UserManager userManager)
    {
        _userManager = userManager;
    }

    [HttpGet]
    public async Task<IActionResult> GetUsers([FromQuery] int page = 1)
    {
        var result = await _userManager.GetUsersAsync(new GetUsersRequest { Page = page });

        if (!result.Success)
        {
            return BadRequest(new { error = result.Error });
        }

        return Ok(result.Data);
    }

    [HttpPost]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request)
    {
        var result = await _userManager.CreateUserAsync(request);

        if (!result.Success)
        {
            return BadRequest(new { error = result.Error });
        }

        return CreatedAtAction(nameof(GetUser), new { id = result.Data.Id }, result.Data);
    }
}
```

#### `Program.cs`
```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddScoped<UserManager>();
builder.Services.AddScoped<UserProvider>();
builder.Services.AddScoped<EmailProvider>();

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

## Svelte Component Library Template

### Project Structure
```
library-name/
├── src/
│   ├── lib/
│   │   ├── components/        # Exportable components
│   │   │   ├── ui/           # Generic UI components
│   │   │   │   ├── Button/
│   │   │   │   │   ├── Button.svelte
│   │   │   │   │   └── index.ts
│   │   │   │   └── Input/
│   │   │   └── domain/       # Domain-specific components
│   │   ├── helpers/          # Utility functions
│   │   ├── constants/        # Shared constants
│   │   └── types/           # TypeScript types
│   └── routes/              # Demo/documentation pages
├── tests/
├── package.json
├── svelte.config.js
├── vite.config.js
├── CLAUDE.md
└── README.md
```

## Docker Templates

### SvelteKit Dockerfile
```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine AS runner

WORKDIR /app
COPY --from=builder /app/build build/
COPY --from=builder /app/package.json .
COPY --from=builder /app/package-lock.json .

RUN npm ci --only=production

EXPOSE 3000
CMD ["node", "build"]
```

### Node.js API Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY dist/ ./dist/

EXPOSE 3000

USER node

CMD ["node", "dist/app.js"]
```

### C# Web API Dockerfile
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ProjectName.csproj", "./"]
RUN dotnet restore "ProjectName.csproj"
COPY . .
RUN dotnet build "ProjectName.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProjectName.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProjectName.dll"]
```

## Testing Templates

### Vitest Configuration
```typescript
// vite.config.js
import { defineConfig } from 'vite';
import { sveltekit } from '@sveltejs/kit/vite';

export default defineConfig({
    plugins: [sveltekit()],
    test: {
        include: ['src/**/*.{test,spec}.{js,ts}'],
        environment: 'jsdom'
    }
});
```

### Test Structure Example
```typescript
// tests/unit/managers/user-manager.test.ts
import { describe, it, expect, vi } from 'vitest';
import { UserManager } from '../../../src/lib/managers/user-manager';

describe('UserManager', () => {
    const mockUserProvider = {
        getUserById: vi.fn(),
        createUser: vi.fn()
    };

    const mockEmailProvider = {
        sendWelcomeEmail: vi.fn()
    };

    const userManager = new UserManager(mockUserProvider, mockEmailProvider);

    describe('createUser', () => {
        it('should create user and send welcome email', async () => {
            const userData = { email: 'test@example.com', name: 'Test User' };
            const createdUser = { id: '1', ...userData };

            mockUserProvider.createUser.mockResolvedValue(createdUser);
            mockEmailProvider.sendWelcomeEmail.mockResolvedValue(true);

            const result = await userManager.createUser(userData);

            expect(result.success).toBe(true);
            expect(result.data).toEqual(createdUser);
            expect(mockEmailProvider.sendWelcomeEmail).toHaveBeenCalledWith(userData.email);
        });
    });
});
```

## Environment Configuration

### Development Environment
```bash
# .env.development
DATABASE_URL=postgresql://localhost:5432/project_dev
API_BASE_URL=http://localhost:3000
LOG_LEVEL=debug
```

### Production Environment
```bash
# .env.production
DATABASE_URL=${DATABASE_CONNECTION_STRING}
API_BASE_URL=https://api.production.com
LOG_LEVEL=info
```

### Environment Types
```typescript
// src/lib/types/environment.ts
export interface Environment {
    DATABASE_URL: string;
    API_BASE_URL: string;
    LOG_LEVEL: 'debug' | 'info' | 'warn' | 'error';
}
```