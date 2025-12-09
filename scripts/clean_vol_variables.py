"""
AL Code Variable Name Cleaner

This script removes the 'VOL' prefix from variable names in AL code declarations
AND updates all references to those variables within their scope.

Example transformations:
- VOLSizeRange: Record VOLSizeRange; → SizeRange: Record VOLSizeRange;
- All usages of VOLSizeRange in scope → SizeRange
"""

import re
import os
from pathlib import Path
from dataclasses import dataclass
from typing import Optional

# AL types that can have VOL-prefixed variables
AL_TYPES = r'Record|Codeunit|Page|Report|Query|Xmlport|Enum|Interface|TestPage|TestRequestPage'

@dataclass
class VariableRename:
    old_name: str
    new_name: str
    line_declared: int
    scope_start: int  # Line where scope starts (procedure/trigger start or var block)
    scope_end: int    # Line where scope ends

def find_procedure_boundaries(lines: list[str]) -> list[tuple[int, int]]:
    """
    Find all procedure/trigger boundaries in AL code.
    Returns list of (start_line, end_line) tuples (1-indexed).
    """
    boundaries = []

    # Pattern for procedure/trigger starts
    proc_pattern = re.compile(
        r'^\s*(local\s+|internal\s+)?(procedure|trigger)\s+',
        re.IGNORECASE
    )

    i = 0
    while i < len(lines):
        line = lines[i]
        if proc_pattern.match(line):
            start = i + 1  # 1-indexed
            # Find matching end
            begin_count = 0
            found_begin = False
            j = i
            while j < len(lines):
                # Count begin/end keywords (not in strings)
                clean_line = remove_strings(lines[j])

                # Look for 'begin' keyword
                begins = len(re.findall(r'\bbegin\b', clean_line, re.IGNORECASE))
                if begins > 0:
                    found_begin = True
                    begin_count += begins

                # Look for 'end' keyword
                ends = len(re.findall(r'\bend\b', clean_line, re.IGNORECASE))
                begin_count -= ends

                # Procedure ends when we've found a begin and then balanced back to 0
                if found_begin and begin_count == 0:
                    boundaries.append((start, j + 1))
                    break
                j += 1
            i = j + 1
        else:
            i += 1

    return boundaries


def remove_strings(line: str) -> str:
    """Remove string literals from a line to avoid matching keywords inside strings."""
    # Remove single-quoted strings
    result = re.sub(r"'[^']*'", "''", line)
    return result


def find_var_declarations(lines: list[str], scope_start: int, scope_end: int) -> list[VariableRename]:
    """
    Find VOL-prefixed variable declarations within a scope.
    This includes both procedure parameters and local variables.
    scope_start and scope_end are 1-indexed line numbers.
    """
    renames = []

    # Pattern for variable declarations (including procedure parameters)
    # Matches: VOLName: Record|Codeunit|etc TypeName
    # Also matches: var VOLName: Record|Codeunit|etc TypeName (for var parameters)
    var_pattern = re.compile(
        rf'\b(VOL)(\w+)(\s*:\s*)({AL_TYPES})(\s+)',
        re.IGNORECASE
    )

    in_procedure_sig = True  # Start in procedure signature
    in_var_block = False

    for i in range(scope_start - 1, min(scope_end, len(lines))):
        line = lines[i]
        clean_line = remove_strings(line)

        # Check for var keyword (entering var block)
        if re.match(r'^\s*var\s*$', clean_line, re.IGNORECASE):
            in_var_block = True
            in_procedure_sig = False
            continue

        # Check if we're past the 'begin' keyword (no more var declarations)
        if re.search(r'\bbegin\b', clean_line, re.IGNORECASE):
            break

        # Check if we're exiting procedure signature (hit 'var' block or directly 'begin')
        if in_procedure_sig and re.match(r'^\s*var\s*$', clean_line, re.IGNORECASE):
            in_procedure_sig = False
            in_var_block = True

        # Look for VOL-prefixed variables in procedure signature or var block
        for match in var_pattern.finditer(line):
            old_name = match.group(1) + match.group(2)  # VOL + rest
            new_name = match.group(2)  # Just the rest (without VOL)

            renames.append(VariableRename(
                old_name=old_name,
                new_name=new_name,
                line_declared=i + 1,  # 1-indexed
                scope_start=scope_start,
                scope_end=scope_end
            ))

    return renames


