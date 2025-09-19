# Common Solutions

!!! info "Guideline Metadata"
    **Version**: 1.0.0
    **Last Modified**: 2025-01-19T00:00:00Z
    **Category**: Implementation Guidelines
    **Priority**: High

Reusable solutions and patterns for frequently encountered problems across projects.

## Error Handling Patterns

### Result Pattern Implementation
```typescript
// Base Result type
export interface Result<T> {
    success: boolean;
    data?: T;
    error?: string;
}

// Helper functions
export class ResultHelper {
    static success<T>(data: T): Result<T> {
        return { success: true, data };
    }

    static failure<T>(error: string): Result<T> {
        return { success: false, error };
    }

    static async fromPromise<T>(
        promise: Promise<T>,
        errorMessage?: string
    ): Promise<Result<T>> {
        try {
            const data = await promise;
            return ResultHelper.success(data);
        } catch (error) {
            return ResultHelper.failure(
                errorMessage || (error as Error).message
            );
        }
    }
}

// Usage example
async function createUser(userData: CreateUserData): Promise<Result<User>> {
    return ResultHelper.fromPromise(
        this.userProvider.createUser(userData),
        'Failed to create user'
    );
}
```

### Custom Error Classes
```typescript
// Base error class
export class AppError extends Error {
    constructor(
        message: string,
        public code: string,
        public statusCode: number = 500
    ) {
        super(message);
        this.name = this.constructor.name;
    }
}

// Specific error types
export class ValidationError extends AppError {
    constructor(message: string) {
        super(message, 'VALIDATION_ERROR', 400);
    }
}

export class NotFoundError extends AppError {
    constructor(resource: string) {
        super(`${resource} not found`, 'NOT_FOUND', 404);
    }
}

export class DatabaseError extends AppError {
    constructor(message: string, originalError?: Error) {
        super(message, 'DATABASE_ERROR', 500);
        if (originalError) {
            this.stack = originalError.stack;
        }
    }
}
```

## Validation Patterns

### Input Validation with Zod
```typescript
import { z } from 'zod';

// Schema definitions
export const CreateUserSchema = z.object({
    email: z.string().email('Invalid email format'),
    name: z.string().min(1, 'Name is required').max(100, 'Name too long'),
    age: z.number().int().min(18, 'Must be at least 18')
});

export const UpdateUserSchema = CreateUserSchema.partial();

// Validation helper
export class ValidationHelper {
    static validate<T>(schema: z.ZodSchema<T>, data: unknown): Result<T> {
        try {
            const validData = schema.parse(data);
            return ResultHelper.success(validData);
        } catch (error) {
            if (error instanceof z.ZodError) {
                const messages = error.errors.map(e => e.message).join(', ');
                return ResultHelper.failure(`Validation failed: ${messages}`);
            }
            return ResultHelper.failure('Validation failed');
        }
    }
}

// Usage in manager
export class UserManager {
    async createUser(userData: unknown): Promise<Result<User>> {
        const validation = ValidationHelper.validate(CreateUserSchema, userData);
        if (!validation.success) {
            return validation;
        }

        return this.userProvider.createUser(validation.data);
    }
}
```

### Business Rule Validation
```typescript
// Business rule validators
export class UserBusinessRules {
    static async validateUserCreation(
        userData: CreateUserData,
        userProvider: UserProvider
    ): Promise<Result<void>> {
        // Check if email already exists
        const existingUser = await userProvider.getUserByEmail(userData.email);
        if (existingUser) {
            return ResultHelper.failure('Email already registered');
        }

        // Check age requirement
        if (userData.age < 18) {
            return ResultHelper.failure('User must be at least 18 years old');
        }

        return ResultHelper.success(undefined);
    }
}

// Usage in manager
export class UserManager {
    async createUser(userData: CreateUserData): Promise<Result<User>> {
        const businessValidation = await UserBusinessRules.validateUserCreation(
            userData,
            this.userProvider
        );

        if (!businessValidation.success) {
            return businessValidation;
        }

        return this.userProvider.createUser(userData);
    }
}
```

## Database Patterns

