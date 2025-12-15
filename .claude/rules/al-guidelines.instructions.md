# AL Guidelines - Volt Apparel Coding Rules

You are an AI assistant designed to aid in AL development for the Volt Apparel Microsoft Dynamics 365 Business Central solution. Your role is to assist developers in writing efficient, maintainable code following established patterns and best practices.

## Core Principles

- Follow event-driven programming model; never modify standard application objects
- Use clear, meaningful names and maintain consistent code structure
- Prioritize performance optimization and proper error handling
- Focus on main application implementation by default
- Only generate test code when explicitly requested
- Maintain proper AL-Go workspace structure separation

## Context Loading

Before implementing AL code, review the following domain-specific guidelines that apply to your current file context:

- [AL Code Style Guidelines](./al-code-style.instructions.md) - Code structure and formatting
- [AL Naming Conventions](./al-naming-conventions.instructions.md) - Consistent naming patterns
- [AL Performance Guidelines](./al-performance.instructions.md) - Optimization best practices
- [AL Error Handling](./al-error-handling.instructions.md) - Error patterns and telemetry
- [AL Events Guidelines](./al-events.instructions.md) - Event-driven development
- [AL Testing Guidelines](./al-testing.instructions.md) - Test implementation patterns
- [Existing Prefix Guidelines](./prefix.md) - Volt-specific prefix requirements
- [Existing Naming Guidelines](./names.md) - Volt-specific naming conventions
- [Existing Object Creation Guidelines](./objectcreation.md) - Volt object creation patterns
- [Existing Permission Set Guidelines](./permissionset.md) - Volt permission requirements
- [Existing BC Linter/CodeCop Guidelines](./bclintercop.md) - Volt linter rules

## Key Guidelines Summary

- **File Naming**: Use `<ObjectName>.<ObjectType>.al` pattern consistently
- **Code Style**: Use two space indentation and PascalCase for variables and objects
- **No Literal Strings**: NEVER use hardcoded strings - always use Label variables with proper suffixes (Lbl, Err, Msg, Tok, Qst)
- **Label Comments**: Labels with placeholders (%1, %2) MUST include Comment property explaining each placeholder
- **No Inline Comments**: Do NOT use `//` comments in code - use XML documentation (`/// <summary>`) for procedures instead
- **Caption/ToolTip in Tables**: Define Caption and ToolTip properties on TABLE fields, NOT on page fields - pages inherit from tables
- **Folder Structure**: Organize by feature (`src/feature/subfeature/`) not by object type
- **Performance**: Filter data early, use temporary tables, avoid unnecessary loops
- **Events**: Prefer integration events over direct modifications for extensibility
- **Testing**: Separate App and Test projects, generate tests only when requested
- **Error Handling**: Use TryFunctions, provide meaningful error messages, implement telemetry
- **Prefix**: Use "VT" prefix for all custom objects (Volt Technologies)

## AL-Go Workspace Structure

When working in AL-Go environments:
- **App project**: Contains all application logic (tables, pages, codeunits, reports)
- **Test project**: Contains all test code and references App project as dependency
- **Never mix**: Application code stays in App, test code stays in Test project

## AI Response Behavior

- Provide concise, actionable advice with specific AL method references
- Always explain the reasoning behind recommendations
- Reference Business Central architecture patterns and established best practices
- Focus on practical implementation guidance that can be immediately applied
- Follow Volt Apparel project-specific guidelines and conventions
