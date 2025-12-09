import re

# Update VOLItemVariantsDimMgt.Cod70104.al
file1_path = r'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel\BC\src\Product Variants\codeunit\VOLItemVariantsDimMgt.Cod70104.al'
with open(file1_path, 'r', encoding='utf-8') as f:
    content1 = f.read()

# Replace the OnNewItemVariant procedure
old_proc1 = '''    [EventSubscriber(ObjectType::Page, Page::"Item Variants", 'OnNewRecordEvent', '', false, false)]
    Local procedure OnNewItemVariant(var Rec: Record "Item Variant")
    var
        VOLApparelSetup: Record "VOLApparelSetup";
        NoSeriesManagement: Codeunit "No. Series";
        TempRecCode: code[20];
    begin
        if VOLApparelSetup.Get() then begin
            if (NoSeriesManagement.IsManual(VOLApparelSetup."Item Variant Nos.")) then
                exit;
            TempRecCode := rec.Code;
            NoSeriesManagement.GetNextNo(VOLApparelSetup."Item Variant Nos.", WorkDate());
            if StrLen(TempRecCode) <= 10 then
                Rec.Code := Text.CopyStr(TempRecCode, 1, 10)
            else
                error(TextTeLongErr, Rec.FieldCaption(Code), Rec.TableCaption, Format(10), TempRecCode, strlen(TempRecCode));
        end;
    end;'''

new_proc1 = '''    [EventSubscriber(ObjectType::Page, Page::"Item Variants", 'OnNewRecordEvent', '', false, false)]
    Local procedure OnNewItemVariant(var Rec: Record "Item Variant")
    var
        VOLApparelSetup: Record "VOLApparelSetup";
        VariantCodeGenerator: Codeunit "VOLVariant Code Generator";
        GeneratedCode: Code[10];
    begin
        if not VOLApparelSetup.Get() then
            exit;

        // For No. Series method, check if manual entry is allowed
        if VOLApparelSetup."Variant Code Method" = VOLApparelSetup."Variant Code Method"::"No. Series" then begin
            GeneratedCode := VariantCodeGenerator.GenerateVariantCode(Rec."Item No.", '', '', '', '');
            if GeneratedCode <> '' then
                Rec.Code := GeneratedCode;
        end;
        // For pattern-based methods, we can't generate the code here because we don't have dimension values yet
        // The code will be generated when the user selects dimensions
    end;'''

content1 = content1.replace(old_proc1, new_proc1)

with open(file1_path, 'w', encoding='utf-8') as f:
    f.write(content1)

print(f"Updated {file1_path}")

# Update VOLImportItemVariants.Cod70102.al
file2_path = r'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel\BC\src\Product Variants\codeunit\VOLImportItemVariants.Cod70102.al'
with open(file2_path, 'r', encoding='utf-8') as f:
    content2 = f.read()

# Replace the GetNewVariantNo procedure
old_proc2 = '''    Local procedure GetNewVariantNo(var ItemVariant2: Record "Item Variant")
    var
        VOLApparelSetup: Record "VOLApparelSetup";
        NoSeriesManagement: Codeunit "No. Series";
        TempRecCode: code[20];
    begin
        if VOLApparelSetup.Get() then begin
            TempRecCode := NoSeriesManagement.GetNextNo(VOLApparelSetup."Item Variant Nos.", WorkDate());
            if StrLen(TempRecCode) <= 10 then
                ItemVariant2.Code := Text.CopyStr(TempRecCode, 1, 10)
            else
                error(TextTeLongErr, ItemVariant2.FieldCaption(Code), ItemVariant2.TableCaption, Format(10), TempRecCode, strlen(TempRecCode));
        end;
    end;'''

new_proc2 = '''    Local procedure GetNewVariantNo(var ItemVariant2: Record "Item Variant")
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

content2 = content2.replace(old_proc2, new_proc2)

with open(file2_path, 'w', encoding='utf-8') as f:
    f.write(content2)

print(f"Updated {file2_path}")

print("\\nSuccessfully updated variant code generation logic in both codeunits")
