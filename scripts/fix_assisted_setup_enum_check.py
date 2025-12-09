file_path = r'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel\BC\src\Common\page\VOLApparelAssistedSetup.Pag70000.al'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the enum comparison - enum doesn't have a blank value
content = content.replace(
    '''        VariantCodeMethod := VariantCodeMethod::"No. Series";
        if Rec.Get() and (Rec."Variant Code Method" <> Rec."Variant Code Method"::" ") then
            VariantCodeMethod := Rec."Variant Code Method";''',
    '''        VariantCodeMethod := VariantCodeMethod::"No. Series";
        if Rec.Get() then
            VariantCodeMethod := Rec."Variant Code Method";'''
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed enum check in Assisted Setup")
