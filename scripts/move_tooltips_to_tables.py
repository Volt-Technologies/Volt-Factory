#!/usr/bin/env python3
"""
AL ToolTip Migration Script

This script:
1. Removes ToolTip properties from fields in Page and PageExtension objects
2. Adds those tooltips to the corresponding fields in Table objects (if they don't already have one)

Usage:
    python move_tooltips_to_tables.py <path_to_bc_folder>

Example:
    python move_tooltips_to_tables.py ./BC
"""

import os
import re
import sys
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class FieldTooltip:
    """Represents a tooltip extracted from a page field."""
    field_name: str
    tooltip: str
    source_file: str
    source_table: Optional[str] = None


def find_al_files(base_path: str) -> Dict[str, List[str]]:
    """Find all AL files categorized by type."""
    files = {
        'pages': [],
        'pageextensions': [],
        'tables': [],
        'tableextensions': []
    }

    for root, _, filenames in os.walk(base_path):
        for filename in filenames:
            if not filename.endswith('.al'):
                continue

            filepath = os.path.join(root, filename)

            # Categorize by filename pattern or content
            lower_name = filename.lower()
            if '.pag-ext' in lower_name or 'pageext' in lower_name:
                files['pageextensions'].append(filepath)
            elif '.pag' in lower_name or 'page' in lower_name:
                files['pages'].append(filepath)
            elif '.tab-ext' in lower_name or 'tableext' in lower_name:
                files['tableextensions'].append(filepath)
            elif '.tab' in lower_name or 'table' in lower_name:
                files['tables'].append(filepath)
            else:
                # Check content to determine type
                try:
                    with open(filepath, 'r', encoding='utf-8-sig') as f:
                        content = f.read(500)
                        if re.match(r'\s*pageextension\s+', content, re.IGNORECASE):
                            files['pageextensions'].append(filepath)
                        elif re.match(r'\s*page\s+\d+', content, re.IGNORECASE):
                            files['pages'].append(filepath)
                        elif re.match(r'\s*tableextension\s+', content, re.IGNORECASE):
                            files['tableextensions'].append(filepath)
                        elif re.match(r'\s*table\s+\d+', content, re.IGNORECASE):
                            files['tables'].append(filepath)
                except Exception:
                    pass

    return files


def extract_source_table_from_page(content: str) -> Optional[str]:
    """Extract the SourceTable property from a page definition."""
    match = re.search(r'SourceTable\s*=\s*([^;]+);', content, re.IGNORECASE)
    if match:
        table_name = match.group(1).strip().strip('"\'')
        return table_name
    return None


def extract_tooltips_from_page(filepath: str) -> List[FieldTooltip]:
    """Extract all field tooltips from a page or pageextension file."""
    tooltips = []

    try:
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            content = f.read()
    except Exception as e:
        print(f"  Warning: Could not read {filepath}: {e}")
        return tooltips

    source_table = extract_source_table_from_page(content)

    # Find all field blocks with tooltips
    # Pattern to match field definitions in pages
    field_pattern = re.compile(
        r'field\s*\(\s*["\']?([^;"\')]+)["\']?\s*;\s*Rec\.(["\']?[^")]+["\']?)\s*\)\s*\{([^}]*(?:\{[^}]*\}[^}]*)*)\}',
        re.IGNORECASE | re.DOTALL
    )

    for match in field_pattern.finditer(content):
        field_block = match.group(3)
        rec_field = match.group(2).strip().strip('"\'')

        # Check if this field has a ToolTip
        tooltip_match = re.search(r"ToolTip\s*=\s*'([^']+)'", field_block)
        if not tooltip_match:
            tooltip_match = re.search(r'ToolTip\s*=\s*"([^"]+)"', field_block)

        if tooltip_match:
            tooltip = tooltip_match.group(1)
            tooltips.append(FieldTooltip(
                field_name=rec_field,
                tooltip=tooltip,
                source_file=filepath,
                source_table=source_table
            ))

    return tooltips


def remove_tooltips_from_page(filepath: str) -> Tuple[bool, int]:
    """
    Remove ToolTip properties from fields in a page file.
    Returns (modified, count) tuple.
    """
    try:
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            content = f.read()
    except Exception as e:
        print(f"  Warning: Could not read {filepath}: {e}")
        return False, 0

    original_content = content

    # Remove entire ToolTip lines (including the whole line with proper newline handling)
    # Pattern matches full lines: <whitespace>ToolTip = 'text';<newline>
    patterns = [
        r"^[ \t]*ToolTip\s*=\s*'[^']*';\s*\r?\n",
        r'^[ \t]*ToolTip\s*=\s*"[^"]*";\s*\r?\n',
    ]

    count = 0
    for pattern in patterns:
        matches = re.findall(pattern, content, re.MULTILINE)
        count += len(matches)
        content = re.sub(pattern, '', content, flags=re.MULTILINE)

    # Clean up multiple consecutive empty lines (more than 2 newlines in a row)
    content = re.sub(r'\n{3,}', '\n\n', content)

    if content != original_content:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True, count
        except Exception as e:
            print(f"  Warning: Could not write {filepath}: {e}")
            return False, 0

    return False, 0


