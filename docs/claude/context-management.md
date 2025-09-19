# Claude Context Management

Instructions for managing Bliss Framework guidelines in Claude Code's working context.

## 🎯 Context Storage Strategy

Claude Code should maintain guideline information persistently across sessions using a standardized format that allows for efficient version checking and updates.

## 📋 Context Structure

### Primary Context Object
```json
{
  "blissFrameworkGuidelines": {
    "metadata": {
      "loadedAt": "2025-01-19T14:30:00Z",
      "frameworkVersion": "1.0.0",
      "lastUpdateCheck": "2025-01-19T14:30:00Z",
      "initializationUrl": "https://bliss-framework.org/claude/init/",
      "manifestUrl": "https://bliss-framework.org/claude/versions.json"
    },
    "guidelines": {
      "general-principles": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "url": "https://bliss-framework.org/claude/general-principles/",
        "checksum": "sha256:abc123...",
        "priority": "critical",
        "status": "loaded",
        "keyPoints": [
          "Czech communication, English code",
          "Three-layer architecture required",
          "Provider pattern for external dependencies",
          "Result pattern for error handling"
        ]
      },
      "naming-conventions": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "url": "https://bliss-framework.org/claude/naming-conventions/",
        "checksum": "sha256:def456...",
        "priority": "critical",
        "status": "loaded",
        "keyPoints": [
          "camelCase for functions and variables",
          "PascalCase for classes and components",
          "kebab-case for files",
          "snake_case for database"
        ]
      },
      "architecture-patterns": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "url": "https://bliss-framework.org/claude/architecture-patterns/",
        "checksum": "sha256:ghi789...",
        "priority": "critical",
        "status": "loaded",
        "keyPoints": [
          "IO Layer: External communication",
          "Management Layer: Business logic orchestration",
          "Provider Layer: Specific tasks",
          "Side Layer: Shared utilities"
        ]
      },
      "project-templates": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "url": "https://bliss-framework.org/claude/project-templates/",
        "checksum": "sha256:jkl012...",
        "priority": "high",
        "status": "loaded",
        "keyPoints": [
          "CLAUDE.md required in every project",
          "Standard folder structures defined",
          "Technology-specific templates available"
        ]
      },
      "common-solutions": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "url": "https://bliss-framework.org/claude/common-solutions/",
        "checksum": "sha256:mno345...",
        "priority": "high",
        "status": "loaded",
        "keyPoints": [
          "Result pattern for error handling",
          "Validation patterns with Zod",
          "Database connection management",
          "Authentication and authorization patterns"
        ]
      }
    }
  }
}
```

## 🔄 Update Workflow

### Initial Initialization
1. **First Time Setup**:
   ```
   User: "Go to bliss-framework.org/claude/init"
   Claude: Fetches init page → Loads all guidelines → Stores context
   ```

2. **Context Storage**:
   - Store complete guideline content summaries
   - Store version numbers and checksums
   - Store key implementation points
   - Store last loaded timestamps

### Subsequent Sessions
1. **Version Check**:
   ```
   On session start → Check stored versions → Compare with manifest
   If updates available → Load updated guidelines → Update context
   ```

2. **Update Process**:
   - Fetch current manifest from `versions.json`
   - Compare stored versions with current versions
   - Download and process only updated guidelines
   - Update context with new information
   - Report what was updated

## 📝 Implementation Commands

### Context Initialization
```json
{
  "action": "initialize_bliss_framework",
  "steps": [
    "Fetch https://bliss-framework.org/claude/init/",
    "Read all referenced guidelines in order",
    "Extract key points from each guideline",
    "Store structured context information",
    "Confirm initialization complete"
  ]
}
```

### Version Checking
```json
{
  "action": "check_guideline_updates",
  "steps": [
    "Fetch https://bliss-framework.org/claude/versions.json",
    "Compare stored versions with current manifest",
    "Identify guidelines needing updates",
    "Report update status to user"
  ]
}
```

### Selective Updates
```json
{
  "action": "update_guidelines",
  "parameters": {
    "guidelinesToUpdate": ["naming-conventions", "architecture-patterns"],
    "reason": "Version mismatch detected"
  },
  "steps": [
    "Load updated guideline content",
    "Extract and store key points",
    "Update version information",
    "Confirm successful update"
  ]
}
```

## 🎯 Key Points Extraction

For each guideline, Claude should extract and store:

### General Principles
- Communication language rules
- Development workflow patterns
- Code quality standards
- Architecture principles

### Naming Conventions
- Casing rules for different contexts
- File naming patterns
- Function naming patterns
- Database naming standards

### Architecture Patterns
- Three-layer architecture rules
- Provider communication rules
- Error handling patterns
- Testing approaches

### Project Templates
- Required files (CLAUDE.md)
- Standard folder structures
- Technology-specific patterns
- Configuration templates

### Common Solutions
- Error handling implementations
- Validation patterns
- Database patterns
- Authentication patterns

## 🔍 Status Reporting

Claude should be able to provide status reports:

### Initialization Status
```
✅ Bliss Framework Guidelines Initialized
📅 Loaded: 2025-01-19 14:30 UTC
📋 Guidelines: 5/5 loaded successfully
🔄 Next check: Automatic on session start
```

### Update Status
```
🔄 Checking for updates...
📋 General Principles: v1.0.0 ✅ Current
📝 Naming Conventions: v1.1.0 🔄 Update available
🏗️ Architecture Patterns: v1.0.0 ✅ Current
📁 Project Templates: v1.0.0 ✅ Current
🔧 Common Solutions: v1.0.0 ✅ Current

Action: Updating Naming Conventions...
```

### Error Handling
```
❌ Update Check Failed
🌐 Network: Unable to reach manifest
⏰ Last successful check: 2025-01-19 14:30 UTC
📋 Using cached guidelines: v1.0.0
🔄 Will retry on next session
```

## 🚨 Critical Guidelines Summary

Claude should always remember these critical points:

### Communication
- **User communication**: Always in Czech
- **Code and documentation**: Always in English
- **Git commits**: Always in English

### Architecture
- **Three layers**: IO ↔ Management ↔ Provider + Side
- **Provider isolation**: Providers never communicate directly
- **Management orchestration**: All coordination through Management layer

### Naming
- **Functions**: camelCase (`getUserById`)
- **Files**: kebab-case (`user-provider.ts`)
- **Classes**: PascalCase (`UserManager`)
- **Database**: snake_case (`user_accounts`)

### Project Structure
- **Required**: CLAUDE.md in every project root
- **Standard folders**: providers/, managers/, io/, models/, mappers/, helpers/, constants/
- **Testing**: Mirror folder structure in tests/

## 🔧 Troubleshooting

### Common Issues
1. **Version mismatch**: Re-download and compare checksums
2. **Network errors**: Use cached versions and notify user
3. **Parsing errors**: Fall back to previous version and report issue
4. **Missing guidelines**: Re-run full initialization

### Recovery Process
1. **Backup current context** before updates
2. **Attempt selective recovery** if update fails
3. **Full re-initialization** as last resort
4. **Report status** to user throughout process

---

**Implementation Note**: This context management system ensures Claude Code maintains consistent, up-to-date knowledge of Bliss Framework guidelines while providing transparency and reliability in the update process.