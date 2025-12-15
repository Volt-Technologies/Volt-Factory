# AL Code Style & Formatting Rules

These rules ensure consistent code structure and organization across AL projects, making code more maintainable and AI-assistant friendly.

## Style guidelines for AL code
- Always use PascalCase for variable and function names.
- Use PascalCase for object names (e.g., tables, pages, reports).
- Maintain a consistent indentation style (2 spaces preferred).

## Commonly used methods and patterns
- Temporary tables for performance optimization
- Use of events for extensibility

## Rule 1: Consistent Indentation and Formatting

### Intent
Maintain consistent code formatting to improve readability and enable better AI understanding of code structure. Use indentation with two spaces consistently throughout your project and maintain consistent formatting within functions and procedures.

### Examples

```al
// Good example
procedure CalculateDiscount(Amount: Decimal; DiscountPct: Decimal): Decimal
begin
  if DiscountPct > 0 then
    exit(Amount * DiscountPct / 100);

  exit(0);
end;
```

## Rule 2: Feature-Based Folder Organization

### Intent
Organize code by business features rather than object types to improve maintainability and logical grouping. Use feature-based organization with `src/feature/subfeature/` structure and place shared components in `Common` or `Shared` folders.

### Examples

```
// Good example - Feature-based organization
src/
├── NoSeries/
│   ├── NoSeries.Table.al
│   ├── NoSeries.Page.al
│   └── NoSeriesSetup.Codeunit.al
├── Sales/
│   ├── Invoice/
│   │   ├── SalesInvoice.Page.al
│   │   └── SalesInvoicePosting.Codeunit.al
│   └── Order/
│       └── SalesOrder.Page.al
└── Common/
    ├── Helpers/
    │   └── DateHelper.Codeunit.al
    └── Interfaces/
        └── IPostable.Interface.al
```

```
// Bad example (avoid object-type segregation)
src/
├── Tables/
│   ├── NoSeries.Table.al
│   └── SalesHeader.Table.al
├── Pages/
│   ├── NoSeries.Page.al
│   └── SalesInvoice.Page.al
└── Codeunits/
    ├── NoSeriesSetup.Codeunit.al
    └── SalesInvoicePosting.Codeunit.al
```

## Rule 3: Code Documentation and Comments

### Intent
Provide clear documentation for global functions using XML documentation comments. Code should be self-documenting through clear naming, but global functions in codeunits require proper documentation for API clarity.

**IMPORTANT: Do NOT use inline `//` comments in AL code.** If documentation is needed, use XML documentation comments (`/// <summary>`) for procedures. The code itself should be self-explanatory through clear naming and structure.

### Guidelines
- **Use XML documentation** (`/// <summary>`, `/// <param>`, `/// <returns>`) for global/public procedures
- **Avoid `//` inline comments** - Code should be self-documenting through proper naming
- **Never comment obvious code** - If code needs explanation, refactor it to be clearer
- **Use meaningful names** instead of comments to explain what code does

### Examples

```al
// Good example - XML documentation for global functions, NO inline comments
codeunit 50100 "Base64 Convert"
{
    /// <summary>
    /// Converts the value of the input string to its equivalent string representation that is encoded with base-64 digits.
    /// </summary>
    /// <param name="String">The string to convert.</param>
    /// <returns>The string representation, in base-64, of the input string.</returns>
    procedure ToBase64(String: Text): Text
    begin
        exit(Base64ConvertImpl.ToBase64(String));
    end;

    /// <summary>
    /// Validates discount percentage against business rules.
    /// </summary>
    /// <param name="DiscountPct">The discount percentage to validate.</param>
    procedure ValidateDiscountPercentage(DiscountPct: Decimal)
    var
        DiscountExceedsMaxErr: Label 'Discount cannot exceed 50%% due to company policy.';
        DiscountNegativeErr: Label 'Discount percentage cannot be negative.';
    begin
        if DiscountPct > 50 then
            Error(DiscountExceedsMaxErr);

        if DiscountPct < 0 then
            Error(DiscountNegativeErr);
    end;
}
```

