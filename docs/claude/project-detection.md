# Project Detection System

Automated system for detecting project technology stack and loading appropriate guidelines.

## 🎯 Purpose

When Claude Code initializes in a new project, it should:
1. **Detect the technology stack** automatically or by asking user
2. **Load tech-specific guidelines** in addition to core guidelines
3. **Provide context-aware assistance** based on the detected stack

## 🔍 Detection Process

### Automatic Detection
Claude Code should examine the project directory for these patterns:

#### File-Based Detection
```bash
# Check for key files in order of specificity
1. svelte.config.js → SvelteKit
2. next.config.js → Next.js/React
3. nuxt.config.js → Nuxt/Vue
4. mix.exs → Elixir/Phoenix
5. *.csproj → C#/.NET
6. package.json → Node.js (check dependencies)
7. requirements.txt/pyproject.toml → Python
8. Cargo.toml → Rust
```

#### Content-Based Detection
```bash
# Examine package.json dependencies
"@sveltejs/kit" → SvelteKit
"next" → Next.js
"nuxt" → Nuxt
"express" → Node.js/Express
"fastapi" → Python/FastAPI
"react-native" → React Native
"electron" → Electron
```

#### Folder Structure Detection
```bash
# Check for characteristic folders
src/routes/ + src/app.html → SvelteKit
pages/ + next.config.js → Next.js
lib/*_web/ + mix.exs → Phoenix
Controllers/ + *.csproj → ASP.NET Core
android/ + ios/ + package.json → React Native
```

### Manual Selection
If automatic detection fails or is ambiguous:

```
🔍 Project Technology Stack Detection

I couldn't automatically detect your tech stack. Please select:

1. 🌐 Web Frontend:
   a) SvelteKit
   b) Next.js (React)
   c) Nuxt (Vue)
   d) Vanilla TypeScript/JavaScript

2. 🖥️ Backend API:
   a) Node.js + Express
   b) C# ASP.NET Core
   c) Elixir + Phoenix
   d) Python + FastAPI

3. 📱 Mobile:
   a) React Native
   b) Flutter
   c) Native iOS/Android

4. 🗄️ Database:
   a) PostgreSQL
   b) MongoDB
   c) SQLite

5. 🖥️ Desktop:
   a) Electron
   b) Tauri
   c) .NET MAUI

6. 🤷 Other/Mixed Project

Which best describes your project? (enter number + letter, e.g., "1a" for SvelteKit)
```

## 📋 Tech Stack Registry

Reference: [tech-stacks.json](../claude-guidelines/tech-stacks.json)

### Detection Patterns
Each tech stack includes:
- **File patterns**: Key files that indicate the stack
- **Dependency patterns**: Package.json/requirements.txt checks
- **Folder patterns**: Characteristic directory structures
- **Content patterns**: File content indicators

### Associated Guidelines
Each stack specifies:
- **Core guidelines**: Always loaded (architecture, naming, etc.)
- **Language guidelines**: Language-specific conventions
- **Framework guidelines**: Framework-specific patterns
- **Common solutions**: Tech-specific implementation patterns

## 🔄 Context Loading Strategy

### Multi-Tier Loading
```json
{
  "blissFrameworkGuidelines": {
    "core": {
      // Always loaded regardless of stack
      "general-principles": "v1.0.0",
      "naming-conventions": "v1.0.0",
      "architecture-patterns": "v1.0.0"
    },
    "techStack": {
      "detected": "sveltekit",
      "confidence": "high",
      "guidelines": {
        "coding-guidelines-svelte": "v1.0.0",
        "sveltekit-patterns": "v1.0.0"
      }
    },
    "language": {
      "primary": "typescript",
      "guidelines": {
        "typescript-conventions": "v1.0.0"
      }
    }
  }
}
```

### Loading Order
1. **Core Guidelines** (always first)
2. **Language Guidelines** (based on primary language)
3. **Framework Guidelines** (based on detected stack)
4. **Common Solutions** (filtered by relevance)

