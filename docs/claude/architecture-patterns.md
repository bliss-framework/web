# Architecture Patterns

!!! info "Guideline Metadata"
    **Version**: 1.0.0
    **Last Modified**: 2025-01-19T00:00:00Z
    **Category**: Core Guidelines
    **Priority**: Critical

Standardized architectural patterns and implementation guidelines for all projects.

## Three-Layer Architecture

The fundamental architecture pattern used across all projects.

### Layer Overview

```mermaid
graph TB
    subgraph "External World"
        HTTP[HTTP Requests]
        DB[(Database)]
        API[External APIs]
        FILES[File System]
    end

    subgraph "Application Layers"
        subgraph "IO Layer"
            CONTROLLERS[Controllers/Routes]
            VALIDATION[Input Validation]
            SERIALIZATION[Response Serialization]
        end

        subgraph "Management Layer"
            MANAGERS[Managers]
            ORCHESTRATION[Business Logic]
            COORDINATION[Provider Coordination]
        end

        subgraph "Provider Layer"
            DB_PROVIDER[Database Provider]
            API_PROVIDER[API Provider]
            FILE_PROVIDER[File Provider]
        end

        subgraph "Side Layer"
            MODELS[Models]
            MAPPERS[Mappers]
            HELPERS[Helpers]
            CONSTANTS[Constants/Enums]
        end
    end

    HTTP --> CONTROLLERS
    CONTROLLERS --> MANAGERS
    MANAGERS --> DB_PROVIDER
    MANAGERS --> API_PROVIDER
    MANAGERS --> FILE_PROVIDER
    DB_PROVIDER --> DB
    API_PROVIDER --> API
    FILE_PROVIDER --> FILES

    MANAGERS -.-> MODELS
    MANAGERS -.-> MAPPERS
    MANAGERS -.-> HELPERS

    classDef ioLayer fill:#e1f5fe
    classDef managementLayer fill:#f3e5f5
    classDef providerLayer fill:#e8f5e8
    classDef sideLayer fill:#fff3e0

    class CONTROLLERS,VALIDATION,SERIALIZATION ioLayer
    class MANAGERS,ORCHESTRATION,COORDINATION managementLayer
    class DB_PROVIDER,API_PROVIDER,FILE_PROVIDER providerLayer
    class MODELS,MAPPERS,HELPERS,CONSTANTS sideLayer
```

### Layer Responsibilities

#### IO Layer
- **Purpose**: Handle external communication
- **Responsibilities**:
  - Receive and validate input
  - Format and send responses
  - Handle authentication/authorization
  - Rate limiting and request logging

```typescript
// Example: API Controller
export class UserController {
    constructor(private userManager: UserManager) {}

    async getUser(req: Request, res: Response) {
        const { id } = this.validateGetUserRequest(req);
        const result = await this.userManager.getUserById(id);

        if (!result.success) {
            return res.status(404).json({ error: result.error });
        }

        res.json(this.formatUserResponse(result.data));
    }

    private validateGetUserRequest(req: Request): { id: string } {
        // Input validation logic
    }

    private formatUserResponse(user: User): UserResponse {
        // Response formatting logic
    }
}
```

#### Management Layer
- **Purpose**: Orchestrate business logic
- **Responsibilities**:
  - Coordinate between providers
  - Implement business rules
  - Handle complex operations
  - Manage transactions

```typescript
// Example: User Manager
export class UserManager {
    constructor(
        private userProvider: UserProvider,
        private emailProvider: EmailProvider,
        private auditProvider: AuditProvider
    ) {}

    async createUser(userData: CreateUserRequest): Promise<Result<User>> {
        try {
            // Validate business rules
            const validation = this.validateUserData(userData);
            if (!validation.success) {
                return { success: false, error: validation.error };
            }

            // Coordinate multiple providers
            const user = await this.userProvider.createUser(userData);
            await this.emailProvider.sendWelcomeEmail(user.email);
            await this.auditProvider.logUserCreation(user.id);

            return { success: true, data: user };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }
}
```

#### Provider Layer
- **Purpose**: Perform specific tasks
- **Responsibilities**:
  - Database operations
  - External API calls
  - File system operations
  - Cache management

