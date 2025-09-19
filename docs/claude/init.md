# Claude Code Initialization

Welcome to the Bliss Framework Claude Guidelines initialization system. This page provides a structured way for Claude Code to load and maintain up-to-date project guidelines and conventions.

## 🎯 Purpose

This initialization system ensures that Claude Code:
- Has access to the latest project guidelines and conventions
- Can track versions of guidelines to detect updates
- Maintains consistent behavior across all projects
- Can efficiently update its knowledge when guidelines change

## 📋 Initialization Checklist

When starting work in a new project, Claude Code should:

1. **Detect Project Type** - Analyze project structure and identify technology stack
2. **Load Core Guidelines** - Read universal guideline documents listed below
3. **Load Tech-Specific Guidelines** - Read language/framework-specific guidelines
4. **Store Version Information** - Save version numbers and checksums for future reference
5. **Verify Context** - Confirm all guidelines are properly loaded into working context
6. **Check for Updates** - On subsequent sessions, verify if newer versions are available

### Project Detection Process
Before loading guidelines, Claude Code must:

1. **Scan Project Directory** - Look for characteristic files and folders
2. **Analyze Dependencies** - Check package.json, requirements.txt, etc.
3. **Determine Tech Stack** - Use [project detection system](project-detection.md)
4. **Ask User if Uncertain** - Confirm ambiguous or unrecognized stacks
5. **Load Appropriate Guidelines** - Fetch tech-specific guidelines from [tech stack registry](tech-stacks.json)

## 📚 Required Guidelines

### Core Guidelines (Always Required)
Claude Code must read and internalize these universal guidelines first:

!!! important "Use Raw Text Files"
    Claude Code should fetch and read the **Raw Text URLs** (.txt files) for direct content access.
    The Web View links (.md files) are for human browsing only.

### 1. General Principles ⚡
- **Raw Text URL**: [general-principles.txt](general-principles.txt)
- **Web View**: [General Principles](general-principles.md)
- **Current Version**: `1.0.0`
- **Last Modified**: `2025-01-19T00:00:00Z`
- **Priority**: Critical
- **Description**: Core working principles, communication patterns, and development workflow

### 2. Naming Conventions 📝
- **Raw Text URL**: [naming-conventions.txt](naming-conventions.txt)
- **Web View**: [Naming Conventions](naming-conventions.md)
- **Current Version**: `1.0.0`
- **Last Modified**: `2025-01-19T00:00:00Z`
- **Priority**: Critical
- **Description**: Standardized naming patterns across all technologies and file types

### 3. Architecture Patterns 🏗️
- **Raw Text URL**: [architecture-patterns.txt](architecture-patterns.txt)
- **Web View**: [Architecture Patterns](architecture-patterns.md)
- **Current Version**: `1.0.0`
- **Last Modified**: `2025-01-19T00:00:00Z`
- **Priority**: Critical
- **Description**: Three-layer architecture, provider patterns, and implementation guidelines

### 4. Project Templates 📁
- **Raw Text URL**: [project-templates.txt](project-templates.txt)
- **Web View**: [Project Templates](project-templates.md)
- **Current Version**: `1.0.0`
- **Last Modified**: `2025-01-19T00:00:00Z`
- **Priority**: High
- **Description**: Standardized project structures for different technology stacks

### 5. Common Solutions 🔧
- **Raw Text URL**: [common-solutions.txt](common-solutions.txt)
- **Web View**: [Common Solutions](common-solutions.md)
- **Current Version**: `1.0.0`
- **Last Modified**: `2025-01-19T00:00:00Z`
- **Priority**: High
- **Description**: Reusable patterns and solutions for frequently encountered problems

### Tech-Specific Guidelines (Based on Detected Stack)
After detecting the project technology stack, Claude Code should load additional guidelines:

#### Available Tech Stacks
Reference: [Tech Stack Registry](tech-stacks.json)

