# Create Business Central Feature Specification

Create comprehensive functional and technical specifications for a new Volt Apparel Business Central feature.

## When to Use This Command

- Starting new feature development
- Need structured requirements before coding
- Translating business needs into technical design
- Planning major enhancements to VT objects

## Specification Creation Workflow

### Step 1: Gather Business Requirements

Ask the user:
1. **Feature name**: What is being built?
2. **Business objective**: Why is this needed?
3. **User stories**: Who needs this and what do they need to do?
4. **Apparel context**: How does this relate to styles, cut tickets, seasons, production?
5. **Acceptance criteria**: What defines success?

### Step 2: Create Functional Design

Invoke bc-functional-designer agent:

```
Task(
  subagent_type: "bc-functional-designer",
  description: "Create functional design",
  prompt: "Create comprehensive functional design for: [feature name]

  Business Objective: [description]
  User Stories: [list]
  Apparel Context: [VT objects involved]

  Create functional design documents in:
  factory/2functional_design/[Feature]/[UserStory]/

  Include:
  - Business requirements
  - User workflows
  - UI mockups (text-based)
  - Business rules
  - Validation requirements
  - Integration points
  - Acceptance criteria"
)
```

### Step 3: Create Technical Design

Invoke bc-technical-designer agent:

```
Task(
  subagent_type: "bc-technical-designer",
  description: "Create technical design",
  prompt: "Create technical design for: [feature name]

  Read functional design from:
  factory/2functional_design/[Feature]/[UserStory]/

  Create technical specifications in:
  factory/3technical_design/[Feature]/[UserStory]/

  Include:
  - AL object specifications (tables, pages, codeunits)
  - Object IDs and naming (VT prefix)
  - Field definitions with data types
  - Procedure signatures
  - Event subscriptions
  - Algorithm designs
  - Implementation order
  - Testing strategy"
)
```

### Step 4: Create Azure DevOps Work Items

The agents will automatically create:
- Epic for feature
- Features for major components
- User Stories for functionality
- Technical Tasks for AL objects
- Test Tasks for validation

### Step 5: Review Specifications

Review outputs in:
- `factory/2functional_design/[Feature]/[UserStory]/` - Functional specs
- `factory/3technical_design/[Feature]/[UserStory]/` - Technical specs
- Azure DevOps - Work item hierarchy

## Example: Create Style Color Management Feature

```
User: "I need a feature to manage style color variants with images and availability"

Step 1: Functional Design
→ bc-functional-designer creates:
  - User workflows for color management
  - UI designs for color matrix
  - Business rules for color validation
  - Integration with VT Style table

Step 2: Technical Design
→ bc-technical-designer creates:
  - VT Style Color table specification
  - VT Style Color Card page specification
  - Color validation codeunit specification
  - Image storage integration design

Step 3: Azure DevOps
→ Epic: Style Color Management
→ Feature: Color Variant Tracking
→ User Story: Add Colors to Style
→ Tasks: Create table, page, validation logic
```

## Specification Templates

### Functional Design Checklist
- ✅ Business requirements documented
- ✅ User personas identified
- ✅ Workflows described step-by-step
- ✅ UI mockups created
- ✅ Business rules specified
- ✅ Validation requirements listed
- ✅ Integration points identified
- ✅ Acceptance criteria defined

### Technical Design Checklist
- ✅ AL objects specified (with VT prefix)
- ✅ Object IDs allocated
- ✅ Fields defined (type, length, properties)
- ✅ Procedures documented (parameters, logic)
- ✅ Events identified (publishers, subscribers)
- ✅ Algorithms designed
- ✅ Testing strategy outlined
- ✅ Implementation order recommended

## Key Reminders

- **VT prefix required** for all custom objects
- **AL guidelines** from `.claude/al_guidelines/` apply
- **Apparel domain** - consider style/color/size matrices
- **Factory workflow** - functional → technical → development
- **Azure DevOps** - maintain work item traceability

## Output

Provides:
1. Functional design documents in factory/2functional_design/
2. Technical design documents in factory/3technical_design/
3. Azure DevOps work item hierarchy
4. Ready for bc-al-developer to implement
