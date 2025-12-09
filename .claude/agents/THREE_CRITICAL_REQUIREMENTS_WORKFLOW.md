# Three Critical Requirements - Workflow Integration

**Date**: 2025-11-06
**Purpose**: Document how the three mandatory requirements flow through the Volt Factory workflow

---

## The Three Critical Requirements

Every feature developed in the Volt Factory workflow MUST include:

1. **Business Rules for Error Conditions**: What is NOT allowed - operations that should be prevented or cause validation errors
2. **Assisted Setup for Consultants**: One-click implementation support for rapid deployment
3. **Demo Data Functionality**: Sample data to showcase features and support training

---

## Workflow Integration Map

### Phase 1: BC Functional Designer (Orchestrator + Sub-Agents)

**Location**: `.claude/agents/bc-functional-designer.md`

**Changes Made**:
- Updated orchestrator to mandate these three areas in handoff document
- Modified handoff template to include specific sections for:
  - Error Conditions (Section 7)
  - Assisted Setup Requirements (Section 8)
  - Demo Data Requirements (Section 9)

**Sub-Agent: 04 Initial Solution Designer**

**Location**: `.claude/agents/bc-functional-designer-subagents/04_initial_solution_designer.md`

**New Sections Added**:

1. **Error Conditions and Prevention Rules**
   - Template for documenting what is NOT allowed
   - Business reasoning for each prohibition
   - User-facing error messages
   - Recovery guidance
   - Example: "Cannot delete attribute in use" with complete specification

2. **Assisted Setup Requirements**
   - Template for one-click setup components
   - Configuration options for consultants
   - Sample data included in setup
   - Validation of successful setup
   - Time-to-complete estimates
   - Example: "Initial Attribute Library Setup" with wizard flow

3. **Demo Data Requirements**
   - Template for demo data sets
   - Purpose and demonstration scenarios
   - Data components with realistic samples
   - User scenarios showing demo data in action
   - Access points and reset capabilities
   - Example: "Sample Product Attributes" with 12 demo attributes

**Sub-Agent: 06 UI/UX Designer**

**Location**: `.claude/agents/bc-functional-designer-subagents/06_ui_ux_designer.md`

**New Section Added**:

1. **Demo Data UI Requirements**
   - How users access demo data (Setup menu, management screens, wizards)
   - Visual indicators for demo records (badges, colors, filters)
   - Demo Data Manager screen design
   - Integration with Assisted Setup wizard
   - Example: Complete demo data manager UI with split-view layout

**Output Path**: `factory/2functional_design/[Feature]/`

**Documents Updated**:
- `04_initial_solution_design.md` - Now includes error conditions, setup requirements, demo data
- `06_ui_ux_design.md` - Now includes demo data UI elements
- `HANDOFF_TO_TECHNICAL_DESIGN.md` - Now includes three requirement sections

---

### Phase 2: BC Technical Designer

**Location**: `.claude/agents/bc-technical-designer.md`

**Changes Made**:

1. **Core Responsibilities Updated**:
   - Added "CRITICAL - Three Mandatory Design Areas" section
   - Error Conditions: Design validation triggers, error messages, OnValidate logic
   - Assisted Setup: Design wizard pages, integration with BC framework, validation
   - Demo Data: Design codeunits, data structures, UI integration

2. **Output Requirements Expanded**:
   - New document: `assisted_setup_design.md`
     * Wizard page structure and navigation
     * Configuration data creation logic
     * Sample data generation specifications
     * BC Assisted Setup framework integration

   - New document: `demo_data_design.md`
     * Demo data codeunit specifications
     * Data structures with sample values
     * Creation/reset procedure designs
     * Demo data identification flags
     * UI integration points

   - Updated: `technical_specifications.md`
     * Now includes error handling implementations section

   - Updated: `HANDOFF_TO_DEVELOPMENT.md`
     * Error condition test cases
     * Assisted setup validation checklist
     * Demo data verification steps

**Output Path**: `factory/3technical_design/[Feature]/[UserStory]/`

**Documents Created**:
1. `technical_specifications.md` (includes error handling)
2. `al_object_designs.md`
3. `algorithm_designs.md`
4. **`assisted_setup_design.md`** (NEW)
5. **`demo_data_design.md`** (NEW)
6. `HANDOFF_TO_DEVELOPMENT.md` (updated with three requirement checklists)

---

### Phase 3: BC AL Developer

**Location**: `.claude/agents/bc-al-developer.md`

**Changes Made**:

1. **Core Responsibilities Updated**:
   - Added "CRITICAL - Three Mandatory Implementation Areas" section

   a. **Error Conditions & Validation Logic**:
      - Implement all validation rules from technical design
      - OnValidate triggers for field-level validation
      - Validation codeunits for complex rules
      - Clear, user-friendly Error() messages
      - Test all error conditions
      - Document error codes and messages

   b. **Assisted Setup Wizard**:
      - Implement wizard pages using BC framework
      - Setup codeunits for logic and data creation
      - Include demo data in setup process
      - Validation for successful setup
      - Register wizard in Assisted Setup table
      - Test complete flow
      - One-click consultant experience

   c. **Demo Data Functionality**:
      - Demo data codeunits with Create/Reset procedures
      - IsDemo fields in tables
      - Realistic sample data
      - UI actions for load/reset
      - Visual indicators (styling, filters)
      - Safe removal/reset capability
      - Test creation and cleanup

