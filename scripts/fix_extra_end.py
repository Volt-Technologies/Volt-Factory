file_path = r'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel\BC\src\Product Variants\tableextension\VOLItemVariantExt.Tab-Ext70107.al'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the extra end; before the closing brace
content = content.replace(
    '''        if GeneratedCode <> '' then
            Rec.Code := GeneratedCode;
    end;
end;
}''',
    '''        if GeneratedCode <> '' then
            Rec.Code := GeneratedCode;
    end;
}'''
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Removed extra end; statement")
