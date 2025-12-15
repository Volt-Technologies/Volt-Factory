# Naming Conventions Rules

Consistent naming conventions improve code readability, maintainability, and help AI assistants understand code structure and intent.

## Rule 1: Object Naming Conventions

### Intent
Use consistent naming patterns for all AL objects to improve discoverability and maintain professional standards. Use PascalCase for object names (tables, pages, reports, codeunits) and meaningful, descriptive names that clearly indicate the object's purpose. Object names must not exceed 30 characters total, with a maximum of 26 characters for the name itself to reserve space for prefixes/affixes (3 characters + 1 space).

**IMPORTANT**: All Volt Apparel custom objects must use the "VT" prefix (Volt Technologies).

### Examples

```al
// Good examples (within 26 character limit with VT prefix)
table 50100 "VT Customer Ledger Entry"     // 24 chars
page 50101 "VT Sales Invoice"              // 16 chars
codeunit 50102 "VT Sales Invoice Posting"  // 24 chars
report 50103 "VT Customer Statement"       // 21 chars
```

```al
// Bad examples (avoid abbreviations, unclear names, or length violations)
table 50100 "CustLE"                                // Too abbreviated
page 50101 "SalesInv"                               // Too abbreviated
table 50104 "VT Very Long Customer Ledger Entry"    // 35 chars - exceeds limit
codeunit 50102 "SIPoster"                          // Unclear abbreviation
```

## Rule 2: File Naming Conventions

### Intent
Establish consistent file naming patterns that clearly identify object types and facilitate organized development. Use pattern `<ObjectName>.<ObjectType>.al` and maintain consistency across all file names. Ensure file names are descriptive and match the AL object name within the files.

### Examples

```al
// Good examples
NoSeries.Page.al
NoSeries.Table.al
NoSeriesErrorsImpl.Codeunit.al
NoSeriesSetup.Codeunit.al
CustomerCard.Page.al
SalesHeader.Table.al
PostSalesInvoice.Codeunit.al
ItemLedgerEntry.Report.al
InventorySetup.PageExt.al
SalesHeader.TableExt.al

// For implementations and interfaces
INoSeries.Interface.al
NoSeriesImpl.Codeunit.al

// For test files
NoSeriesTests.Codeunit.al
SalesPostingTests.Codeunit.al
```

## Rule 3: Variable and Function Naming

### Intent
Use consistent naming conventions for variables and functions to improve code readability. Use PascalCase for variable and function names, descriptive names that clearly indicate purpose, and avoid abbreviations unless they are well-known business terms. Use consistent parameter naming in procedures.

### Examples

```al
// Good examples - Variables
var
  CustomerLedgerEntry: Record "Cust. Ledger Entry";
  TotalAmount: Decimal;
  DiscountPercentage: Decimal;
  IsValidTransaction: Boolean;
```

```al
// Good examples - Functions
procedure CalculateCustomerBalance(CustomerNo: Code[20]): Decimal
procedure ValidateSalesDocument(var SalesHeader: Record "Sales Header")
procedure UpdateInventoryQuantity(ItemNo: Code[20]; Quantity: Decimal)
```

## Rule 4: Parameter Naming in Event Subscribers

### Intent
Use meaningful parameter names in event subscribers to improve code clarity and maintainability. Use descriptive parameter names that clearly indicate their purpose, follow Business Central conventions for common parameter types, and maintain consistency across similar event subscribers. Avoid unclear generic names like "Rec" - use specific descriptive names.

### Examples

```al
// Good example - Descriptive parameter names
[EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeInsert, '', false, false)]
local procedure AddDefaultValuesOnBeforeInsertSalesHeader(var SalesHeader: Record "Sales Header"; RunTrigger: Boolean)
begin
  // Event handling logic
end;

[EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeModify, '', false, false)]
local procedure CheckBalanceOnBeforeModifyCustomer(var Customer: Record Customer; var xCustomer: Record Customer)
begin
  // Event handling logic
end;
```