### Connection Management
```typescript
// Database connection interface
export interface Database {
    query<T>(sql: string, params?: unknown[]): Promise<T[]>;
    queryOne<T>(sql: string, params?: unknown[]): Promise<T | null>;
    transaction<T>(callback: (tx: Database) => Promise<T>): Promise<T>;
}

// PostgreSQL implementation
export class PostgresDatabase implements Database {
    constructor(private pool: Pool) {}

    async query<T>(sql: string, params: unknown[] = []): Promise<T[]> {
        try {
            const result = await this.pool.query(sql, params);
            return result.rows;
        } catch (error) {
            throw new DatabaseError('Query failed', error as Error);
        }
    }

    async queryOne<T>(sql: string, params: unknown[] = []): Promise<T | null> {
        const results = await this.query<T>(sql, params);
        return results[0] || null;
    }

    async transaction<T>(callback: (tx: Database) => Promise<T>): Promise<T> {
        const client = await this.pool.connect();

        try {
            await client.query('BEGIN');
            const tx = new PostgresTransaction(client);
            const result = await callback(tx);
            await client.query('COMMIT');
            return result;
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }
}
```

### Query Builder Pattern
```typescript
export class QueryBuilder {
    private selectClause = '';
    private fromClause = '';
    private whereConditions: string[] = [];
    private params: unknown[] = [];

    select(columns: string): QueryBuilder {
        this.selectClause = `SELECT ${columns}`;
        return this;
    }

    from(table: string): QueryBuilder {
        this.fromClause = `FROM ${table}`;
        return this;
    }

    where(condition: string, value: unknown): QueryBuilder {
        this.whereConditions.push(`${condition} = $${this.params.length + 1}`);
        this.params.push(value);
        return this;
    }

    build(): { sql: string; params: unknown[] } {
        const whereClause = this.whereConditions.length > 0
            ? `WHERE ${this.whereConditions.join(' AND ')}`
            : '';

        const sql = [this.selectClause, this.fromClause, whereClause]
            .filter(clause => clause)
            .join(' ');

        return { sql, params: this.params };
    }
}

// Usage
const query = new QueryBuilder()
    .select('id, email, name')
    .from('users')
    .where('status', 'active')
    .where('age >', 18)
    .build();

const users = await database.query<User>(query.sql, query.params);
```

## Caching Patterns

### In-Memory Cache
```typescript
export interface CacheProvider {
    get<T>(key: string): Promise<T | null>;
    set<T>(key: string, value: T, ttlSeconds?: number): Promise<void>;
    delete(key: string): Promise<void>;
    clear(): Promise<void>;
}

export class MemoryCacheProvider implements CacheProvider {
    private cache = new Map<string, { value: unknown; expires: number }>();

    async get<T>(key: string): Promise<T | null> {
        const item = this.cache.get(key);

        if (!item) {
            return null;
        }

        if (Date.now() > item.expires) {
            this.cache.delete(key);
            return null;
        }

        return item.value as T;
    }

    async set<T>(key: string, value: T, ttlSeconds = 300): Promise<void> {
        const expires = Date.now() + (ttlSeconds * 1000);
        this.cache.set(key, { value, expires });
    }

    async delete(key: string): Promise<void> {
        this.cache.delete(key);
    }

    async clear(): Promise<void> {
        this.cache.clear();
    }
}

// Cached provider wrapper
export class CachedUserProvider implements UserProvider {
    constructor(
        private userProvider: UserProvider,
        private cache: CacheProvider
    ) {}

    async getUserById(id: string): Promise<User | null> {
        const cacheKey = `user:${id}`;
        const cached = await this.cache.get<User>(cacheKey);

        if (cached) {
            return cached;
        }

        const user = await this.userProvider.getUserById(id);

        if (user) {
            await this.cache.set(cacheKey, user, 300); // 5 minutes
        }

        return user;
    }
}
```

## Authentication Patterns