2. **Output Requirements Expanded**:
   - Updated: `implementation_summary.md`
     * Error conditions implemented (list with messages)
     * Assisted setup status (created, tested, registered)
     * Demo data status (verified)

   - New document: `validation_reference.md`
     * Complete list of error conditions implemented
     * Validation rules with trigger points
     * Error messages catalog

   - New document: `setup_guide.md`
     * Quick guide for consultants
     * How to use the assisted setup wizard
     * Configuration options explained

   - New document: `demo_data_reference.md`
     * What demo data is available
     * How to load/reset demo data
     * Demo data scenarios and use cases

**Output Path**: `factory/4development/[Feature]/[UserStory]/`

**Documents Created**:
1. `implementation_summary.md` (updated with three requirement statuses)
2. `code_references.md`
3. `object_ids_allocated.md`
4. **`validation_reference.md`** (NEW)
5. **`setup_guide.md`** (NEW)
6. **`demo_data_reference.md`** (NEW)

---

## Verification Checklist

Use this checklist to verify all three requirements are captured and implemented:

### ✅ Functional Design Phase

- [ ] Error conditions documented in `04_initial_solution_design.md`
  - [ ] What is NOT allowed is clearly specified
  - [ ] Business reasons provided for each restriction
  - [ ] Error messages drafted (user-friendly language)
  - [ ] User recovery paths identified

- [ ] Assisted setup requirements documented in `04_initial_solution_design.md`
  - [ ] Setup wizard flow described
  - [ ] Configuration options specified
  - [ ] Sample data to be created listed
  - [ ] One-click experience designed
  - [ ] Time estimate provided

- [ ] Demo data requirements documented in `04_initial_solution_design.md`
  - [ ] Demo data sets defined with purpose
  - [ ] Sample data components listed
  - [ ] User scenarios described
  - [ ] Access points identified

- [ ] Demo data UI documented in `06_ui_ux_design.md`
  - [ ] Access points designed (menus, buttons)
  - [ ] Visual indicators specified
  - [ ] Demo data manager screen (if applicable)
  - [ ] Assisted setup integration shown

- [ ] Handoff document includes all three requirement sections
  - [ ] Error Conditions section complete
  - [ ] Assisted Setup Requirements section complete
  - [ ] Demo Data Requirements section complete

### ✅ Technical Design Phase

- [ ] Error handling designed in `technical_specifications.md`
  - [ ] Validation triggers identified (OnValidate, procedures)
  - [ ] Error message constants defined
  - [ ] Validation logic algorithms provided

- [ ] Assisted setup designed in `assisted_setup_design.md`
  - [ ] Wizard page AL specifications
  - [ ] Setup codeunit procedures defined
  - [ ] Sample data creation logic specified
  - [ ] BC Assisted Setup integration detailed

- [ ] Demo data designed in `demo_data_design.md`
  - [ ] Demo data codeunit specifications
  - [ ] IsDemo field added to table designs
  - [ ] Sample data values and structures
  - [ ] UI action specifications (Load/Reset)

- [ ] Handoff includes three requirement checklists
  - [ ] Error condition test cases listed
  - [ ] Assisted setup validation steps
  - [ ] Demo data verification procedure

### ✅ Development Phase

- [ ] Error validation implemented
  - [ ] OnValidate triggers implemented
  - [ ] Validation codeunits created
  - [ ] Error messages match specifications
  - [ ] All error conditions tested

- [ ] Assisted setup implemented
  - [ ] Wizard pages created
  - [ ] Setup codeunits implemented
  - [ ] Registered in Assisted Setup table
  - [ ] Tested end-to-end
  - [ ] Consultant guide created

- [ ] Demo data implemented
  - [ ] Demo data codeunits created
  - [ ] IsDemo fields added to tables
  - [ ] Sample data matches specifications
  - [ ] UI actions implemented (Load/Reset)
  - [ ] Visual indicators working
  - [ ] Reset functionality tested

- [ ] Documentation complete
  - [ ] `validation_reference.md` created
  - [ ] `setup_guide.md` created
  - [ ] `demo_data_reference.md` created
  - [ ] Implementation summary includes all three areas

### ✅ Testing Phase

- [ ] Error condition tests
  - [ ] All validation rules tested
  - [ ] Error messages verified
  - [ ] Boundary conditions tested
  - [ ] Recovery paths validated

- [ ] Assisted setup tests
  - [ ] Wizard completes successfully
  - [ ] Configuration data created correctly
  - [ ] Sample data populated
  - [ ] Validation checks working
  - [ ] One-click experience smooth