## Rule 5: Interface and Implementation Naming

### Intent
Clearly distinguish between interfaces and their implementations using consistent naming patterns. Prefix interfaces with "I" (e.g., `INoSeries`), use "Impl" suffix for implementation codeunits, and keep interface and implementation names closely related. Ensure names stay within the 26-character limit.

### Examples

```al
// Good examples (within character limits)
// Interface file: ICustomerService.Interface.al
interface ICustomerService
{
    procedure GetCustomerBalance(CustomerNo: Code[20]): Decimal;
}

// Implementation file: CustomerServiceImpl.Codeunit.al
codeunit 50100 "Customer Service Impl" implements ICustomerService
{
    procedure GetCustomerBalance(CustomerNo: Code[20]): Decimal
    begin
        // Implementation logic
    end;
}
```

## Rule 6: Label Variable Naming Conventions

### Intent
**NEVER use literal strings in AL code.** All text strings must be declared as Label variables with appropriate suffixes. This enables proper translation support, maintains code consistency, and makes strings reusable across the codebase.

### Label Suffixes
Use the appropriate suffix based on the label's purpose:

| Suffix | Purpose | Example |
|--------|---------|---------|
| `Lbl` | General labels, captions, field labels | `CustomerNameLbl` |
| `Err` | Error messages | `CustomerNotFoundErr` |
| `Msg` | Information/confirmation messages | `PostingCompletedMsg` |
| `Tok` | Tokens, constants, non-translatable text | `ApiEndpointTok` |
| `Qst` | Questions (confirm dialogs) | `DeleteRecordQst` |
| `Txt` | General text (translatable) | `WelcomeTxt` |

### Comment Property for Placeholders
When a label contains placeholders (`%1`, `%2`, etc.), you **MUST** include the `Comment` property explaining what each placeholder represents.

### Examples

```al
// Good examples - Label variables with proper suffixes
var
    CustomerNotFoundErr: Label 'Customer %1 was not found.', Comment = '%1 = Customer No.';
    PostingSuccessMsg: Label 'Document %1 has been posted successfully.', Comment = '%1 = Document No.';
    DeleteConfirmQst: Label 'Are you sure you want to delete %1 records?', Comment = '%1 = Record count';
    ApiEndpointTok: Label 'https://api.example.com/v1', Locked = true;
    TotalAmountLbl: Label 'Total Amount';

    ValidationFailedErr: Label 'Validation failed for %1 in field %2. Expected %3 but found %4.',
        Comment = '%1 = Record ID, %2 = Field Name, %3 = Expected Value, %4 = Actual Value';

procedure ValidateCustomer(CustomerNo: Code[20])
var
    Customer: Record Customer;
    CustomerNotFoundErr: Label 'Customer %1 was not found in the system.', Comment = '%1 = Customer No.';
begin
    if not Customer.Get(CustomerNo) then
        Error(CustomerNotFoundErr, CustomerNo);
end;
```

```al
// Bad examples - NEVER DO THIS
procedure ValidateCustomer(CustomerNo: Code[20])
var
    Customer: Record Customer;
begin
    if not Customer.Get(CustomerNo) then
        Error('Customer %1 was not found.');  // BAD: Literal string without label variable

    Message('Operation completed');  // BAD: Literal string
end;

procedure ShowMessage()
var
    MyLabel: Label 'Item %1 has quantity %2';  // BAD: Missing Comment property for placeholders
begin
    Message(MyLabel, ItemNo, Quantity);
end;
```

### Key Rules
1. **Never use literal strings** - Always declare Label variables
2. **Use correct suffix** - Match the suffix to the label's purpose (Err, Msg, Lbl, Tok, Qst, Txt)
3. **Document placeholders** - Include `Comment` property explaining each `%1`, `%2`, etc.
4. **Use Locked = true** - For non-translatable tokens (URLs, API keys, technical identifiers)
5. **Keep labels close to usage** - Declare labels in the procedure where they are used when they are procedure-specific