```typescript
// Example: Database Provider
export class UserProvider {
    constructor(private db: Database) {}

    async getUserById(id: string): Promise<User | null> {
        const row = await this.db.query(
            'SELECT * FROM users WHERE id = $1',
            [id]
        );

        return row ? this.mapRowToUser(row) : null;
    }

    async createUser(userData: CreateUserData): Promise<User> {
        const row = await this.db.query(
            'INSERT INTO users (email, name) VALUES ($1, $2) RETURNING *',
            [userData.email, userData.name]
        );

        return this.mapRowToUser(row);
    }

    private mapRowToUser(row: DatabaseRow): User {
        return {
            id: row.id,
            email: row.email,
            name: row.name,
            createdAt: row.created_at
        };
    }
}
```

#### Side Layer
- **Purpose**: Support all layers with shared utilities
- **Components**:
  - Models (data structures)
  - Mappers (data transformation)
  - Helpers (utility functions)
  - Constants and enums

```typescript
// Models
export interface User {
    id: string;
    email: string;
    name: string;
    createdAt: Date;
}

// Mappers
export class UserMapper {
    static toDto(user: User): UserDto {
        return {
            id: user.id,
            email: user.email,
            displayName: user.name
        };
    }
}

// Helpers
export class DateHelper {
    static formatDate(date: Date): string {
        return date.toISOString().split('T')[0];
    }
}

// Constants
export const USER_CONSTANTS = {
    MAX_NAME_LENGTH: 100,
    MIN_PASSWORD_LENGTH: 8
} as const;
```

## Critical Architecture Rules

### Rule 1: No Provider-to-Provider Communication
```typescript
// ❌ WRONG: Providers calling each other
export class UserProvider {
    constructor(private orderProvider: OrderProvider) {} // NO!

    async deleteUser(id: string) {
        await this.orderProvider.deleteUserOrders(id); // NO!
    }
}

// ✅ CORRECT: Manager orchestrates
export class UserManager {
    constructor(
        private userProvider: UserProvider,
        private orderProvider: OrderProvider
    ) {}

    async deleteUser(id: string) {
        await this.orderProvider.deleteUserOrders(id);
        await this.userProvider.deleteUser(id);
    }
}
```

### Rule 2: Providers Return Domain Models
```typescript
// ❌ WRONG: Returning raw database rows
async getUserById(id: string): Promise<DatabaseRow> {
    return this.db.query('SELECT * FROM users WHERE id = $1', [id]);
}

// ✅ CORRECT: Returning domain models
async getUserById(id: string): Promise<User | null> {
    const row = await this.db.query('SELECT * FROM users WHERE id = $1', [id]);
    return row ? this.mapRowToUser(row) : null;
}
```

### Rule 3: Error Handling at Layer Boundaries
```typescript
// Providers: Return null/throw specific errors
export class UserProvider {
    async getUserById(id: string): Promise<User | null> {
        try {
            const row = await this.db.query(/* ... */);
            return row ? this.mapRowToUser(row) : null;
        } catch (error) {
            throw new DatabaseError('Failed to fetch user', error);
        }
    }
}

// Managers: Return Result objects
export class UserManager {
    async getUserById(id: string): Promise<Result<User>> {
        try {
            const user = await this.userProvider.getUserById(id);
            return user
                ? { success: true, data: user }
                : { success: false, error: 'User not found' };
        } catch (error) {
            return { success: false, error: error.message };
        }
    }
}

// IO Layer: Convert to HTTP responses
export class UserController {
    async getUser(req: Request, res: Response) {
        const result = await this.userManager.getUserById(req.params.id);

        if (!result.success) {
            return res.status(404).json({ error: result.error });
        }

        res.json(result.data);
    }
}
```

## Common Patterns

### Result Pattern
```typescript
export interface Result<T> {
    success: boolean;
    data?: T;
    error?: string;
}

// Usage
const result = await userManager.createUser(userData);
if (result.success) {
    // Handle success
    console.log(result.data);
} else {
    // Handle error
    console.error(result.error);
}
```

### Repository Pattern (for Providers)
```typescript
export interface UserProvider {
    getUserById(id: string): Promise<User | null>;
    createUser(userData: CreateUserData): Promise<User>;
    updateUser(id: string, changes: Partial<User>): Promise<User>;
    deleteUser(id: string): Promise<void>;
}

export class DatabaseUserProvider implements UserProvider {
    // Implementation
}

export class MockUserProvider implements UserProvider {
    // Test implementation
}
```

### Factory Pattern (for Complex Creation)
```typescript
export class ServiceFactory {
    static createUserService(config: Config): UserManager {
        const userProvider = new DatabaseUserProvider(config.database);
        const emailProvider = new EmailProvider(config.email);
        const auditProvider = new AuditProvider(config.audit);

        return new UserManager(userProvider, emailProvider, auditProvider);
    }
}
```