- [ ] Demo data tests
  - [ ] Demo data loads successfully
  - [ ] Sample data is realistic and complete
  - [ ] Visual indicators working
  - [ ] Reset functionality working
  - [ ] Demo data can be safely removed

---

## Example: Product Attribute Feature

### Functional Design Output

**Error Conditions** (from `04_initial_solution_design.md`):
1. Cannot delete attribute in use by products
2. Cannot change attribute type if values exist
3. Attribute code must be unique
4. Required attributes must have values before sales posting

**Assisted Setup** (from `04_initial_solution_design.md`):
- Wizard: "Product Attribute Setup Wizard"
- Creates: 12 sample attributes, 3 categories, 5 demo products
- Time: 2-3 minutes
- Options: Industry template, include demo data, naming convention

**Demo Data** (from `04_initial_solution_design.md`):
- 12 attributes: COLOR, SIZE, FABRIC, WEIGHT, etc.
- 3 categories: Physical, Specifications, Compliance
- 5 demo products: T-Shirt, Jeans, Jacket, Shoes, Accessories

### Technical Design Output

**Error Handling** (from `technical_specifications.md`):
```al
// Table Extension: VT Attribute
field(50100; Code; Code[20])
{
    trigger OnValidate()
    begin
        if Code <> xRec.Code then
            CheckCodeUnique(Code);
    end;
}

procedure CheckCodeUnique(AttributeCode: Code[20])
var
    Attribute: Record "VT Attribute";
begin
    Attribute.SetRange(Code, AttributeCode);
    if Attribute.FindFirst() then
        Error('Attribute code %1 already exists. Please choose a different code.', AttributeCode);
end;
```

**Assisted Setup** (from `assisted_setup_design.md`):
```al
// Wizard Page 50101: VT Attribute Setup Wizard
page 50101 "VT Attribute Setup Wizard"
{
    PageType = NavigatePage;
    // ... wizard implementation
}

// Codeunit 50102: VT Attribute Setup
codeunit 50102 "VT Attribute Setup"
{
    procedure CreateInitialData()
    // ... setup implementation
}
```

**Demo Data** (from `demo_data_design.md`):
```al
// Codeunit 50103: VT Demo Data
codeunit 50103 "VT Demo Data"
{
    procedure CreateDemoAttributes()
    procedure CreateDemoProducts()
    procedure ResetDemoData()
}

// Table Extension: VT Attribute with IsDemo field
field(50110; IsDemo; Boolean)
```

### Development Output

**Validation Reference** (from `validation_reference.md`):
| Validation Rule | Trigger Point | Error Message | Test Case |
|----------------|---------------|---------------|-----------|
| Unique Code | OnValidate: Code | "Attribute code 'X' already exists" | Create duplicate |
| Cannot Delete In Use | OnDelete | "Cannot delete. Used by N products" | Delete used attribute |

**Setup Guide** (from `setup_guide.md`):
```
Assisted Setup: Product Attributes
1. Open Assisted Setup from Role Center
2. Select "Product Attribute Setup Wizard"
3. Choose industry template: Apparel
4. Check "Include demo data"
5. Click Finish
Result: 12 attributes, 3 categories, 5 demo products created
```

**Demo Data Reference** (from `demo_data_reference.md`):
```
Available Demo Data:
- 12 Sample Attributes (COLOR, SIZE, FABRIC, ...)
- 3 Attribute Categories
- 5 Demo Products

To Load: Product Attribute Setup → Actions → Load Demo Data
To Reset: Product Attribute Setup → Actions → Reset Demo Data
Visual Indicator: Demo records have blue background
```

---

## Benefits of This Integration

1. **Consistency**: Every feature includes error handling, setup, and demo data
2. **Quality**: Systematic capture prevents forgetting critical aspects
3. **Consultant Experience**: One-click setup accelerates implementations
4. **User Training**: Demo data enables self-service learning
5. **Traceability**: Requirements tracked from functional → technical → implementation
6. **Testing**: Clear validation criteria for error conditions
7. **Documentation**: Comprehensive guides for consultants and users

---

## Future Enhancements

Consider adding these related requirements in future iterations:

- **Upgrade Scripts**: How feature data migrates between versions
- **Performance Benchmarks**: Expected response times for key operations
- **Security Roles**: Permission set requirements for each feature
- **Translation Strings**: Multi-language support for errors and UI
- **Telemetry Events**: What events to log for diagnostics
- **API Endpoints**: REST API exposure for feature data

---

## Agent Maintenance

When updating these agents in the future:

1. **Always maintain** the three critical requirement sections
2. **Test the workflow** with a sample feature to verify propagation
3. **Update this document** if workflow structure changes
4. **Notify team members** of any changes to required outputs
5. **Review examples** to ensure they remain current and accurate

---

**Last Updated**: 2025-11-06
**Next Review**: When workflow structure changes
**Owner**: Volt Factory Development Team
