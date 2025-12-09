# Documentation Generation: [Feature Name]

## Prerequisites

This workflow assumes:
- ✅ The feature has been fully implemented in AL code
- ✅ The Business Central app has been compiled and published successfully
- ✅ All unit tests have passed
- ✅ The feature is functional and ready for end-users

If your feature isn't complete yet, use one of the other workflows to complete development and testing first.

---

## Workflow Scope

This workflow focuses exclusively on creating comprehensive end-user documentation.

**Workflow**: Existing Feature (implemented & tested) → Documentation

---

## Feature to Document

**Feature Name**: [Replace with your feature name]

**Feature Description**:
[Replace with a brief description of what the feature does and what modules/functionality it includes]

Example:
- Feature: Document Allocation Cancellation
- Description: Enables users to cancel allocations in sales orders, purchase orders, and related document types. Includes cancellation actions on order lines, validation of cancellation eligibility, and automatic release of reserved inventory.

**Modules/Areas Involved**:
[List the main areas of Business Central where this feature appears]

Example:
- Sales Order Processing
- Purchase Order Processing
- Inventory Allocation Management

---

## Phase 1: Documentation Generation

**Agent**: `gitbook-documentation-builder`

**Responsibilities**:

### 1. Analyze the Implemented Feature
- Review the AL code in the `BC` folder to understand what was implemented
- Identify all pages where the feature appears
- Understand the user workflows and interactions
- Review Azure DevOps work items for functional requirements (if available)
- Understand business rules and validation logic

### 2. Plan Documentation Structure
Organize documentation based on:
- Module structure (which BC modules does the feature affect?)
- User workflows (what tasks can users accomplish?)
- Feature components (pages, actions, fields)

Create a logical structure such as:
```
docs/Documentation/
  └── [Module Name]/
      └── [Feature Name]/
          ├── overview.md
          ├── getting-started.md
          ├── [workflow-1].md
          ├── [workflow-2].md
          ├── field-reference.md
          └── troubleshooting.md
```

### 3. Generate Documentation Content

For each documentation page, create:

#### **Overview Page**
- Feature introduction and purpose
- Business value and use cases
- High-level capabilities
- Who should use this feature

#### **Getting Started**
- How to access the feature in Business Central
- Prerequisites and permissions required
- Initial setup (if applicable)
- Navigation instructions

#### **Workflow Guides**
For each user workflow/use case:
- Step-by-step instructions
- Screenshots of each step (captured via Chrome DevTools MCP)
- Field descriptions relevant to the workflow
- Validation rules and requirements
- Business rules that apply
- Expected outcomes
- Tips and best practices

#### **Field Reference**
- Complete list of all new/modified fields
- Field name and location
- Data type and format
- Purpose and description
- Validation rules
- When the field is used
- Relationship to other fields

#### **Troubleshooting**
- Common issues users might encounter
- Error messages and their meanings
- How to resolve common problems
- When to contact support
- FAQs

### 4. Capture Screenshots
Using Chrome DevTools MCP automation:
- Navigate to the Business Central web interface
- Navigate to each page where the feature appears
- Capture high-quality screenshots of:
  - Overview pages showing the feature location
  - Each step in the user workflows
  - Field layouts and UI elements
  - Action buttons and menus
  - Validation messages and dialogs
  - Completed workflows showing results

### 5. Organize and Integrate Documentation
- Save all markdown files in the appropriate module folder within `docs/Documentation`
- Name files descriptively (use lowercase with hyphens: `cancel-allocation-workflow.md`)
- Update `docs/Documentation/SUMMARY.md` to include links to new pages
- Ensure proper hierarchy and indentation in SUMMARY.md
- Verify all internal links work correctly

### 6. Quality Review
- Ensure documentation is clear and concise
- Verify all screenshots are readable and relevant
- Check that workflows are complete and accurate
- Confirm field descriptions match the implementation
- Test that all links work
- Ensure consistent formatting and style

**Output**: Complete user-facing documentation in GitBook format with screenshots, properly organized in `docs/Documentation` folder.

---

## Documentation Quality Standards

Good documentation should:
- ✅ **Be User-Focused**: Written from the user's perspective, not the developer's
- ✅ **Be Clear and Concise**: Use simple language, short sentences, avoid jargon
- ✅ **Be Complete**: Cover all features, workflows, and use cases
- ✅ **Be Visual**: Include screenshots for every significant step
- ✅ **Be Organized**: Logical structure that's easy to navigate
- ✅ **Be Accurate**: Match the actual implementation exactly
- ✅ **Be Actionable**: Provide clear steps users can follow
- ✅ **Be Helpful**: Include troubleshooting and common issues

---

## Success Criteria

The documentation workflow is successful when:
1. ✅ All feature functionality is documented comprehensively
2. ✅ Step-by-step guides are created for each user workflow
3. ✅ Screenshots are captured for all significant UI interactions
4. ✅ Field reference documentation is complete
5. ✅ Troubleshooting section addresses common issues
6. ✅ Documentation is organized in the appropriate module structure
7. ✅ SUMMARY.md is updated with links to all new pages
8. ✅ All internal links work correctly
9. ✅ Documentation follows GitBook markdown format
10. ✅ Content is clear, accurate, and user-friendly

---

## Documentation Structure Example

For a feature called "Cancel Document Allocation":

```
docs/Documentation/
  └── Sales-Processing/
      └── Cancel-Allocation/
          ├── overview.md
          ├── cancel-sales-order-allocation.md
          ├── cancel-purchase-order-allocation.md
          ├── allocation-field-reference.md
          └── troubleshooting.md
```

And in `SUMMARY.md`:
```markdown
* [Sales Processing](Sales-Processing/README.md)
  * [Cancel Allocation](Sales-Processing/Cancel-Allocation/overview.md)
    * [Cancel Sales Order Allocation](Sales-Processing/Cancel-Allocation/cancel-sales-order-allocation.md)
    * [Cancel Purchase Order Allocation](Sales-Processing/Cancel-Allocation/cancel-purchase-order-allocation.md)
    * [Field Reference](Sales-Processing/Cancel-Allocation/allocation-field-reference.md)
    * [Troubleshooting](Sales-Processing/Cancel-Allocation/troubleshooting.md)
```

---

## Notes

- **Chrome DevTools MCP Integration**: The `gitbook-documentation-builder` agent uses Chrome DevTools MCP to automatically capture screenshots from the Business Central web interface
- **GitBook Format**: All documentation uses GitBook-flavored markdown with proper formatting
- **Module Organization**: Documentation should be organized by Business Central module (Sales, Purchase, Inventory, etc.)
- **User Perspective**: Write from the end-user's perspective, not the developer's - assume no technical knowledge
- **Visual Clarity**: Every significant user action should have a corresponding screenshot
- **Maintenance**: Documentation should be updated whenever the feature changes
- **Accessibility**: Use clear heading hierarchy and descriptive alt text for images
- **Consistency**: Follow existing documentation style and formatting conventions