#### Example: SvelteKit Project
```
Detected Stack: SvelteKit
Additional Guidelines to Load:
✅ Svelte Guidelines: coding-guidelines-svelte/index.md
✅ TypeScript Conventions: coding-guidelines-typescript/naming-conventions.md
✅ SvelteKit Patterns: project-templates.md#sveltekit-template
✅ Component Solutions: common-solutions.md#svelte-component-patterns
```

#### Example: C# Web API Project
```
Detected Stack: ASP.NET Core Web API
Additional Guidelines to Load:
✅ C# Guidelines: coding-guidelines-csharp/index.md
✅ C# Naming: coding-guidelines-csharp/naming-conventions.md
✅ Web API Template: project-templates.md#csharp-web-api-template
✅ DI Patterns: common-solutions.md#csharp-dependency-injection
```

#### Example: Node.js Express API
```
Detected Stack: Node.js + Express
Additional Guidelines to Load:
✅ TypeScript Guidelines: coding-guidelines-typescript/index.md
✅ Express Template: project-templates.md#nodejs-express-api-template
✅ Middleware Patterns: common-solutions.md#express-middleware-patterns
✅ Error Handling: common-solutions.md#nodejs-error-handling
```

#### Manual Stack Selection
If auto-detection fails, Claude Code should present:
```
🔍 Unable to detect tech stack automatically.

Please select your project type:
1. 🌐 SvelteKit (Full-stack web app)
2. ⚛️ Next.js (React web app)
3. 🖥️ Node.js + Express (Backend API)
4. 🔷 C# ASP.NET Core (Web API)
5. 💜 Elixir + Phoenix (Web framework)
6. 🐍 Python + FastAPI (API framework)
7. 📱 React Native (Mobile app)
8. 🖥️ Electron (Desktop app)
9. 🗄️ PostgreSQL (Database project)
10. 🤷 Other/Generic project

Enter number (1-10):
```

## 🔄 Version Management

### Version Manifest
The current versions of all guidelines are tracked in: [versions.json](versions.json)

### Version Checking Process
1. **Initial Load**: Store version information for all loaded guidelines
2. **Update Check**: Compare stored versions against current manifest
3. **Selective Update**: Only reload guidelines that have newer versions
4. **Version Storage**: Update stored version information after successful load

