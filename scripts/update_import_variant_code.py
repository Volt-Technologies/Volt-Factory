import re

file_path = r'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel\BC\src\Product Variants\codeunit\VOLImportItemVariants.Cod70102.al'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the GetNewVariantNo procedure with enhanced version
old_proc = '''    Local procedure GetNewVariantNo(var ItemVariant2: Record "Item Variant")
    var
        VOLApparelSetup: Record "VOLApparelSetup";
        VariantCodeGenerator: Codeunit "VOLVariant Code Generator";
        GeneratedCode: Code[10];
    begin
        if not VOLApparelSetup.Get() then
            exit;

        // For No. Series method, generate code immediately
        if VOLApparelSetup."Variant Code Method" = VOLApparelSetup."Variant Code Method"::"No. Series" then begin
            GeneratedCode := VariantCodeGenerator.GenerateVariantCode(ItemVariant2."Item No.", '', '', '', '');
            if GeneratedCode <> '' then
                ItemVariant2.Code := GeneratedCode;
        end;
        // For pattern-based methods, we can't generate the code here because we don't have dimension values yet
        // The code will be generated later based on the dimension values in the Excel file
    end;'''

new_proc = '''    Local procedure GetNewVariantNo(var ItemVariant2: Record "Item Variant")
    var
        VOLApparelSetup: Record "VOLApparelSetup";
        VariantCodeGenerator: Codeunit "VOLVariant Code Generator";
        GeneratedCode: Code[10];
    begin
        if not VOLApparelSetup.Get() then
            exit;

        // For No. Series method, generate code immediately
        if VOLApparelSetup."Variant Code Method" = VOLApparelSetup."Variant Code Method"::"No. Series" then begin
            GeneratedCode := VariantCodeGenerator.GenerateVariantCode(ItemVariant2."Item No.", '', '', '', '');
            if GeneratedCode <> '' then
                ItemVariant2.Code := GeneratedCode;
        end;
        // For pattern-based methods, the code will be generated after default dimensions are inserted
        // by the GenerateCodeFromDefaultDimensions procedure
    end;'''

content = content.replace(old_proc, new_proc)

# Find the ImportItemVariantExcel procedure and modify it to generate codes after inserting dimensions
# Find where we insert the item variant
old_import_section = '''            ItemVariant2.Description := GetDescription(ItemVariant2.Code);
            ItemVariant2.Insert(false);
            ItemVariant2."VOLUpdateDimensionSetID"();
            Counter += 1;
        end;'''

new_import_section = '''            // Generate code from dimensions if using pattern-based method
            GenerateCodeFromDefaultDimensions(ItemVariant2);

            ItemVariant2.Description := GetDescription(ItemVariant2.Code);
            ItemVariant2.Insert(false);
            ItemVariant2."VOLUpdateDimensionSetID"();
            Counter += 1;
        end;'''

content = content.replace(old_import_section, new_import_section)

# Add the new procedure before the var section
var_section_idx = content.rfind('    var\n        ItemVariant: Record "Item Variant";')
if var_section_idx > 0:
    new_procedure = '''    local procedure GenerateCodeFromDefaultDimensions(var ItemVariant2: Record "Item Variant")
    var
        VOLApparelSetup: Record "VOLApparelSetup";
        VariantCodeGenerator: Codeunit "VOLVariant Code Generator";
        DefaultDimension: Record "Default Dimension";
        Dimension: Record Dimension;
        ColorCode: Code[20];
        SizeCode: Code[20];
        Dim3Code: Code[20];
        Dim4Code: Code[20];
        GeneratedCode: Code[10];
    begin
        if not VOLApparelSetup.Get() then
            exit;

        // Only for pattern-based methods
        if VOLApparelSetup."Variant Code Method" = VOLApparelSetup."Variant Code Method"::"No. Series" then
            exit;

        // Extract dimension values from default dimensions
        DefaultDimension.SetRange("Table ID", Database::"Item Variant");
        DefaultDimension.SetRange("No.", ItemVariant2.Code);
        if DefaultDimension.FindSet() then
            repeat
                if Dimension.Get(DefaultDimension."Dimension Code") then
                    case Dimension."VOLProduct Dimension No." of
                        Dimension."VOLProduct Dimension No."::"Product Dimension 1":
                            ColorCode := DefaultDimension."Dimension Value Code";
                        Dimension."VOLProduct Dimension No."::"Product Dimension 2":
                            SizeCode := DefaultDimension."Dimension Value Code";
                        Dimension."VOLProduct Dimension No."::"Product Dimension 3":
                            Dim3Code := DefaultDimension."Dimension Value Code";
                        Dimension."VOLProduct Dimension No."::"Product Dimension 4":
                            Dim4Code := DefaultDimension."Dimension Value Code";
                    end;
            until DefaultDimension.Next() = 0;

        // Generate the code
        GeneratedCode := VariantCodeGenerator.GenerateVariantCode(ItemVariant2."Item No.", ColorCode, SizeCode, Dim3Code, Dim4Code);
        if GeneratedCode <> '' then
            ItemVariant2.Code := GeneratedCode;
    end;

'''
    content = content[:var_section_idx] + new_procedure + content[var_section_idx:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Successfully updated import codeunit with pattern-based code generation")
