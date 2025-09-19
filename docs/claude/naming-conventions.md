# Naming Conventions

!!! info "Guideline Metadata"
    **Version**: 1.0.0
    **Last Modified**: 2025-01-19T00:00:00Z
    **Category**: Core Guidelines
    **Priority**: Critical

Standardized naming patterns across all projects and technologies.

## General Rules

### Universal Principles
1. **Descriptive over Short** - `getUserById()` not `getUser()`
2. **No Abbreviations** - `userManager` not `usrMgr`
3. **Consistent Language** - All names in English
4. **No Magic Numbers** - Use named constants

### Casing Standards
- **camelCase**: Variables, functions, methods
- **PascalCase**: Classes, interfaces, components, types
- **kebab-case**: Files, URLs, CSS classes
- **SCREAMING_SNAKE_CASE**: Constants, environment variables
- **snake_case**: Database tables, columns

## Files and Folders

### File Naming
```
# Good
user-provider.ts
order-manager.ts
payment-service.ts
user-profile.component.svelte

# Bad
UserProvider.ts
orderMgr.ts
payment_service.ts
```

### Folder Structure
```
src/
├── providers/
├── managers/
├── io/
├── models/
├── mappers/
├── helpers/
├── constants/
└── types/
```

## Functions and Methods

### Naming Patterns
```typescript
// CRUD Operations
getUserById(id: string)
createUser(userData: CreateUserRequest)
updateUser(id: string, changes: UpdateUserRequest)
deleteUser(id: string)

// Boolean Functions
isValid(data: unknown): boolean
hasPermission(user: User, action: string): boolean
canAccess(resource: Resource): boolean

// Async Functions
async fetchUsers(): Promise<User[]>
async saveUser(user: User): Promise<void>

// Validation
validateEmail(email: string): ValidationResult
validatePassword(password: string): ValidationResult

// Transformation
mapUserToDto(user: User): UserDto
parseUserInput(input: string): ParsedUser
```

### Function Categories
- **get/fetch**: Retrieve data (get = sync, fetch = async)
- **create/add**: Create new entities
- **update/modify**: Change existing entities
- **delete/remove**: Remove entities
- **validate**: Check data validity
- **parse**: Convert data formats
- **map**: Transform data structures
- **calculate**: Perform computations
- **generate**: Create derived data

## Variables

### Descriptive Names
```typescript
// Good
const userAccountBalance = 150.50;
const isUserLoggedIn = checkAuth();
const maxRetryAttempts = 3;

// Bad
const balance = 150.50;
const loggedIn = checkAuth();
const max = 3;
```

### Collection Names
```typescript
// Arrays/Lists
const users = []; // plural
const userList = []; // explicit list
const activeUsers = []; // descriptive

// Maps/Objects
const userById = new Map();
const configByEnvironment = {};

// Sets
const uniqueUserIds = new Set();
const visitedPages = new Set();
```

## Classes and Interfaces

### Classes
```typescript
// Service classes
class UserProvider {}
class OrderManager {}
class PaymentService {}

// Model classes
class User {}
class Order {}
class PaymentRequest {}

// Helper classes
class DateHelper {}
class ValidationHelper {}
class CryptoHelper {}
```

### Interfaces
```typescript
// Data contracts
interface User {}
interface CreateUserRequest {}
interface UserResponse {}

// Behavior contracts
interface UserProvider {}
interface PaymentGateway {}
interface Logger {}

// Configuration
interface DatabaseConfig {}
interface ApiSettings {}
```

## Database Naming

### Tables
```sql
-- Use singular, snake_case
users
user_accounts
order_items
payment_transactions

-- Not plural or camelCase
user -- singular
userAccounts -- camelCase
```

### Columns
```sql
-- Descriptive, snake_case
user_id
email_address
created_at
updated_at
is_active
account_balance

-- Foreign keys with table prefix
user_id (references users.id)
order_id (references orders.id)
```

### Indexes
```sql
-- Pattern: idx_table_column(s)
idx_users_email
idx_orders_user_id_created_at
idx_payments_status_date
```

## Constants and Enums

### Constants
```typescript
// Application constants
const MAX_LOGIN_ATTEMPTS = 3;
const DEFAULT_PAGE_SIZE = 20;
const API_BASE_URL = 'https://api.example.com';

// Error messages
const ERROR_USER_NOT_FOUND = 'User not found';
const ERROR_INVALID_CREDENTIALS = 'Invalid credentials';
```

### Enums
```typescript
// Status enums
enum UserStatus {
    Active = 'active',
    Inactive = 'inactive',
    Suspended = 'suspended'
}

// Action enums
enum PaymentAction {
    Charge = 'charge',
    Refund = 'refund',
    Authorize = 'authorize'
}
```

## Component Naming (Svelte/React)

### Component Files
```
// PascalCase.svelte
UserProfile.svelte
OrderSummary.svelte
PaymentForm.svelte

// Page components
UserDashboard.svelte
OrderHistory.svelte
```

### Component Properties
```typescript
// Props use camelCase
interface UserProfileProps {
    userId: string;
    showActions: boolean;
    onUserUpdate: (user: User) => void;
}
```

## API Naming

### Endpoints
```
// RESTful patterns
GET    /api/users           # Get all users
GET    /api/users/{id}      # Get specific user
POST   /api/users           # Create user
PUT    /api/users/{id}      # Update user
DELETE /api/users/{id}      # Delete user

// Action endpoints
POST   /api/users/{id}/activate
POST   /api/orders/{id}/cancel
POST   /api/payments/{id}/refund
```

### Request/Response Types
```typescript
// Request DTOs
interface CreateUserRequest {}
interface UpdateOrderRequest {}
interface ProcessPaymentRequest {}

// Response DTOs
interface UserResponse {}
interface OrderListResponse {}
interface PaymentStatusResponse {}
```

## Environment Variables

### Naming Pattern
```bash
# Pattern: COMPONENT_PURPOSE_DETAIL
DATABASE_CONNECTION_STRING
API_BASE_URL
REDIS_CACHE_HOST
SMTP_SERVER_HOST
JWT_SECRET_KEY

# Environment specific
DEV_DATABASE_URL
PROD_DATABASE_URL
TEST_API_KEY
```

## Test Files

### Test File Names
```
# Pattern: [component].test.[ext]
user-provider.test.ts
order-manager.test.ts
payment-service.test.ts

# Integration tests
user-api.integration.test.ts
payment-flow.e2e.test.ts
```

### Test Function Names
```typescript
describe('UserProvider', () => {
    describe('getUserById', () => {
        it('should return user when id exists', () => {});
        it('should return null when id does not exist', () => {});
        it('should throw error when id is invalid', () => {});
    });
});
```

## Anti-Patterns to Avoid

### Bad Naming Examples
```typescript
// Too generic
const data = fetchStuff();
const result = doThing();

// Misleading
const getUsersAsync(); // Not actually async
const user = getUsers(); // Returns array

// Abbreviations
const usrMgr = new UserManager();
const btnClk = handleClick;

// Inconsistent
const user_id = 1; // mixing snake_case in camelCase context
const UserID = 2;   // inconsistent casing
```

### Good Alternatives
```typescript
// Specific and clear
const userAccounts = fetchUserAccounts();
const validationResult = validateUserInput();

// Accurate naming
const getUsers(); // sync function
const fetchUsersAsync(); // async function

// Full words
const userManager = new UserManager();
const handleButtonClick = handleClick;

// Consistent casing
const userId = 1;
const userAccountId = 2;
```