## 🎯 Detection Examples

### SvelteKit Project
```bash
# Files found:
✅ svelte.config.js
✅ package.json → "@sveltejs/kit": "^2.0.0"
✅ src/routes/+page.svelte
✅ src/app.html

# Result:
Detected: SvelteKit v2.x
Primary Language: TypeScript
Additional: Node.js backend patterns
```

### C# Web API
```bash
# Files found:
✅ MyProject.csproj → <PackageReference Include="Microsoft.AspNetCore.OpenApi"
✅ Program.cs
✅ Controllers/WeatherForecastController.cs
✅ appsettings.json

# Result:
Detected: ASP.NET Core Web API
Primary Language: C#
Additional: Entity Framework patterns
```

### Node.js Express API
```bash
# Files found:
✅ package.json → "express": "^4.18.0"
✅ server.js or app.js
✅ routes/ folder
✅ controllers/ folder

# Result:
Detected: Node.js + Express
Primary Language: TypeScript/JavaScript
Additional: REST API patterns
```

## 🤖 Claude Behavior

### Initial Project Setup
```
User: "Initialize Claude for this project"

Claude Actions:
1. Scan current directory for detection patterns
2. Load tech-stacks.json registry
3. Apply detection logic
4. If confident → Load appropriate guidelines
5. If uncertain → Ask user for clarification
6. Store tech stack info in context
7. Report what was loaded
```

### Example Interaction
```
🔍 Analyzing project structure...

Found: svelte.config.js, package.json with @sveltejs/kit
✅ Detected: SvelteKit project

📚 Loading guidelines:
✅ Core: General Principles, Naming, Architecture
✅ Language: TypeScript conventions
✅ Framework: Svelte/SvelteKit patterns
✅ Solutions: Component patterns, API routes

🎯 Ready! I'm now configured for SvelteKit development with Bliss Framework patterns.

Type of assistance: UI components, API routes, database integration, testing
```

### Uncertain Detection
```
🔍 Analyzing project structure...

Found multiple potential stacks:
- package.json with React and Express
- Could be: Full-stack React app OR separate frontend/backend

❓ Which describes your project better?
1. Single full-stack React app (Next.js style)
2. Separate React frontend + Express backend
3. Something else

Please select (1-3):
```

## 📊 Detection Confidence Levels

### High Confidence (95%+)
- Unique framework files found (svelte.config.js, mix.exs)
- Characteristic folder structure present
- Package dependencies align clearly

**Action**: Auto-load appropriate guidelines

### Medium Confidence (70-94%)
- Some indicators present but ambiguous
- Multiple possible interpretations
- Missing key confirmation files

**Action**: Show detected stack, ask for confirmation

### Low Confidence (<70%)
- Minimal or conflicting indicators
- Generic project structure
- Unusual or unknown patterns

**Action**: Present selection menu to user

## 🔧 Implementation Instructions

### For Claude Code Context
```json
{
  "projectDetection": {
    "enabled": true,
    "autoDetect": true,
    "confidenceThreshold": 70,
    "fallbackToManual": true,
    "cacheDetection": true,
    "registryUrl": "https://bliss-framework.org/claude-guidelines/tech-stacks.json"
  }
}
```

### Detection Algorithm
1. **File Scanning**: Check for framework-specific files
2. **Content Analysis**: Parse package.json, requirements.txt, etc.
3. **Structure Matching**: Compare folder patterns
4. **Confidence Scoring**: Weight matches by uniqueness
5. **Disambiguation**: Handle conflicts and ambiguity
6. **User Confirmation**: Verify uncertain detections

### Caching Strategy
- Store detection results in project-local context
- Cache for session duration
- Re-detect if major files change
- Allow manual override

---

**Next**: This detection system integrates with the initialization process to automatically load relevant tech-specific guidelines based on the project being worked on.