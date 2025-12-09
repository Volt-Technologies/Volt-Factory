import re

file_path = r'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel\BC\src\Product Variants\tableextension\VOLItemVariantExt.Tab-Ext70107.al'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Find the VOLUpdateDimensionSetID procedure and add variant code generation logic
# Find where we set the description (just before Rec.Modify())
old_code = '''            rec.Description := '';//start blank
            for i := 1 to ARRAYLEN(DescriptionArray) do
                Rec.Description := copystr(Rec.Description + DescriptionArray[i], 1, 100);
            Rec.Modify();'''

new_code = '''            rec.Description := '';//start blank
            for i := 1 to ARRAYLEN(DescriptionArray) do
                Rec.Description := copystr(Rec.Description + DescriptionArray[i], 1, 100);

            // Generate variant code based on selected method
            GenerateVariantCodeFromDimensions(DescriptionArray);

            Rec.Modify();'''

content = content.replace(old_code, new_code)

# Add the new procedure at the end, before the closing brace
# Find the last procedure (GetProductDimensionCaption)
last_proc_end = content.rfind('end;\n}')
if last_proc_end > 0:
    new_procedure = '''
    local procedure GenerateVariantCodeFromDimensions(DimValues: array[4] of Text[25])
    var
        ApparelSetup: Record VOLApparelSetup;
        VariantCodeGenerator: Codeunit "VOLVariant Code Generator";
        ColorCode: Code[20];
        SizeCode: Code[20];
        Dim3Code: Code[20];
        Dim4Code: Code[20];
        GeneratedCode: Code[10];
    begin
        if not ApparelSetup.Get() then
            exit;

        // Only generate code for pattern-based methods, not No. Series
        if ApparelSetup."Variant Code Method" = ApparelSetup."Variant Code Method"::"No. Series" then
            exit;

        // If the code was already set (e.g., from No. Series or manual entry), don't overwrite
        if Rec.Code <> '' then
            exit;

        // Extract dimension values from the array (remove ' : ' prefix)
        ColorCode := CopyStr(DimValues[1], 1, 20);
        if StrLen(DimValues[2]) > 3 then
            SizeCode := CopyStr(DimValues[2], 4, 20)  // Skip ' : ' prefix
        else
            SizeCode := '';
        if StrLen(DimValues[3]) > 3 then
            Dim3Code := CopyStr(DimValues[3], 4, 20)
        else
            Dim3Code := '';
        if StrLen(DimValues[4]) > 3 then
            Dim4Code := CopyStr(DimValues[4], 4, 20)
        else
            Dim4Code := '';

        // Generate the code
        GeneratedCode := VariantCodeGenerator.GenerateVariantCode(Rec."Item No.", ColorCode, SizeCode, Dim3Code, Dim4Code);
        if GeneratedCode <> '' then
            Rec.Code := GeneratedCode;
    end;
'''
    content = content[:last_proc_end] + new_procedure + content[last_proc_end:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Successfully added variant code generation logic to Item Variant table extension")
