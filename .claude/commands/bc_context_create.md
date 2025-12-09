# Generate Project Context Documentation

Generate comprehensive project context documentation for AI assistant onboarding to the Volt Apparel Business Central solution.

## When to Use This Command

- Onboarding new AI assistants or agents
- Creating project overview documentation
- Sharing project structure with team
- Documenting architecture decisions
- New developer orientation

## Context Generation Workflow

### Step 1: Analyze Project Structure

Gather information about:
1. **Project Overview**: Volt Apparel BC solution
2. **Folder Structure**: factory/ workflow, BC/ source code
3. **Agent Architecture**: All agents and sub-agents
4. **AL Guidelines**: Coding standards and conventions
5. **Azure DevOps**: Work item structure
6. **Dependencies**: BC version, extensions, packages

### Step 2: Generate Context Document

Create `PROJECT_CONTEXT.md` with 16 sections:

#### 1. Project Overview
- **Name**: Volt Apparel Business Central Solution
- **Purpose**: Apparel industry ERP solution for Microsoft Dynamics 365 BC
- **Domain**: Style management, cut tickets, production, seasons, allocation
- **Technology**: AL language, Business Central SaaS

#### 2. Business Domain
- Apparel vertical focus
- Key workflows: style creation, cut tickets, production tracking
- Master data: styles, colors, sizes, fabrics, seasons
- Transactional data: cut tickets, production orders, allocations

#### 3. Solution Architecture
- **VT prefix** for all custom objects
- **Extension pattern**: Extend BC standard objects
- **Event-driven**: Publisher/subscriber patterns
- **API integration**: RESTful APIs for mobile/PLM

#### 4. Folder Structure
```
Volt-Apparel/
├── factory/                    # Volt Factory workflow
│   ├── 1research/             # Business research phase
│   ├── 2functional_design/    # Functional specifications
│   ├── 3technical_design/     # Technical specifications
│   ├── 4development/          # Implementation docs
│   └── 5unit_test/            # Test results
├── BC/                        # Business Central source
│   ├── src/                   # AL code (feature-based)
│   │   ├── Styles/           # VT Style objects
│   │   ├── CutTickets/       # VT Cut Ticket objects
│   │   ├── Seasons/          # VT Season objects
│   │   └── Common/           # Shared utilities
│   └── app.json              # App manifest
├── BC_Test/                   # Test codeunits
│   ├── Features/             # Feature tests
│   └── Libraries/            # Test helpers
└── .claude/                   # AI configuration
    ├── agents/               # Agent definitions
    ├── commands/             # Slash commands
    └── al_guidelines/        # AL coding standards
```

#### 5. Agent Architecture
- **Layer 1**: Business context (bc-business-research, bc-functional-designer)
- **Layer 2**: Technical implementation (bc-technical-designer, bc-al-developer, bc-test-runner, bc-debugger)
- **Layer 3**: Support (azure-devops-manager, gitbook-documentation-builder)
- **Sub-agents**: Specialized for architecture, API, testing

#### 6. AL Coding Standards
- VT prefix mandatory
- 2-space indentation
- PascalCase naming
- Event-driven patterns
- Performance-first (SetLoadFields, early filtering)
- Feature-based organization

#### 7. Development Workflow
1. Business Research → bc-business-research
2. Functional Design → bc-functional-designer
3. Technical Design → bc-technical-designer
4. Implementation → bc-al-developer
5. Compilation → bc-app-compiler
6. Testing → bc-test-runner
7. Documentation → gitbook-documentation-builder

#### 8. Object ID Management
- Managed via mcp__objid tools
- MANDATORY allocation before object creation
- Tracked in .objidconfig
- Never hardcode IDs

#### 9. Testing Strategy
- Unit tests for all codeunits
- Integration tests for workflows
- UI tests for pages
- Given/When/Then pattern

#### 10. Azure DevOps Integration
- Epic → Feature → User Story → Tasks hierarchy
- Work item traceability
- Automated status updates
- Links to factory/ documentation

#### 11. Key Technologies
- AL Language (Business Central)
- Azure DevOps (project management)
- Chrome DevTools MCP (test automation and browser automation)
- GitBook (documentation)

#### 12. Apparel Domain Concepts
- **Style**: Master design (STYLE001)
- **Color**: Color variants per style
- **Size**: Size range (XS-XXL)
- **Season**: Seasonal collections (SS2024, AW2024)
- **Cut Ticket**: Production order for quantity/color/size
- **Fabric BOM**: Materials required per style

#### 13. Environment Setup
- Sandbox: Development and testing
- Production: Live apparel operations
- Launch.json: BC connection config
- .objidconfig: Object ID management

#### 14. Common Commands
- `/bc_compile`: Compile AL apps
- `/bc_publish_sandbox`: Publish to sandbox
- `/bc_diagnose`: Debug issues
- `/bc_spec_create`: Create specifications
- `/bc_performance_triage`: Quick performance check

#### 15. Extension Points
- Extend BC standard objects (Item, Sales Line, etc.)
- Event subscribers for BC standard events
- Custom VT events for extensibility

#### 16. Project Goals
- Comprehensive apparel ERP solution
- Industry-specific workflows
- AI-powered features
- Mobile integration
- Scalable architecture

### Step 3: Save Context Document

Write to: `PROJECT_CONTEXT.md` in root directory

### Step 4: Update for Major Changes

Regenerate context when:
- New major features added
- Architecture changes
- New agents created
- Technology changes

## Usage Example

User: "Generate project context documentation"