### JWT Token Handling
```typescript
import jwt from 'jsonwebtoken';

export interface TokenPayload {
    userId: string;
    email: string;
    role: string;
}

export class TokenService {
    constructor(private secretKey: string) {}

    generateToken(payload: TokenPayload): string {
        return jwt.sign(payload, this.secretKey, { expiresIn: '24h' });
    }

    verifyToken(token: string): Result<TokenPayload> {
        try {
            const payload = jwt.verify(token, this.secretKey) as TokenPayload;
            return ResultHelper.success(payload);
        } catch (error) {
            return ResultHelper.failure('Invalid token');
        }
    }
}

// Authentication middleware
export function authMiddleware(tokenService: TokenService) {
    return async (req: Request, res: Response, next: NextFunction) => {
        const authHeader = req.headers.authorization;

        if (!authHeader?.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Missing or invalid token' });
        }

        const token = authHeader.substring(7);
        const verification = tokenService.verifyToken(token);

        if (!verification.success) {
            return res.status(401).json({ error: verification.error });
        }

        req.user = verification.data;
        next();
    };
}
```

### Role-Based Access Control
```typescript
export enum UserRole {
    Admin = 'admin',
    User = 'user',
    Guest = 'guest'
}

export class AuthorizationService {
    private static roleHierarchy = {
        [UserRole.Admin]: [UserRole.Admin, UserRole.User, UserRole.Guest],
        [UserRole.User]: [UserRole.User, UserRole.Guest],
        [UserRole.Guest]: [UserRole.Guest]
    };

    static hasRole(userRole: UserRole, requiredRole: UserRole): boolean {
        return this.roleHierarchy[userRole].includes(requiredRole);
    }

    static requireRole(requiredRole: UserRole) {
        return (req: Request, res: Response, next: NextFunction) => {
            const user = req.user as TokenPayload;

            if (!user) {
                return res.status(401).json({ error: 'Authentication required' });
            }

            if (!this.hasRole(user.role as UserRole, requiredRole)) {
                return res.status(403).json({ error: 'Insufficient permissions' });
            }

            next();
        };
    }
}
```

## API Response Patterns

### Standardized API Responses
```typescript
export interface ApiResponse<T> {
    success: boolean;
    data?: T;
    error?: string;
    meta?: {
        timestamp: string;
        requestId: string;
    };
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
    pagination: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}

// Response builder
export class ResponseBuilder {
    static success<T>(data: T, requestId: string): ApiResponse<T> {
        return {
            success: true,
            data,
            meta: {
                timestamp: new Date().toISOString(),
                requestId
            }
        };
    }

    static error(error: string, requestId: string): ApiResponse<never> {
        return {
            success: false,
            error,
            meta: {
                timestamp: new Date().toISOString(),
                requestId
            }
        };
    }

    static paginated<T>(
        data: T[],
        pagination: { page: number; limit: number; total: number },
        requestId: string
    ): PaginatedResponse<T> {
        return {
            success: true,
            data,
            pagination: {
                ...pagination,
                totalPages: Math.ceil(pagination.total / pagination.limit)
            },
            meta: {
                timestamp: new Date().toISOString(),
                requestId
            }
        };
    }
}
```

## Logging Patterns

### Structured Logging
```typescript
export enum LogLevel {
    Debug = 'debug',
    Info = 'info',
    Warn = 'warn',
    Error = 'error'
}

export interface LogEntry {
    level: LogLevel;
    message: string;
    timestamp: string;
    context?: Record<string, unknown>;
    error?: Error;
}

export interface Logger {
    debug(message: string, context?: Record<string, unknown>): void;
    info(message: string, context?: Record<string, unknown>): void;
    warn(message: string, context?: Record<string, unknown>): void;
    error(message: string, error?: Error, context?: Record<string, unknown>): void;
}

export class ConsoleLogger implements Logger {
    constructor(private minLevel: LogLevel = LogLevel.Info) {}

    debug(message: string, context?: Record<string, unknown>): void {
        this.log(LogLevel.Debug, message, context);
    }

    info(message: string, context?: Record<string, unknown>): void {
        this.log(LogLevel.Info, message, context);
    }

    warn(message: string, context?: Record<string, unknown>): void {
        this.log(LogLevel.Warn, message, context);
    }

    error(message: string, error?: Error, context?: Record<string, unknown>): void {
        this.log(LogLevel.Error, message, context, error);
    }

    private log(
        level: LogLevel,
        message: string,
        context?: Record<string, unknown>,
        error?: Error
    ): void {
        if (!this.shouldLog(level)) {
            return;
        }

        const entry: LogEntry = {
            level,
            message,
            timestamp: new Date().toISOString(),
            context,
            error
        };

        console.log(JSON.stringify(entry));
    }

    private shouldLog(level: LogLevel): boolean {
        const levels = [LogLevel.Debug, LogLevel.Info, LogLevel.Warn, LogLevel.Error];
        return levels.indexOf(level) >= levels.indexOf(this.minLevel);
    }
}
```

