# General Principles

!!! info "Guideline Metadata"
    **Version**: 1.0.0
    **Last Modified**: 2025-01-19T00:00:00Z
    **Category**: Core Guidelines
    **Priority**: Critical

Core working principles for all projects developed with Claude Code.

## Communication

### Language Convention
- **User communication**: Czech (čeština)
- **Code and documentation**: English
- **Comments in code**: English
- **Git commits**: English

### Response Style
- Direct and concise
- Focus on implementation over explanation
- Show code first, explain if needed
- No unnecessary preambles

## Development Workflow

### 1. Task Planning
Always use TodoWrite tool for:
- Tasks with 3+ steps
- Complex implementations
- Multiple file modifications
- Bug fixing with investigation

### 2. Investigation First
Before implementing:
- Search existing codebase for patterns
- Check dependencies and imports
- Understand current architecture
- Look for similar implementations

### 3. Follow Existing Patterns
- Match code style in existing files
- Use established libraries (don't introduce new ones)
- Follow naming conventions
- Maintain consistency over personal preference

## Code Quality

### Never Compromise On
1. **Security**: No hardcoded secrets, proper validation
2. **Type Safety**: Full typing in TypeScript/C#
3. **Error Handling**: Explicit error handling everywhere
4. **Testing**: Write tests for critical logic

### Always Prefer
- Explicit over implicit
- Readability over cleverness
- Composition over inheritance
- Pure functions over side effects

## File Management

### Creation Rules
- **NEVER** create files unless absolutely necessary
- **ALWAYS** prefer editing existing files
- **NEVER** create documentation proactively
- **ONLY** create what's explicitly requested

### Modification Rules
- Understand context before editing
- Preserve existing formatting
- Keep changes minimal and focused
- Don't refactor unrelated code

## Architecture Principles

### Three-Layer Rule
```
IO Layer ← → Management Layer ← → Provider Layer
                    ↑
                Side Layer
           (Models, Mappers, Helpers)
```

**Strict Rules:**
- Providers NEVER talk to each other
- Management orchestrates all provider interaction
- IO handles all external communication
- Side layer has no dependencies on other layers

### Provider Pattern
Each provider:
- Has single responsibility
- Returns domain models (not raw data)
- Handles its own errors
- Is independently testable

## Error Handling - "Let It Crash" Philosophy

Following Erlang's "Let it crash" philosophy adapted for our architecture:

### Core Principles
1. **Fail fast, fail loud** - Better to crash immediately than hide errors
2. **Trust your layers** - Lower layers trust input from upper layers
3. **Minimal transformation** - Pass external data as-is when possible
4. **Single logging point** - Log errors once at the catch point

### Layer Responsibilities
- **Lower layers**: Assume input is pre-validated, no re-validation
- **Providers**: Pass external data as-is, no unnecessary mapping
- **Errors**: Let them bubble up, don't hide or swallow
- **Logging**: Log once at the top layer where caught

### Standard Approach
```typescript
try {
    // Happy path
    return { success: true, data: result };
} catch (error) {
    // Explicit error handling
    logger.error('Operation failed', error);
    return { success: false, error: error.message };
}
```

### Never
- Swallow errors silently
- Use generic error messages
- Throw in providers (return error objects)
- Log sensitive information

## Git Workflow

### Commit Messages
Format: `<type>: <description>`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring
- `docs`: Documentation
- `test`: Testing
- `chore`: Maintenance

### Branch Strategy
- `main`/`prod`: Production code
- `feature/*`: New features
- `fix/*`: Bug fixes
- `refactor/*`: Code improvements

## Performance Considerations

### Always
- Batch database operations
- Use pagination for lists
- Cache expensive computations
- Lazy load when possible

### Never
- Premature optimization
- N+1 queries
- Synchronous blocking operations
- Memory leaks (cleanup subscriptions)

## Testing Philosophy

### Test Priority
1. Critical business logic
2. Data transformations
3. Edge cases
4. Integration points

### Test Structure
```typescript
describe('Component/Function', () => {
    describe('method', () => {
        it('should handle normal case', () => {});
        it('should handle edge case', () => {});
        it('should handle error case', () => {});
    });
});
```

## Code Review Checklist

Before considering task complete:
- [ ] Follows existing patterns
- [ ] Has error handling
- [ ] No hardcoded values
- [ ] Tests pass
- [ ] No console.logs
- [ ] Types are complete
- [ ] Names are descriptive