### Version Format
- **Semantic Versioning**: `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)
- **Timestamp**: ISO 8601 format (e.g., `2025-01-19T14:30:00Z`)
- **Checksum**: SHA-256 hash for content verification

## 💾 Context Storage Format

Claude Code should maintain this information in its working context:

```json
{
  "blissFrameworkGuidelines": {
    "loadedAt": "2025-01-19T14:30:00Z",
    "version": "1.0.0",
    "projectDetection": {
      "detectedStack": "sveltekit",
      "confidence": "high",
      "detectionMethod": "automatic",
      "detectedAt": "2025-01-19T14:30:00Z",
      "keyFiles": ["svelte.config.js", "package.json", "src/routes/+page.svelte"],
      "primaryLanguage": "typescript",
      "framework": "svelte"
    },
    "coreGuidelines": {
      "general-principles": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "status": "loaded"
      },
      "naming-conventions": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "status": "loaded"
      },
      "architecture-patterns": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "status": "loaded"
      },
      "project-templates": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "status": "loaded"
      },
      "common-solutions": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "status": "loaded"
      }
    },
    "techSpecificGuidelines": {
      "coding-guidelines-svelte": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "status": "loaded",
        "relevance": "primary"
      },
      "typescript-conventions": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "status": "loaded",
        "relevance": "language"
      },
      "sveltekit-patterns": {
        "version": "1.0.0",
        "loadedAt": "2025-01-19T14:30:00Z",
        "status": "loaded",
        "relevance": "framework"
      }
    }
  }
}
```

## 🚀 Initialization Commands

### For New Projects
```bash
# Claude Code should execute:
# 1. Detect project technology stack
# 2. Fetch version manifest and tech stack registry
# 3. Load core guidelines in order
# 4. Load tech-specific guidelines based on detected stack
# 5. Store all version information and detection results
# 6. Confirm initialization complete with summary
```

### For Existing Projects
```bash
# Claude Code should execute:
# 1. Check stored project detection and guideline versions
# 2. Fetch current version manifest and tech stack registry
# 3. Re-detect project if major files changed
# 4. Compare versions for both core and tech-specific guidelines
# 5. Update only changed guidelines
# 6. Update stored version information
```

### Project Type Changes
```bash
# If major project files change (e.g., new framework added):
# 1. Re-run project detection
# 2. Compare with stored detection results
# 3. If stack changed, load new tech-specific guidelines
# 4. Notify user of detected changes
# 5. Update stored detection information
```

## ⚠️ Important Instructions for Claude Code

### During Initialization
1. **Read Completely**: Load entire content of each guideline document
2. **Process Sequentially**: Load guidelines in the order listed above
3. **Verify Understanding**: Confirm comprehension of key concepts before proceeding
4. **Store Metadata**: Save version and timestamp information for each loaded guideline

### During Regular Operation
1. **Apply Guidelines**: Follow all loaded guidelines consistently
2. **Reference Appropriately**: Cite specific guidelines when making decisions
3. **Check Updates**: Periodically verify if guidelines have been updated
4. **Maintain Context**: Keep guideline information readily accessible

### Update Detection
```javascript
// Pseudo-code for update checking
function checkForUpdates(storedVersions, currentManifest) {
    const updatesNeeded = [];

    for (const [guideline, currentInfo] of Object.entries(currentManifest.guidelines)) {
        const storedVersion = storedVersions[guideline]?.version;
        const currentVersion = currentInfo.version;

        if (!storedVersion || storedVersion !== currentVersion) {
            updatesNeeded.push({
                guideline,
                storedVersion: storedVersion || 'not loaded',
                currentVersion,
                url: currentInfo.url
            });
        }
    }

    return updatesNeeded;
}
```

## 📊 Status Reporting

After initialization, Claude Code should be able to report:
- Detected project technology stack
- Which core and tech-specific guidelines are loaded
- Version numbers of all loaded guidelines
- Last update check timestamp
- Any guidelines that need updating

Example status output:
```
✅ Bliss Framework Guidelines Status:

🔍 Project Detection:
   Stack: SvelteKit (confidence: high)
   Language: TypeScript
   Detected: 2025-01-19 14:30 UTC

📚 Core Guidelines:
📋 General Principles: v1.0.0 (loaded 2025-01-19 14:30)
📝 Naming Conventions: v1.0.0 (loaded 2025-01-19 14:30)
🏗️ Architecture Patterns: v1.0.0 (loaded 2025-01-19 14:30)
📁 Project Templates: v1.0.0 (loaded 2025-01-19 14:30)
🔧 Common Solutions: v1.0.0 (loaded 2025-01-19 14:30)

🎯 Tech-Specific Guidelines:
🌟 Svelte Guidelines: v1.0.0 (loaded 2025-01-19 14:30)
📘 TypeScript Conventions: v1.0.0 (loaded 2025-01-19 14:30)
⚡ SvelteKit Patterns: v1.0.0 (loaded 2025-01-19 14:30)

Last check: 2025-01-19 14:30 UTC
Status: All guidelines current ✅
Ready for SvelteKit development with Bliss Framework patterns
```

## 🔗 Quick Links

- [Version Manifest](versions.json) - Current versions of all guidelines
- [Claude Code Home](index.md) - Overview and navigation
- [GitHub Repository](https://github.com/bliss-framework/web) - Source code and issue tracking

---

**Next Steps**: After reading this page, Claude Code should proceed to load all guidelines in the order specified above, starting with [General Principles](general-principles.md).