def find_global_var_declarations(lines: list[str], proc_boundaries: list[tuple[int, int]]) -> list[VariableRename]:
    """
    Find VOL-prefixed variable declarations in global var blocks.
    These are var declarations outside of any procedure.
    """
    renames = []

    # Pattern for variable declarations
    var_pattern = re.compile(
        rf'\b(VOL)(\w+)(\s*:\s*)({AL_TYPES})(\s+)',
        re.IGNORECASE
    )

    # Find global var sections (outside procedures)
    in_procedure = False
    in_var_section = False

    for i, line in enumerate(lines):
        line_num = i + 1  # 1-indexed

        # Check if we're inside a procedure
        in_procedure = any(start <= line_num <= end for start, end in proc_boundaries)

        if in_procedure:
            continue

        # Check for var keyword
        if re.match(r'^\s*var\s*$', line, re.IGNORECASE):
            in_var_section = True
            continue

        # End of var section when we hit a non-var-like line (procedure, trigger, etc.)
        if in_var_section:
            if re.match(r'^\s*(local\s+|internal\s+)?(procedure|trigger)\s+', line, re.IGNORECASE):
                in_var_section = False
                continue

        if in_var_section:
            for match in var_pattern.finditer(line):
                old_name = match.group(1) + match.group(2)
                new_name = match.group(2)

                # Global scope is entire file
                renames.append(VariableRename(
                    old_name=old_name,
                    new_name=new_name,
                    line_declared=line_num,
                    scope_start=1,
                    scope_end=len(lines)
                ))

    return renames


def replace_variable_references(lines: list[str], renames: list[VariableRename]) -> list[str]:
    """
    Replace all variable references within their scopes.
    Process all applicable renames for each line to handle multiple variables on the same line.
    """
    new_lines = list(lines)

    for i in range(len(new_lines)):
        line_num = i + 1  # 1-indexed

        # Find all renames applicable to this line
        applicable_renames = [
            r for r in renames
            if r.scope_start <= line_num <= r.scope_end
        ]

        if not applicable_renames:
            continue

        # Apply all renames to this line
        line = new_lines[i]
        for rename in applicable_renames:
            line = replace_in_code_only(line, rename.old_name, rename.new_name)
        new_lines[i] = line

    return new_lines


def replace_in_code_only(line: str, old_name: str, new_name: str) -> str:
    """
    Replace variable name only in code portions, not inside strings or quoted type names.
    """
    # Find all single-quoted string positions (AL string literals)
    string_positions = []
    i = 0
    while i < len(line):
        if line[i] == "'":
            start = i
            i += 1
            while i < len(line):
                if line[i] == "'":
                    if i + 1 < len(line) and line[i + 1] == "'":
                        # Escaped quote
                        i += 2
                    else:
                        # End of string
                        string_positions.append((start, i))
                        break
                i += 1
        i += 1

    # Find all double-quoted identifier positions (AL quoted identifiers like "My Table")
    dquote_positions = []
    i = 0
    while i < len(line):
        if line[i] == '"':
            start = i
            i += 1
            while i < len(line):
                if line[i] == '"':
                    dquote_positions.append((start, i))
                    break
                i += 1
        i += 1

    # Now replace, avoiding strings and quoted type references
    result = []
    last_end = 0

    pattern = re.compile(rf'\b{re.escape(old_name)}\b', re.IGNORECASE)

    for match in pattern.finditer(line):
        match_start = match.start()
        match_end = match.end()

        # Skip if inside a single-quoted string literal
        in_str = any(start <= match_start <= end for start, end in string_positions)
        if in_str:
            continue

        # Skip if inside a double-quoted identifier (type name)
        in_dquote = any(start < match_start and match_end <= end for start, end in dquote_positions)
        if in_dquote:
            continue

        # Check if this is a type reference (after Record, Codeunit, etc.)
        before = line[:match_start].rstrip()
        if re.search(rf'\b({AL_TYPES})\s*"?\s*$', before, re.IGNORECASE):
            # This is a type reference, don't replace
            continue

        # Replace this occurrence
        # Preserve original case pattern
        matched_text = match.group()
        if matched_text[0:3].isupper():
            replacement = new_name[0].upper() + new_name[1:]
        elif matched_text[0:3].islower():
            replacement = new_name[0].lower() + new_name[1:]
        else:
            replacement = new_name

        result.append(line[last_end:match_start])
        result.append(replacement)
        last_end = match_end

    result.append(line[last_end:])
    return ''.join(result)


