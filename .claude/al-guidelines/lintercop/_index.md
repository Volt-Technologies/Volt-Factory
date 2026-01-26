---
alwaysApply: true
---
# LinterCop Rules Index

This folder contains comprehensive guidelines based on the BusinessCentral.LinterCop analyzer. These rules MUST be followed when writing AL code.

## Rule Files

| File | Rules | Description |
|------|-------|-------------|
| LC0001-LC0010.md | LC0001-LC0010 | Core rules: FlowFields, Commit, Object IDs, Casing, Code Metrics |
| LC0011-LC0020.md | LC0011-LC0020 | Object design: Access, Permissions, Captions, DataClassification |
| LC0021-LC0030.md | LC0021-LC0030 | Best practices: Confirm/Translation Helpers, FieldGroups, Documentation |
| LC0031-LC0040.md | LC0031-LC0040 | Modern AL: ReadIsolation, SecretText, ToolTips, RunTrigger |
| LC0041-LC0050.md | LC0041-LC0050 | Labels and Enums: Locked labels, Empty captions, AutoCalcFields |
| LC0051-LC0060.md | LC0051-LC0060 | Code quality: Overflow, Unused procedures, Interface naming, API pages |
| LC0061-LC0070.md | LC0061-LC0070 | API development: ODataKeyFields, Mandatory fields, Permissions |
| LC0071-LC0080.md | LC0071-LC0080 | Events and JSON: IsHandled pattern, Event publishers, JPath |
| LC0081-LC0093.md | LC0081-LC0093 | Performance: IsEmpty, Query, Cognitive complexity, Tests |

## Severity Levels

- **Error**: Code will not compile or will fail at runtime. MUST be fixed.
- **Warning**: Indicates likely bugs or bad practices. SHOULD be fixed.
- **Info**: Suggestions for better code quality. Consider fixing.
- **Hidden**: Default disabled rules. Enable as needed.

## Critical Rules Summary

### ERRORS (Must Fix)
- **LC0006**: AutoIncrement fields cannot be used in temporary tables

### WARNINGS (Should Fix)
| Rule | Description |
|------|-------------|
| LC0001 | FlowFields must have Editable = false |
| LC0002 | Commit() requires explanatory comment |
| LC0003 | Use object names, not IDs in declarations |
| LC0005 | Variable casing must match declaration |
| LC0008 | Don't use filter operators in SetRange |
| LC0032 | Clear(All) doesn't affect SingleInstance codeunits |
| LC0039 | Argument type must match expected type |
| LC0042 | AutoCalcFields only for FlowFields/Blobs |
| LC0051 | Avoid text overflow in assignments |
| LC0058 | Don't use temporary records in page methods |
| LC0059 | Escape single quotes properly |
| LC0065 | Event subscriber var keyword must match publisher |
| LC0073 | IsHandled parameters must be passed by var |
| LC0074 | Don't assign directly to FlowFilter fields |
| LC0075 | Get() arguments must match primary key |
| LC0076 | TableRelation field length must be compatible |
| LC0080 | Use single quotes in JPath expressions |
| LC0087 | Use IsNullGuid() for GUID checks |

### INFO (Consider Fixing)
| Category | Rules |
|----------|-------|
| **Documentation** | LC0016, LC0026, LC0036-LC0038, LC0064, LC0066, LC0072 |
| **Naming** | LC0046-LC0047, LC0054-LC0055, LC0063, LC0092 |
| **API Pages** | LC0060-LC0062 |
| **Performance** | LC0009, LC0031, LC0081-LC0082 |
| **Events** | LC0018, LC0028, LC0071, LC0079 |
| **Modern AL** | LC0029, LC0043, LC0083, LC0085-LC0086, LC0088 |
| **Best Practices** | LC0019-LC0027, LC0040-LC0041, LC0048-LC0050, LC0052-LC0053, LC0069, LC0078 |

## Quick Reference - Common Patterns

### FlowFields
```al
field(50; "Total Amount"; Decimal)
{
    FieldClass = FlowField;
    CalcFormula = sum(...);
    Editable = false;  // REQUIRED (LC0001)
}
```

### Labels
```al
// Token labels must be locked (LC0046)
var
    ApiEndpointTok: Label '/api/v1', Locked = true;

// Tooltips must start with "Specifies" and end with "." (LC0026, LC0036)
field(Name; Rec.Name)
{
    ToolTip = 'Specifies the name of the customer.';
}
```

### API Pages
```al
page 50100 "VOL API"
{
    PageType = API;
    ODataKeyFields = SystemId;  // REQUIRED (LC0061)
    // NO ApplicationArea (LC0060)
}
```

### Event Subscribers
```al
// var keyword must match publisher (LC0065)
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePost, '', false, false)]
local procedure HandleOnBeforePost(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
begin
    // Never set IsHandled to false (LC0071)
    if NeedToHandle then
        IsHandled := true;
end;
```

### Performance
```al
// Use IsEmpty() not Count() (LC0081)
if not SalesHeader.IsEmpty() then
    ProcessOrders();

// Use SetFilter for operators, SetRange for simple values (LC0008)
Customer.SetRange("Customer Posting Group", 'DOMESTIC');
Customer.SetFilter(Name, '@*smith*');
```
