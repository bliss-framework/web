# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Bliss Framework documentation website - a programming methodology and framework created by Ondrej Valenta. The repository contains markdown documentation files that are built into a static website using MkDocs Material.

The Bliss Framework provides:
- Programming guidelines and best practices
- Coding conventions for multiple languages (C#, Elixir, PostgreSQL, Svelte)
- Architecture patterns based on three-layer application design
- Learning guidelines for developers

## Commands

### Setup
```bash
# Install MkDocs and required plugins
pip install mkdocs && pip install mkdocs-material && pip install mkdocs-glightbox mkdocs-git-revision-date-localized-plugin mkdocs-git-authors-plugin
```
Or run: `setup.bat`

### Development
```bash
# Start development server
mkdocs serve
```
Or run: `run.bat`

### Build
```bash
# Build static site
mkdocs build
```

### Docker
```bash
# Build Docker image
docker build --progress plain -f Dockerfile -t bliss-framework:web .
```
Or run: `build-docker.bat`

## Architecture

### Documentation Structure
The documentation follows a hierarchical structure defined in `mkdocs.yml`:

1. **Framework Introduction** (`docs/index.md`, `docs/consistency-is-bliss.md`)
2. **Learning Guidelines** (`docs/learning-guidelines/`) - Basic programming principles and vocabulary
3. **Analysis Guidelines** (`docs/analysis-guidelines/`) - How to analyze problems and solutions
4. **Coding Guidelines** (`docs/coding-guidelines/`) - General coding practices and application architecture
5. **Language-Specific Guidelines** - Separate folders for C#, Elixir, PostgreSQL, and Svelte

### Three-Layer Application Architecture
The framework promotes a three-layer architecture pattern:

- **Input/Output Layer**: Handles external communication, validation, and data formatting
- **Management Layer**: Orchestrates business logic and coordinates between providers
- **Providers Layer**: Performs specific tasks (database, file operations, external APIs)
- **Side Layer**: Contains reusable components (Models, Mappers, Helpers, Constants/Enums)

Key principle: Providers must never communicate directly with each other - all coordination happens through the Management layer.

## File Organization

- `/docs/` - All markdown documentation files
- `/overrides/` - MkDocs Material theme customizations
- `mkdocs.yml` - MkDocs configuration with navigation structure
- `Caddyfile` - Web server configuration for Docker deployment
- `Dockerfile` - Multi-stage build (MkDocs + Caddy)

## Deployment

The site is automatically deployed via GitHub Actions (`.github/workflows/prod.yml`) when changes are pushed to the `prod` branch. The deployment:

1. Builds Docker image using MkDocs Material
2. Pushes to private registry
3. Deploys to production server using docker-compose

## Content Guidelines

When editing documentation:

- Follow the established tone and style from existing content
- Use Mermaid diagrams for sequence diagrams and flowcharts
- Include real-world analogies (like the McDonald's restaurant example)
- Maintain consistency with the framework's core principles
- Use the established folder structure for new language-specific guidelines

## Claude Guidelines Format Rules

The Claude-specific guidelines (`/docs/claude/`) use a dual-format system:

### Text Files (.txt) - For Claude Code
- **Purpose**: Optimized for Claude Code to read and parse efficiently
- **Format**: Bullet points, minimal prose, maximum information density
- **Structure**:
  ```
  SECTION_NAME:
  - key point 1
  - key point 2
  - NO: antipattern

  GOOD: example1, example2
  BAD: badexample1, badexample2
  ```
- **Location**: `/docs/claude/*.txt`

### Markdown Files (.md) - For Human Reading
- **Purpose**: Web visualization, human-friendly browsing
- **Format**: Full markdown with formatting, sections, code blocks
- **Features**: Syntax highlighting, tables, diagrams
- **Location**: `/docs/claude/*.md`

### Key Principles for Claude Guidelines
1. **Bullet points over sentences** - Lists are more token-efficient
2. **Examples over explanations** - Show don't tell
3. **Patterns over theory** - Practical templates
4. **Good/Bad comparisons** - Clear do's and don'ts
5. **Minimal code snippets** - Only when essential

### Example of Dual Format:
```
# Text file (general-principles.txt):
COMMUNICATION:
- user: Czech
- code/docs: English
- NO: mixing languages

# Markdown file (general-principles.md):
## Communication
### Language Convention
- **User communication**: Czech (čeština)
- **Code and documentation**: English
```