# AL Quick Reference

## Object Naming

| Type | Pattern | Example |
|------|---------|---------|
| Table | `VOL {Singular}` | `VOL Product Variant` |
| List Page | `VOL {Plural}` | `VOL Product Variants` |
| Card Page | `VOL {Singular} Card` | `VOL Product Variant Card` |
| Codeunit | `VOL {Feature} Mgt.` | `VOL Variant Mgt.` |
| Enum | `VOL {Singular}` | `VOL Variant Status` |
| Report | `VOL {Description}` | `VOL Variant List` |

## Variable Naming

| Type | Pattern | Example |
|------|---------|---------|
| Record | `{TableName}` | `ProductVariant` |
| Codeunit | `{CodeunitName}` | `VariantMgt` |
| Text | `{Purpose}Txt` | `ConfirmTxt` |
| Label | `{Purpose}Lbl` | `ErrorLbl` |
| Error | `{Context}Err` | `InvalidQtyErr` |

## Key LinterCop Rules

### LC0001: FlowFields Editable
```al
// ✗ Wrong
field(100; "Total Amount"; Decimal)
{
    FieldClass = FlowField;
}

// ✓ Correct
field(100; "Total Amount"; Decimal)
{
    FieldClass = FlowField;
    Editable = false;
}
```

### LC0003: Use Object Names
```al
// ✗ Wrong
SourceTable = 18;

// ✓ Correct
SourceTable = Customer;
```

### LC0040: RunTrigger Parameter
```al
// ✗ Wrong
Rec.Insert();

// ✓ Correct
Rec.Insert(true);
```

### LC0081: Use IsEmpty
```al
// ✗ Wrong
if Customer.Count() > 0 then

// ✓ Correct
if not Customer.IsEmpty() then
```

## Label Pattern

```al
var
    ConfirmDeleteLbl: Label 'Delete %1?', Comment = '%1 = Record';
    RecordNotFoundErr: Label 'Record %1 not found.', Comment = '%1 = Code';
    SuccessMsg: Label 'Operation completed successfully.';
    YesTok: Label 'Yes', Locked = true;
```

## Test Pattern

```al
codeunit 70200 "VOL Feature Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestScenario_Condition_ExpectedResult()
    begin
        // [GIVEN] Setup
        // [WHEN] Action
        // [THEN] Assertion
    end;
}
```

## Error Handling

```al
procedure ValidateField(Value: Code[20])
var
    InvalidValueErr: Label 'Invalid value: %1', Comment = '%1 = Value';
begin
    if Value = '' then
        Error(InvalidValueErr, Value);
end;
```

## Table Structure

```al
table 70100 "VOL Example"
{
    Caption = 'Example';
    DataClassification = CustomerContent;
    LookupPageId = "VOL Examples";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the code.';
            NotBlank = true;
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description.';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
```

## Page Structure

```al
page 70100 "VOL Examples"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "VOL Example";
    CardPageId = "VOL Example Card";
    Caption = 'Examples';
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
```

## Codeunit Structure

```al
codeunit 70100 "VOL Example Mgt."
{
    /// <summary>
    /// Processes the example record.
    /// </summary>
    /// <param name="Example">The example to process.</param>
    procedure ProcessExample(var Example: Record "VOL Example")
    begin
        Example.TestField("Code");
        // Logic here
    end;
}
```

## Permission Set

```al
permissionset 70000 "VOL All"
{
    Caption = 'VOL All Permissions';
    Assignable = true;

    Permissions =
        table "VOL Example" = X,
        tabledata "VOL Example" = RIMD,
        page "VOL Examples" = X,
        page "VOL Example Card" = X,
        codeunit "VOL Example Mgt." = X;
}
```
