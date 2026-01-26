# Object Creation Guide

## Before Creating Objects

### 1. Check Feature Ranges

Read `BC/FeatureRanges.md`:
```
#Common
70000 - 70099

#Product Variants
70100 - 70199
```

### 2. Allocate Object IDs

**ALWAYS** use `mcp__objid__allocate_id`:

```
mode: "reserve"
appPath: "C:\path\to\BC"
object_type: "table"
preferred_range: {from: 70100, to: 70199}
object_metadata: {
  name: "VOL Product Variant",
  file: "src/ProductVariants/table/VOLProductVariant.Table.al"
}
```

## Creating a New Table

For each table, create:

### 1. Table Definition

```al
table 70100 "VOL Product Variant"
{
    Caption = 'Product Variant';
    DataClassification = CustomerContent;
    LookupPageId = "VOL Product Variants";
    DrillDownPageId = "VOL Product Variants";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the variant code.';
            NotBlank = true;
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the variant description.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            ToolTip = 'Specifies the item number.';
            TableRelation = Item;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(ItemNo; "Item No.") { }
    }
}
```

### 2. List Page

```al
page 70100 "VOL Product Variants"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "VOL Product Variant";
    CardPageId = "VOL Product Variant Card";
    Caption = 'Product Variants';
    UsageCategory = Lists;
    Editable = false;

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
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
```

### 3. Card Page

```al
page 70101 "VOL Product Variant Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "VOL Product Variant";
    Caption = 'Product Variant Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
```

### 4. Update Permission Set

```al
permissionset 70000 "VOL All"
{
    Permissions =
        // ... existing ...
        table "VOL Product Variant" = X,
        tabledata "VOL Product Variant" = RIMD,
        page "VOL Product Variants" = X,
        page "VOL Product Variant Card" = X;
}
```

## Creating Table Extensions

```al
tableextension 70100 "VOL Customer Ext" extends Customer
{
    fields
    {
        field(70100; "VOL Credit Rating"; Integer)
        {
            Caption = 'Credit Rating';
            ToolTip = 'Specifies the customer credit rating (1-5).';
            MinValue = 1;
            MaxValue = 5;

            trigger OnValidate()
            begin
                if ("VOL Credit Rating" < 1) or ("VOL Credit Rating" > 5) then
                    Error(InvalidRatingErr, "VOL Credit Rating");
            end;
        }
    }

    var
        InvalidRatingErr: Label 'Credit rating must be between 1 and 5. Value: %1', Comment = '%1 = Rating';
}
```

## Creating Page Extensions

```al
pageextension 70100 "VOL Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addafter("Credit Limit (LCY)")
        {
            field("VOL Credit Rating"; Rec."VOL Credit Rating")
            {
                ApplicationArea = All;
            }
        }
    }
}
```

## Creating Enums

```al
enum 70100 "VOL Variant Status"
{
    Caption = 'Variant Status';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Active)
    {
        Caption = 'Active';
    }
    value(2; Inactive)
    {
        Caption = 'Inactive';
    }
    value(3; Discontinued)
    {
        Caption = 'Discontinued';
    }
}
```

## File Naming Convention

```
BC/src/
├── ProductVariants/
│   ├── table/
│   │   └── VOLProductVariant.Table.al
│   ├── page/
│   │   ├── VOLProductVariants.Page.al
│   │   └── VOLProductVariantCard.Page.al
│   ├── codeunit/
│   │   └── VOLProductVariantMgt.Codeunit.al
│   └── enum/
│       └── VOLVariantStatus.Enum.al
└── Common/
    └── permissionset/
        └── VOLAll.PermissionSet.al
```

## Checklist

- [ ] Object IDs allocated via mcp__objid__allocate_id
- [ ] Table has LookupPageId set
- [ ] List page has CardPageId set
- [ ] All fields have Caption and ToolTip
- [ ] DataClassification = CustomerContent (not ToBeClassified)
- [ ] Permission set updated with all new objects
- [ ] File names match object names
- [ ] VOL prefix on all custom objects