def clean_vol_variables_in_file(file_path: str, dry_run: bool = True) -> tuple[list[tuple[str, str, int]], int]:
    """
    Clean VOL prefixes from variable names in a single AL file.

    Returns a tuple of (list of (old_line, new_line, line_number), total_replacements).
    """
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        lines = f.readlines()

    # Find procedure boundaries
    proc_boundaries = find_procedure_boundaries(lines)

    # Collect all renames needed
    all_renames = []

    # Find local variables in each procedure
    for start, end in proc_boundaries:
        renames = find_var_declarations(lines, start, end)
        all_renames.extend(renames)

    # Find global variables
    global_renames = find_global_var_declarations(lines, proc_boundaries)
    all_renames.extend(global_renames)

    if not all_renames:
        return [], 0

    # Apply all renames
    new_lines = replace_variable_references(lines, all_renames)

    # Calculate changes
    changes = []
    total_replacements = 0
    for i, (old, new) in enumerate(zip(lines, new_lines)):
        if old != new:
            changes.append((old.rstrip(), new.rstrip(), i + 1))
            # Count actual replacements in the line
            # This is approximate but gives a sense of scale
            total_replacements += 1

    if not dry_run and changes:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)

    return changes, len(all_renames)


def process_directory(directory: str, dry_run: bool = True) -> dict:
    """
    Process all .al files in a directory recursively.

    Returns a dict with file paths and their changes.
    """
    results = {}
    total_vars = 0

    for al_file in Path(directory).rglob('*.al'):
        file_path = str(al_file)
        changes, var_count = clean_vol_variables_in_file(file_path, dry_run=dry_run)
        total_vars += var_count
        if changes:
            results[file_path] = changes

    return results, total_vars


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Clean VOL prefixes from AL variable names')
    parser.add_argument('path', help='Path to AL file or directory')
    parser.add_argument('--apply', action='store_true', help='Apply changes (default is dry-run)')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show all changes')
    parser.add_argument('--limit', type=int, default=0, help='Limit output lines per file')

    args = parser.parse_args()

    path = Path(args.path)
    dry_run = not args.apply

    if dry_run:
        print("=== DRY RUN MODE (use --apply to make changes) ===\n")
    else:
        print("=== APPLYING CHANGES ===\n")

    if path.is_file():
        changes, var_count = clean_vol_variables_in_file(str(path), dry_run=dry_run)
        if changes:
            print(f"\n{path} ({var_count} variables to rename):")
            for i, (old, new, line_num) in enumerate(changes):
                if args.limit and i >= args.limit:
                    print(f"  ... and {len(changes) - args.limit} more changes")
                    break
                print(f"  Line {line_num}:")
                print(f"    - {old}")
                print(f"    + {new}")
        else:
            print(f"No changes needed in {path}")
    else:
        results, total_vars = process_directory(str(path), dry_run=dry_run)

        total_changes = 0
        for file_path, changes in results.items():
            total_changes += len(changes)
            if args.verbose:
                print(f"\n{file_path}:")
                for i, (old, new, line_num) in enumerate(changes):
                    if args.limit and i >= args.limit:
                        print(f"  ... and {len(changes) - args.limit} more changes")
                        break
                    print(f"  Line {line_num}:")
                    print(f"    - {old}")
                    print(f"    + {new}")
            else:
                print(f"{file_path}: {len(changes)} line changes")

        print(f"\n{'Would rename' if dry_run else 'Renamed'} {total_vars} variables")
        print(f"{'Would modify' if dry_run else 'Modified'} {total_changes} lines in {len(results)} files")


if __name__ == '__main__':
    main()
