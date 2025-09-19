# Claude Guidelines

!!! info "Guideline Metadata"
    **Version**: 1.0.0
    **Last Modified**: 2025-01-19T00:00:00Z
    **Category**: Overview
    **Priority**: Essential

This section contains specific guidelines for working with Claude Code (claude.ai/code) on projects. These guidelines ensure consistency and efficiency across all collaborative development work.

## Purpose

These guidelines serve as a central reference for:
- General working principles and collaboration patterns
- Naming conventions and coding standards
- Architecture decisions and patterns
- Project structure templates
- Common solutions and approaches

## Structure

The Claude Guidelines are organized into the following sections:

1. **[General Principles](general-principles.md)** - Core working principles and collaboration patterns
2. **[Naming Conventions](naming-conventions.md)** - Standardized naming across all projects
3. **[Architecture Patterns](architecture-patterns.md)** - Common architectural decisions and patterns
4. **[Project Templates](project-templates.md)** - Standardized project structures for different tech stacks
5. **[Common Solutions](common-solutions.md)** - Reusable solutions for recurring problems

## Key Principles

When working with Claude Code on projects:

1. **Consistency First** - Follow established patterns and conventions
2. **Explicit Over Implicit** - Clear, descriptive names and structures
3. **Three-Layer Architecture** - Maintain separation of concerns
4. **Provider Pattern** - Isolate external dependencies
5. **No Magic** - Avoid clever tricks in favor of clarity

## Quick Reference

### File Naming
- Use kebab-case for files: `user-provider.ts`
- Use PascalCase for components: `UserProfile.svelte`
- Use lowercase for database: `user_accounts` table

### Function Naming
- Use camelCase for functions: `getUserById()`
- Use descriptive verbs: `fetch`, `update`, `delete`, `validate`
- Prefix boolean functions with `is`, `has`, `can`: `isValid()`

### Project Structure
```
project/
├── src/
│   ├── providers/     # Data access and external services
│   ├── managers/      # Business logic orchestration
│   ├── io/           # Input/output handling
│   ├── models/       # Data structures
│   ├── mappers/      # Data transformation
│   ├── helpers/      # Utility functions
│   └── constants/    # Configuration and enums
├── tests/
└── docs/
```

## Integration with CLAUDE.md

Each project should have a `CLAUDE.md` file that references these guidelines and adds project-specific instructions. This creates a two-tier system:
- **Global Guidelines** (this section) - Universal rules for all projects
- **Project Guidelines** (CLAUDE.md) - Project-specific additions

Example CLAUDE.md reference:
```markdown
# CLAUDE.md

This project follows the Bliss Framework Claude Guidelines.
See: https://bliss-framework.org/claude-guidelines/

## Project-Specific Instructions
[Project-specific content here]
```