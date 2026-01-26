---
name: bc-developer
description: Develop Business Central AL code including tables, pages, codeunits, reports, and extensions. Use when implementing BC features, modifications, or enhancements. Handles object ID allocation, AL guidelines compliance, unit test creation, and coordinates with compilation/testing skills for verification.
license: MIT
compatibility: Requires volt-technologies/volt-bc-tools package. Uses mcp__objid tools for object ID allocation.
metadata:
  author: volt-technologies
  version: "1.0.0"
allowed-tools: Bash(node:*) Bash(npx:*) Read Edit Write Glob Grep mcp__objid__allocate_id mcp__objid__config mcp__objid__analyze_workspace
---

# BC Developer Skill

Develop Business Central AL code using `volt-technologies/volt-bc-tools` and AL best practices.

## Prerequisites

1. **AL Guidelines**: Read `.claude/al-guidelines/` before coding
2. **Object ID Config**: `.objidconfig` in BC app folder
3. **Feature Ranges**: Check `BC/FeatureRanges.md` for ID ranges

## Development Workflow

### Step 1: Read AL Guidelines

**MANDATORY** - Read these files before writing any AL code:

```
.claude/al-guidelines/
├── prefix.md               # VOL prefix requirements
├── names.md                # Naming conventions
├── objectcreation.md       # Object creation patterns
├── permissionset.md        # Permission set requirements
└── lintercop/_index.md     # LinterCop rules
```

### Step 2: Allocate Object IDs

**CRITICAL**: Always allocate IDs before creating objects.

```
Use mcp__objid__allocate_id with:
- mode: "reserve"
- appPath: "C:\path\to\BC"
- object_type: "table" | "page" | "codeunit" | etc.
- preferred_range: {from: XXXXX, to: XXXXX}
- object_metadata: {name: "VOL Object Name", file: "src/Feature/File.al"}
```

### Step 3: Implement AL Code

Write code in `BC/src/[Feature]/[ObjectType]/`:
```
BC/src/
├── ProductVariants/
│   ├── table/
│   ├── page/
│   ├── codeunit/
│   └── enum/
└── Common/
    └── permissionset/
```

### Step 4: Create Unit Tests

Write tests in `BC Test/src/`:
```al
codeunit 70200 "VOL Feature Tests"
{
    Subtype = Test;

    [Test]
    procedure TestFeatureBehavior()
    begin
        // Arrange
        // Act
        // Assert
    end;
}
```

### Step 5: Compile & Publish

Use bc-compiler skill:
```bash
npx volt-bc dev compile --all
npx volt-bc dev publish "./output/App.app"
```

### Step 6: Run Tests

Use bc-test-runner skill:
```bash
npx volt-bc dev test --codeunit 70200
```

## AL Coding Standards

### Naming Conventions

| Object Type | Convention | Example |
|-------------|------------|---------|
| Table | Singular, VOL prefix | `VOL Product Variant` |
| List Page | Plural | `VOL Product Variants` |
| Card Page | Singular + Card | `VOL Product Variant Card` |
| Codeunit | Action-based | `VOL Product Variant Mgt.` |
| Enum | Singular | `VOL Variant Status` |

### Key LinterCop Rules

**Must Follow**:
- **LC0001**: FlowFields MUST have `Editable = false`
- **LC0003**: Use object names, NOT IDs in declarations
- **LC0040**: Always specify `RunTrigger` parameter
- **LC0081**: Use `IsEmpty()` not `Count() > 0`

**Code Style**:
- NO inline `//` comments - use XML documentation
- NO literal strings - use Label variables (Lbl, Err, Msg)
- Caption and ToolTip at table field level, not pages
- `ApplicationArea = All` at object level

### Object Creation Pattern

For every table, create:
1. Table with `LookupPageId`
2. List Page with `CardPageId`
3. Card Page
4. Add all objects to permissionset

```al
table 70100 "VOL Product Variant"
{
    Caption = 'Product Variant';
    DataClassification = CustomerContent;
    LookupPageId = "VOL Product Variants";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the variant code.';
        }
    }
}

page 70100 "VOL Product Variants"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "VOL Product Variant";
    CardPageId = "VOL Product Variant Card";
    Caption = 'Product Variants';
}

page 70101 "VOL Product Variant Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "VOL Product Variant";
    Caption = 'Product Variant Card';
}
```

## Implementation Checklist

### Error Conditions & Validation
- [ ] Implement all validation rules from technical design
- [ ] Use OnValidate triggers for field validation
- [ ] Create validation codeunits for complex rules
- [ ] Use clear Error() messages
- [ ] Document error codes in implementation summary

### Unit Tests
- [ ] Create test codeunit with `Subtype = Test`
- [ ] Implement happy path scenarios
- [ ] Test edge cases and boundaries
- [ ] Test error conditions
- [ ] Use descriptive test names

### Permission Set
- [ ] Add all new objects to VOL permission set
- [ ] Include TableData permissions
- [ ] Test with restricted user

## Object ID Ranges

Check `BC/FeatureRanges.md`:
```
#Common
70000 - 70099

#Product Variants
70100 - 70199

#Customer Portal
70200 - 70299
```

Use `preferred_range` parameter when allocating IDs.

## Error Handling Pattern

```al
procedure ValidateQuantity(Quantity: Decimal)
var
    QuantityMustBePositiveErr: Label 'Quantity must be positive. Current value: %1', Comment = '%1 = Quantity';
begin
    if Quantity <= 0 then
        Error(QuantityMustBePositiveErr, Quantity);
end;
```

## Test Pattern

```al
codeunit 70200 "VOL Product Variant Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";

    [Test]
    procedure TestCreateVariant_ValidData_Succeeds()
    var
        ProductVariant: Record "VOL Product Variant";
    begin
        // [GIVEN] Valid variant data
        // [WHEN] Creating variant
        ProductVariant.Init();
        ProductVariant.Code := 'TEST001';
        ProductVariant.Insert(true);

        // [THEN] Variant exists
        Assert.IsTrue(ProductVariant.Get('TEST001'), 'Variant should exist');
    end;

    [Test]
    procedure TestValidateQuantity_Negative_ThrowsError()
    var
        VariantMgt: Codeunit "VOL Product Variant Mgt.";
    begin
        // [GIVEN] Negative quantity
        // [WHEN] Validating
        // [THEN] Error is thrown
        asserterror VariantMgt.ValidateQuantity(-1);
        Assert.ExpectedError('Quantity must be positive');
    end;
}
```

## Integration with Other Skills

### Complete Development Cycle

1. **bc-developer** → Write AL code and tests
2. **bc-compiler** → Compile and publish apps
3. **bc-test-runner** → Execute and validate tests
4. Repeat if failures occur

### Coordination Pattern

```
Implement Feature
    ↓
Allocate Object IDs (mcp__objid__allocate_id)
    ↓
Write AL Code (tables, pages, codeunits)
    ↓
Update Permission Set
    ↓
Write Unit Tests
    ↓
Invoke bc-compiler skill → Compile & Publish
    ↓
Invoke bc-test-runner skill → Run Tests
    ↓
If tests fail → Fix code → Repeat
    ↓
If tests pass → Feature Complete ✓
```

## References

- [AL Guidelines Index](.claude/al-guidelines/_index.md)
- [LinterCop Rules](.claude/al-guidelines/lintercop/_index.md)
- [Best Practices](.claude/al-guidelines/BestPractices/_index.md)
- [Patterns](.claude/al-guidelines/patterns/_index.md)