## Configuration Patterns

### Environment Configuration
```typescript
export interface AppConfig {
    port: number;
    database: {
        url: string;
        maxConnections: number;
    };
    redis: {
        url: string;
    };
    jwt: {
        secret: string;
        expiresIn: string;
    };
    email: {
        host: string;
        port: number;
        username: string;
        password: string;
    };
}

export class ConfigService {
    private static instance: AppConfig;

    static load(): AppConfig {
        if (this.instance) {
            return this.instance;
        }

        this.instance = {
            port: parseInt(process.env.PORT || '3000'),
            database: {
                url: this.requireEnv('DATABASE_URL'),
                maxConnections: parseInt(process.env.DB_MAX_CONNECTIONS || '10')
            },
            redis: {
                url: this.requireEnv('REDIS_URL')
            },
            jwt: {
                secret: this.requireEnv('JWT_SECRET'),
                expiresIn: process.env.JWT_EXPIRES_IN || '24h'
            },
            email: {
                host: this.requireEnv('EMAIL_HOST'),
                port: parseInt(process.env.EMAIL_PORT || '587'),
                username: this.requireEnv('EMAIL_USERNAME'),
                password: this.requireEnv('EMAIL_PASSWORD')
            }
        };

        return this.instance;
    }

    private static requireEnv(key: string): string {
        const value = process.env[key];
        if (!value) {
            throw new Error(`Required environment variable ${key} is not set`);
        }
        return value;
    }
}
```

## Testing Patterns

### Mock Factories
```typescript
// Mock data factories
export class UserFactory {
    static create(overrides: Partial<User> = {}): User {
        return {
            id: '1',
            email: 'test@example.com',
            name: 'Test User',
            createdAt: new Date(),
            ...overrides
        };
    }

    static createMany(count: number, overrides: Partial<User> = {}): User[] {
        return Array.from({ length: count }, (_, i) =>
            this.create({ id: (i + 1).toString(), ...overrides })
        );
    }
}

// Provider mocks
export class MockUserProvider implements UserProvider {
    private users: User[] = [];

    async getUserById(id: string): Promise<User | null> {
        return this.users.find(user => user.id === id) || null;
    }

    async createUser(userData: CreateUserData): Promise<User> {
        const user = UserFactory.create({
            id: (this.users.length + 1).toString(),
            ...userData
        });
        this.users.push(user);
        return user;
    }

    // Test helpers
    addUser(user: User): void {
        this.users.push(user);
    }

    clear(): void {
        this.users = [];
    }
}
```

### Integration Test Helpers
```typescript
export class TestHelper {
    static async createTestDatabase(): Promise<Database> {
        // Create test database connection
        // Run migrations
        // Return database instance
    }

    static async cleanupDatabase(db: Database): Promise<void> {
        // Clean up test data
        // Reset sequences
    }

    static async createTestUser(db: Database): Promise<User> {
        // Create test user in database
        // Return user instance
    }
}

// Test setup
describe('UserManager Integration', () => {
    let database: Database;
    let userManager: UserManager;

    beforeEach(async () => {
        database = await TestHelper.createTestDatabase();
        const userProvider = new DatabaseUserProvider(database);
        userManager = new UserManager(userProvider);
    });

    afterEach(async () => {
        await TestHelper.cleanupDatabase(database);
    });

    it('should create user in database', async () => {
        const userData = { email: 'test@example.com', name: 'Test User' };
        const result = await userManager.createUser(userData);

        expect(result.success).toBe(true);
        expect(result.data.email).toBe(userData.email);
    });
});
```