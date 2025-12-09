"""
Fix AL keyword casing issues in .al files.
Only fixes specific patterns that are known to be incorrect casing.
"""

import os
import re
from pathlib import Path


def fix_al_casing(content: str) -> tuple[str, list[str]]:
    """
    Fix casing issues in AL code content.
    Returns tuple of (fixed_content, list_of_changes).

    Only fixes:
    - 'internal procedure' -> 'internal procedure'
    - 'Local procedure' -> 'local procedure'
    - 'REc.' -> 'Rec.' (common typo)
    - Other specific keyword casing at start of statements
    """
    changes = []
    original = content

    # Fix 'internal procedure' -> 'internal procedure'
    # Only when it's at the start of a line (with optional whitespace)
    pattern = r'^(\s*)Internal(\s+procedure\s)'
    replacement = r'\1internal\2'
    new_content, count = re.subn(pattern, replacement, content, flags=re.MULTILINE)
    if count > 0:
        changes.append(f"Internal -> internal: {count} occurrence(s)")
        content = new_content

    # Fix 'Local procedure' -> 'local procedure'
    # Only when it's at the start of a line (with optional whitespace)
    pattern = r'^(\s*)Local(\s+procedure\s)'
    replacement = r'\1local\2'
    new_content, count = re.subn(pattern, replacement, content, flags=re.MULTILINE)
    if count > 0:
        changes.append(f"Local -> local: {count} occurrence(s)")
        content = new_content

    # Fix 'REc.' -> 'Rec.' (common typo, case sensitive)
    # Be very specific - only fix this exact pattern
    pattern = r'\bREc\.'
    replacement = r'Rec.'
    new_content, count = re.subn(pattern, replacement, content)
    if count > 0:
        changes.append(f"REc. -> Rec.: {count} occurrence(s)")
        content = new_content

    # Fix 'REcord' -> 'Record' if it appears (another common typo)
    pattern = r'\bREcord\b'
    replacement = r'Record'
    new_content, count = re.subn(pattern, replacement, content)
    if count > 0:
        changes.append(f"REcord -> Record: {count} occurrence(s)")
        content = new_content

    return content, changes


def process_file(file_path: Path, dry_run: bool = False) -> tuple[bool, list[str]]:
    """
    Process a single AL file.
    Returns tuple of (was_modified, list_of_changes).
    """
    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            content = f.read()
    except UnicodeDecodeError:
        try:
            with open(file_path, 'r', encoding='latin-1') as f:
                content = f.read()
        except Exception as e:
            return False, [f"Error reading file: {e}"]

    fixed_content, changes = fix_al_casing(content)

    if changes and not dry_run:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(fixed_content)

    return bool(changes), changes


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Fix AL keyword casing issues')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be changed without modifying files')
    parser.add_argument('--path', type=str, default='.',
                        help='Path to search for .al files (default: current directory)')
    args = parser.parse_args()

    root_path = Path(args.path)

    if not root_path.exists():
        print(f"Error: Path '{root_path}' does not exist")
        return 1

    # Find all .al files
    al_files = list(root_path.rglob('*.al'))

    if not al_files:
        print(f"No .al files found in {root_path}")
        return 0

    print(f"{'[DRY RUN] ' if args.dry_run else ''}Scanning {len(al_files)} .al files...")
    print("-" * 60)

    modified_count = 0
    total_changes = 0

    for file_path in sorted(al_files):
        was_modified, changes = process_file(file_path, dry_run=args.dry_run)

        if was_modified:
            modified_count += 1
            relative_path = file_path.relative_to(root_path) if file_path.is_relative_to(root_path) else file_path
            print(f"\n{relative_path}:")
            for change in changes:
                print(f"  - {change}")
                total_changes += 1

    print("-" * 60)
    action = "Would modify" if args.dry_run else "Modified"
    print(f"{action} {modified_count} file(s) with {total_changes} total fix(es)")

    return 0


if __name__ == '__main__':
    exit(main())
