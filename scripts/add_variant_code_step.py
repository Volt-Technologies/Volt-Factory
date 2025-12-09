import re

# Read the file
file_path = r'C:\Users\Usuario\Repositories\V\Apparel\Volt-Apparel\BC\src\Common\page\VOLApparelAssistedSetup.Pag70000.al'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update the Step enum to include VariantCodeMethodSetup
content = content.replace(
    'Step: Option Introduction,ProductDimensionsSetup,OptionalDimensionsSetup,DimensionCreation,ColorDataSetup,SizeDataSetup,Dimension3ValuesSetup,Dimension4ValuesSetup,Finish;',
    'Step: Option Introduction,ProductDimensionsSetup,OptionalDimensionsSetup,DimensionCreation,VariantCodeMethodSetup,ColorDataSetup,SizeDataSetup,Dimension3ValuesSetup,Dimension4ValuesSetup,Finish;'
)

# 2. Add new variable for VariantCodeMethod
var_section = content.find('var\n        Step: Option')
if var_section > 0:
    # Find end of variable section (before local procedures)
    local_proc_idx = content.find('local procedure', var_section)
    if local_proc_idx > 0:
        insert_point = content.rfind(';', var_section, local_proc_idx) + 1
        content = content[:insert_point] + '\n        VariantCodeMethod: Enum "VOLVariant Code Method";' + content[insert_point:]

# 3. Add the new step group after StepDimensionCreation
new_step_html = '''
            group(StepVariantCodeMethod)
            {
                Visible = Step = Step::VariantCodeMethodSetup;
                ShowCaption = false;

                group(VariantCodeMethodGroup)
                {
                    Caption = 'Item Variant Code Generation Method';
                    InstructionalText = 'Choose how Item Variant codes will be generated. You can use a Number Series or build codes from dimension values like Color and Size.';

                    group(VariantCodeMethodOptions)
                    {
                        Caption = 'Code Generation Method';

                        field(VariantCodeMethodField; VariantCodeMethod)
                        {
                            ApplicationArea = All;
                            Caption = 'Variant Code Method';
                            ToolTip = 'Specifies how Item Variant codes will be generated.';
                        }
                    }

                    group(VariantCodeMethodInfoGroup)
                    {
                        Caption = '';
                        ShowCaption = false;

                        field(VariantCodeMethodInfo; VariantCodeMethodInfoTxt)
                        {
                            ApplicationArea = All;
                            Caption = '';
                            Editable = false;
                            MultiLine = true;
                            ShowCaption = false;
                            Style = AttentionAccent;
                        }
                    }
                }
            }
'''

# Find where to insert (after StepDimensionCreation group closes)
dimension_creation_end = content.find('group(StepColorData)')
if dimension_creation_end > 0:
    content = content[:dimension_creation_end] + new_step_html + '\n            ' + content[dimension_creation_end:]

# 4. Add label text for the new step
label_section = content.find('DimensionsCreatedLbl: Label')
if label_section > 0:
    next_section_idx = content.find('local procedure', label_section)
    if next_section_idx > 0:
        insert_point_label = content.rfind(';', label_section, next_section_idx) + 1
        content = content[:insert_point_label] + '\n        VariantCodeMethodInfoTxt: Label \'Choose how to generate Item Variant codes:\\- No. Series: Use the configured number series (traditional method)\\- Color-Size: Generate codes from Color and Size dimension values\\- Color-Size-Dim3: Include third dimension in the code\\- Color-Size-Dim3-Dim4: Include all four product dimensions\\\\Important: Generated codes will never exceed 10 characters and will be truncated if necessary.\';' + content[insert_point_label:]

# 5. Update SetControlVisibility to handle the new step
set_control_visibility = content.find('Step::DimensionCreation:')
if set_control_visibility > 0:
    # Find the end of DimensionCreation case
    end_of_case = content.find('end;', set_control_visibility)
    # Find next case
    next_case = content.find('Step::', set_control_visibility + 1)
    if next_case > end_of_case:
        # Insert new case before next case
        new_case = '''            Step::VariantCodeMethodSetup:
                begin
                    BackActionEnabled := true;
                    NextActionEnabled := true;
                end;
'''
        content = content[:next_case] + new_case + '            ' + content[next_case:]

# 6. Initialize VariantCodeMethod in InitializeDefaultValues
init_defaults = content.find('local procedure InitializeDefaultValues()')
if init_defaults > 0:
    # Find the begin of this procedure
    begin_idx = content.find('begin', init_defaults)
    if begin_idx > 0:
        # Add initialization after begin
        next_line = content.find('\n', begin_idx) + 1
        content = content[:next_line] + '        VariantCodeMethod := VariantCodeMethod::"No. Series";\n        if Rec.Get() and (Rec."Variant Code Method" <> Rec."Variant Code Method"::" ") then\n            VariantCodeMethod := Rec."Variant Code Method";\n\n' + content[next_line:]

# 7. Save VariantCodeMethod in FinalizeSetup
finalize_setup = content.find('local procedure FinalizeSetup()')
if finalize_setup > 0:
    # Find where we save other settings
    save_dim3 = content.find('Rec."VOLDimension 3 Code" := Dimension3Code;', finalize_setup)
    if save_dim3 > 0:
        next_line = content.find('\n', save_dim3) + 1
        content = content[:next_line] + '        Rec."Variant Code Method" := VariantCodeMethod;\n' + content[next_line:]

# Write the modified content
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Successfully added Variant Code Method step to Assisted Setup wizard")