```al
// Bad example - DO NOT USE inline // comments
procedure ValidateDiscountPercentage(DiscountPct: Decimal)
begin
  // Check if discount is greater than 50        <-- BAD: Don't use // comments
  if DiscountPct > 50 then
    Error('Discount cannot exceed 50%');         // <-- BAD: Literal string

  // Check if discount is less than 0            <-- BAD: Comment states the obvious
  if DiscountPct < 0 then
    Error('Discount percentage cannot be negative');
end;
```

## Rule 4: No Literal Strings - Use Label Variables

### Intent
**NEVER use literal strings (hardcoded text) directly in AL code.** All text must be defined as Label variables with appropriate suffixes. This is mandatory for translation support, consistency, and maintainability.

See [AL Naming Conventions - Rule 6](./al-naming-conventions.instructions.md#rule-6-label-variable-naming-conventions) for complete Label naming rules including suffixes (Lbl, Err, Msg, Tok, Qst, Txt) and placeholder documentation requirements.

### Quick Reference

```al
// CORRECT - Using Label variables
procedure ProcessOrder(OrderNo: Code[20])
var
    Order: Record "Sales Header";
    OrderNotFoundErr: Label 'Order %1 could not be found.', Comment = '%1 = Order No.';
    ProcessingCompleteMsg: Label 'Order %1 has been processed successfully.', Comment = '%1 = Order No.';
begin
    if not Order.Get(Order."Document Type"::Order, OrderNo) then
        Error(OrderNotFoundErr, OrderNo);

    ProcessOrderInternal(Order);
    Message(ProcessingCompleteMsg, OrderNo);
end;
```

```al
// WRONG - Literal strings (NEVER DO THIS)
procedure ProcessOrder(OrderNo: Code[20])
var
    Order: Record "Sales Header";
begin
    if not Order.Get(Order."Document Type"::Order, OrderNo) then
        Error('Order %1 could not be found.', OrderNo);  // BAD!

    ProcessOrderInternal(Order);
    Message('Order processed successfully.');  // BAD!
end;
```

## Rule 5: Modular and Reusable Code Structure

### Intent
Keep code modular and reusable to enhance maintainability and reduce duplication. Write small, focused procedures that do one thing well and use interfaces and patterns where appropriate.

### Examples

```al
// Good example - Modular approach
procedure PostDocument(var DocumentHeader: Record "Sales Header")
begin
  ValidateDocument(DocumentHeader);
  CalculateTotals(DocumentHeader);
  CreateLedgerEntries(DocumentHeader);
  UpdateStatus(DocumentHeader);
end;

local procedure ValidateDocument(var DocumentHeader: Record "Sales Header")
begin
  if DocumentHeader."No." = '' then
    Error('Document number cannot be empty');
end;

local procedure CalculateTotals(var DocumentHeader: Record "Sales Header")
begin
  DocumentHeader.CalcFields(Amount);
end;
```

```al
// Bad example (avoid monolithic procedures)
procedure PostDocument(var DocumentHeader: Record "Sales Header")
begin
  // All validation, calculation, and posting logic in one procedure
  // ... 200+ lines of mixed concerns
end;
```

## Rule 6: Assisted Setup (Wizard) Pages

### Intent
When creating Assisted Setup pages (wizard-style pages with `PageType = NavigatePage`), actions must have `InFooterBar = true` to be visible. Without this property, navigation actions like Back, Next, and Finish will not appear on the page.

### Required Properties
- **PageType = NavigatePage** - Defines the page as a wizard/assisted setup
- **InFooterBar = true** - Required on ALL actions for them to be visible in the footer navigation bar

### Examples

```al
// CORRECT - Actions with InFooterBar = true
page 50100 "VT Setup Wizard"
{
    PageType = NavigatePage;
    Caption = 'Setup Wizard';

    layout
    {
        area(Content)
        {
            // Wizard steps...
        }
    }

    actions
    {
        area(Processing)
        {
            action(Back)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Image = PreviousRecord;
                InFooterBar = true;  // REQUIRED - Action visible in footer

                trigger OnAction()
                begin
                    CurrentStep -= 1;
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Image = NextRecord;
                InFooterBar = true;  // REQUIRED - Action visible in footer

                trigger OnAction()
                begin
                    CurrentStep += 1;
                end;
            }
            action(Finish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Image = Approve;
                InFooterBar = true;  // REQUIRED - Action visible in footer

                trigger OnAction()
                begin
                    FinishSetup();
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        CurrentStep: Integer;
}
```

```al
// WRONG - Actions will NOT be visible without InFooterBar
page 50100 "VT Setup Wizard"
{
    PageType = NavigatePage;

    actions
    {
        area(Processing)
        {
            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                // MISSING: InFooterBar = true - Action will NOT appear!

                trigger OnAction()
                begin
                    CurrentStep += 1;
                end;
            }
        }
    }
}
```

### Key Points
1. **Always set `InFooterBar = true`** on all actions in NavigatePage pages
2. Common actions include: Back, Next, Finish, Cancel
3. Use `Visible` property to show/hide actions based on current step
4. Use `Enabled` property to control when actions can be clicked

## Rule 7: Caption and ToolTip Properties in Tables, Not Pages

### Intent
**Define `Caption` and `ToolTip` properties on table fields, NOT on page fields.** This ensures consistency across all pages that use the same table field and reduces maintenance overhead. When a field is displayed on multiple pages, the caption and tooltip are automatically inherited from the table definition.

### Benefits
- **Single source of truth** - Change caption/tooltip once in the table, all pages reflect the change
- **Consistency** - Same field always displays the same caption across all pages
- **Less code duplication** - No need to repeat captions and tooltips on every page
- **Easier maintenance** - Update translations and tooltips in one place

### Examples

```al
// CORRECT - Caption and ToolTip defined in TABLE
table 50100 "VT Custom Table"
{
    Caption = 'Custom Table';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the unique identifier for this record.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the record.';
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
            ToolTip = 'Specifies the total amount for this record.';
        }
    }
}

// CORRECT - Page fields WITHOUT Caption/ToolTip (inherited from table)
page 50100 "VT Custom Card"
{
    PageType = Card;
    SourceTable = "VT Custom Table";
    Caption = 'Custom Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    // NO Caption - inherited from table
                    // NO ToolTip - inherited from table
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    // NO Caption - inherited from table
                    // NO ToolTip - inherited from table
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    // NO Caption - inherited from table
                    // NO ToolTip - inherited from table
                }
            }
        }
    }
}
```

```al
// WRONG - Caption and ToolTip duplicated in PAGE (DO NOT DO THIS)
page 50100 "VT Custom Card"
{
    PageType = Card;
    SourceTable = "VT Custom Table";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';  // BAD - Should be in table
                    ToolTip = 'Specifies the unique identifier.';  // BAD - Should be in table
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';  // BAD - Should be in table
                    ToolTip = 'Specifies a description.';  // BAD - Should be in table
                }
            }
        }
    }
}
```

### Exceptions
Only define Caption/ToolTip on page fields when:
1. **Overriding for context** - The field needs a different caption on a specific page for clarity
2. **Calculated/virtual fields** - Fields that don't exist in the source table (e.g., FlowFields displayed differently)
3. **Page-specific fields** - Fields bound to page variables, not table fields

### Key Rules
1. **Always define Caption and ToolTip on table fields**
2. **Never duplicate Caption/ToolTip on page fields** unless overriding for a specific reason
3. **ToolTip is mandatory** - All fields must have tooltips for accessibility and user guidance
4. **Use consistent tooltip format** - Start with "Specifies..." for data fields
