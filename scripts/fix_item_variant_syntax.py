file_path = r'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel\BC\src\Product Variants\tableextension\VOLItemVariantExt.Tab-Ext70107.al'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the missing end; for GetProductDimensionCaption
content = content.replace(
    '''        if Dimension.FindFirst() then
            exit(Dimension."Code Caption");
        exit('');
    
    local procedure GenerateVariantCodeFromDimensions''',
    '''        if Dimension.FindFirst() then
            exit(Dimension."Code Caption");
        exit('');
    end;

    local procedure GenerateVariantCodeFromDimensions'''
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed syntax error in Item Variant table extension")