## Project Structure Template

### Standard Folder Structure
```
src/
├── io/                     # IO Layer
│   ├── controllers/        # HTTP controllers
│   ├── routes/            # Route definitions
│   ├── middleware/        # Request middleware
│   └── validators/        # Input validation
│
├── managers/              # Management Layer
│   ├── user-manager.ts
│   ├── order-manager.ts
│   └── payment-manager.ts
│
├── providers/             # Provider Layer
│   ├── database/
│   │   ├── user-provider.ts
│   │   └── order-provider.ts
│   ├── external/
│   │   ├── email-provider.ts
│   │   └── payment-provider.ts
│   └── file/
│       └── storage-provider.ts
│
├── models/               # Side Layer - Data structures
│   ├── user.ts
│   ├── order.ts
│   └── payment.ts
│
├── mappers/              # Side Layer - Data transformation
│   ├── user-mapper.ts
│   └── order-mapper.ts
│
├── helpers/              # Side Layer - Utilities
│   ├── date-helper.ts
│   ├── validation-helper.ts
│   └── crypto-helper.ts
│
├── constants/            # Side Layer - Configuration
│   ├── app-constants.ts
│   └── error-messages.ts
│
└── types/               # Side Layer - Type definitions
    ├── api-types.ts
    └── database-types.ts
```

### Technology-Specific Adaptations

#### SvelteKit Project
```
src/
├── routes/               # SvelteKit routes (IO Layer)
├── lib/
│   ├── managers/
│   ├── providers/
│   ├── models/
│   ├── mappers/
│   ├── helpers/
│   └── constants/
└── app.html
```

#### Node.js/Express API
```
src/
├── controllers/          # Express controllers (IO Layer)
├── routes/              # Express routes (IO Layer)
├── middleware/          # Express middleware (IO Layer)
├── managers/            # Management Layer
├── providers/           # Provider Layer
├── models/              # Domain models
├── mappers/             # Data transformation
├── helpers/             # Utilities
└── constants/           # Configuration
```

#### C# Web API
```
ProjectName/
├── Controllers/         # ASP.NET controllers (IO Layer)
├── Managers/           # Management Layer
├── Providers/          # Provider Layer
├── Models/             # Domain models
├── Mappers/            # Data transformation
├── Helpers/            # Utilities
└── Constants/          # Configuration
```

## Testing Architecture

### Test Structure Mirrors Code Structure
```
tests/
├── unit/
│   ├── managers/
│   ├── providers/
│   ├── mappers/
│   └── helpers/
├── integration/
│   ├── api/
│   └── database/
└── e2e/
    └── user-flows/
```

### Testing Each Layer
```typescript
// Provider tests (unit)
describe('UserProvider', () => {
    it('should return user when exists', async () => {
        const provider = new UserProvider(mockDatabase);
        const user = await provider.getUserById('123');
        expect(user).toEqual(expectedUser);
    });
});

// Manager tests (unit with mocked providers)
describe('UserManager', () => {
    it('should create user and send email', async () => {
        const manager = new UserManager(mockUserProvider, mockEmailProvider);
        const result = await manager.createUser(userData);
        expect(result.success).toBe(true);
        expect(mockEmailProvider.sendWelcomeEmail).toHaveBeenCalled();
    });
});

// Controller tests (integration)
describe('UserController', () => {
    it('should return 200 for valid user', async () => {
        const response = await request(app).get('/api/users/123');
        expect(response.status).toBe(200);
        expect(response.body).toEqual(expectedUserResponse);
    });
});
```

## Performance Considerations

### Database Layer Optimization
- Use connection pooling
- Implement query batching
- Add proper indexes
- Use transactions for multi-operation flows

### Caching Strategy
- Provider-level caching for external APIs
- Manager-level caching for computed results
- HTTP-level caching for static responses

### Async/Await Best Practices
```typescript
// ✅ Good: Parallel execution when possible
async function getUserWithOrders(userId: string) {
    const [user, orders] = await Promise.all([
        userProvider.getUserById(userId),
        orderProvider.getOrdersByUserId(userId)
    ]);

    return { user, orders };
}

// ❌ Bad: Sequential when parallel is possible
async function getUserWithOrders(userId: string) {
    const user = await userProvider.getUserById(userId);
    const orders = await orderProvider.getOrdersByUserId(userId);

    return { user, orders };
}
```