def add_tooltips_to_table(filepath: str, tooltips: Dict[str, str]) -> Tuple[bool, int]:
    """
    Add tooltips to fields in a table file that don't have them.
    Returns (modified, count) tuple.
    """
    try:
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"  Warning: Could not read {filepath}: {e}")
        return False, 0

    modified = False
    count = 0
    result_lines = []

    in_fields_section = False
    current_field_name = None
    current_field_has_tooltip = False
    brace_depth = 0
    field_start_depth = 0
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Check if we're entering the fields section
        if stripped == 'fields':
            in_fields_section = True
            result_lines.append(line)
            i += 1
            continue

        # Count braces
        open_count = line.count('{')
        close_count = line.count('}')

        # Detect field start in a table: field(N; "Field Name"; Type)
        if in_fields_section:
            field_match = re.search(r'field\s*\(\s*\d+\s*;\s*["\']?([^;"\']+)["\']?\s*;', line)
            if field_match and current_field_name is None:
                current_field_name = field_match.group(1).strip()
                current_field_has_tooltip = False
                field_start_depth = brace_depth + open_count

        # Check for tooltip in current line if we're in a field
        if current_field_name and 'ToolTip' in line:
            current_field_has_tooltip = True

        brace_depth += open_count - close_count

        # Check if we're closing the current field
        if current_field_name and close_count > 0 and brace_depth < field_start_depth:
            # Field is closing
            field_name = current_field_name
            has_tooltip = current_field_has_tooltip

            # Check if we should add a tooltip
            if not has_tooltip and field_name in tooltips:
                # Insert tooltip before the closing brace
                # Determine indentation
                indent_match = re.match(r'^(\s*)', line)
                base_indent = indent_match.group(1) if indent_match else ''
                property_indent = base_indent + '    '  # Add 4 spaces

                tooltip_line = f"{property_indent}ToolTip = '{tooltips[field_name]}';\n"
                result_lines.append(tooltip_line)
                count += 1
                modified = True

            current_field_name = None
            current_field_has_tooltip = False

        # Check if we're leaving the fields section
        if in_fields_section and brace_depth <= 0 and '}' in stripped and 'fields' not in stripped.lower():
            in_fields_section = False

        result_lines.append(line)
        i += 1

    if modified:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(result_lines)
            return True, count
        except Exception as e:
            print(f"  Warning: Could not write {filepath}: {e}")
            return False, 0

    return False, 0


def get_table_name_from_file(filepath: str) -> Optional[str]:
    """Extract the table name from a table file."""
    try:
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            content = f.read(1000)

        # Pattern: table 70100 VOLColor or table 70100 "VOL Color"
        match = re.search(r'table\s+\d+\s+["\']?([^"\'\n{]+)["\']?', content, re.IGNORECASE)
        if match:
            return match.group(1).strip()
    except Exception:
        pass
    return None


def main(base_path: str):
    """Main function to migrate tooltips from pages to tables."""
    print(f"Scanning AL files in: {base_path}")
    print("=" * 60)

    # Find all AL files
    files = find_al_files(base_path)

    print(f"Found {len(files['pages'])} page files")
    print(f"Found {len(files['pageextensions'])} pageextension files")
    print(f"Found {len(files['tables'])} table files")
    print(f"Found {len(files['tableextensions'])} tableextension files")
    print()

    # Build table name to file mapping
    table_files = {}
    for filepath in files['tables']:
        table_name = get_table_name_from_file(filepath)
        if table_name:
            table_files[table_name.lower()] = filepath

    # Extract tooltips from pages and pageextensions
    all_tooltips: List[FieldTooltip] = []

    print("Extracting tooltips from pages...")
    for filepath in files['pages'] + files['pageextensions']:
        tooltips = extract_tooltips_from_page(filepath)
        if tooltips:
            print(f"  {os.path.basename(filepath)}: {len(tooltips)} tooltips found")
            all_tooltips.extend(tooltips)

    print(f"\nTotal tooltips extracted: {len(all_tooltips)}")
    print()

    # Group tooltips by source table
    tooltips_by_table: Dict[str, Dict[str, str]] = {}
    for tt in all_tooltips:
        if tt.source_table:
            table_key = tt.source_table.lower()
            if table_key not in tooltips_by_table:
                tooltips_by_table[table_key] = {}
            # Don't overwrite if already exists (first one wins)
            if tt.field_name not in tooltips_by_table[table_key]:
                tooltips_by_table[table_key][tt.field_name] = tt.tooltip

    # Add tooltips to tables
    print("Adding tooltips to tables...")
    tables_modified = 0
    tooltips_added = 0

    for table_name, tooltip_dict in tooltips_by_table.items():
        if table_name in table_files:
            filepath = table_files[table_name]
            modified, count = add_tooltips_to_table(filepath, tooltip_dict)
            if modified:
                print(f"  {os.path.basename(filepath)}: {count} tooltips added")
                tables_modified += 1
                tooltips_added += count

    print(f"\nTables modified: {tables_modified}")
    print(f"Tooltips added to tables: {tooltips_added}")
    print()

    # Remove tooltips from pages
    print("Removing tooltips from pages...")
    pages_modified = 0
    tooltips_removed = 0

    for filepath in files['pages'] + files['pageextensions']:
        modified, count = remove_tooltips_from_page(filepath)
        if modified:
            print(f"  {os.path.basename(filepath)}: {count} tooltips removed")
            pages_modified += 1
            tooltips_removed += count

    print(f"\nPages modified: {pages_modified}")
    print(f"Tooltips removed from pages: {tooltips_removed}")
    print()

    print("=" * 60)
    print("Migration complete!")
    print(f"  - {tooltips_added} tooltips added to tables")
    print(f"  - {tooltips_removed} tooltips removed from pages")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python move_tooltips_to_tables.py <path_to_bc_folder>")
        print("Example: python move_tooltips_to_tables.py ./BC")
        sys.exit(1)

    base_path = sys.argv[1]

    if not os.path.isdir(base_path):
        print(f"Error: {base_path} is not a valid directory")
        sys.exit(1)

    main(base_path)
