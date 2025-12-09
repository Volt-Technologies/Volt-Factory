"""
AL Code Comment Remover

Removes single-line // comments from AL code.
Preserves code on the same line, only removes the comment portion.
"""

import re
from pathlib import Path


def remove_comments_from_line(line: str) -> str | None:
    """
    Remove // comments from a line.
    Returns None if the entire line should be removed (comment-only line).
    Returns the modified line otherwise.
    """
    # Check if line is inside a string before removing comments
    # We need to be careful not to remove // inside string literals

    result = []
    i = 0
    in_string = False

    while i < len(line):
        char = line[i]

        # Handle single-quoted strings (AL string literals)
        if char == "'" and not in_string:
            in_string = True
            result.append(char)
            i += 1
            continue
        elif char == "'" and in_string:
            # Check for escaped quote ''
            if i + 1 < len(line) and line[i + 1] == "'":
                result.append("''")
                i += 2
                continue
            else:
                in_string = False
                result.append(char)
                i += 1
                continue

        # Check for // comment (only if not in string)
        if not in_string and char == '/' and i + 1 < len(line) and line[i + 1] == '/':
            # Found a comment - stop here
            break

        result.append(char)
        i += 1

    result_str = ''.join(result).rstrip()

    # If the line is now empty or only whitespace, return None to indicate removal
    if not result_str.strip():
        return None

    return result_str + '\n'


def remove_comments_from_file(file_path: str, dry_run: bool = True) -> tuple[int, int]:
    """
    Remove // comments from a single AL file.

    Returns (lines_modified, lines_removed).
    """
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        lines = f.readlines()

    new_lines = []
    lines_modified = 0
    lines_removed = 0

    for line in lines:
        # Skip processing if no // in line
        if '//' not in line:
            new_lines.append(line)
            continue

        new_line = remove_comments_from_line(line)

        if new_line is None:
            # Line was comment-only, remove it
            lines_removed += 1
        elif new_line != line:
            # Line was modified (trailing comment removed)
            new_lines.append(new_line)
            lines_modified += 1
        else:
            # Line unchanged (// was inside a string)
            new_lines.append(line)

    if not dry_run and (lines_modified > 0 or lines_removed > 0):
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)

    return lines_modified, lines_removed


def process_directory(directory: str, dry_run: bool = True) -> dict:
    """
    Process all .al files in a directory recursively.
    """
    results = {}

    for al_file in Path(directory).rglob('*.al'):
        file_path = str(al_file)
        modified, removed = remove_comments_from_file(file_path, dry_run=dry_run)
        if modified > 0 or removed > 0:
            results[file_path] = (modified, removed)

    return results


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Remove // comments from AL code')
    parser.add_argument('path', help='Path to AL file or directory')
    parser.add_argument('--apply', action='store_true', help='Apply changes (default is dry-run)')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show details')

    args = parser.parse_args()

    path = Path(args.path)
    dry_run = not args.apply

    if dry_run:
        print("=== DRY RUN MODE (use --apply to make changes) ===\n")
    else:
        print("=== APPLYING CHANGES ===\n")

    if path.is_file():
        modified, removed = remove_comments_from_file(str(path), dry_run=dry_run)
        print(f"{path}: {modified} lines modified, {removed} lines removed")
    else:
        results = process_directory(str(path), dry_run=dry_run)

        total_modified = 0
        total_removed = 0

        for file_path, (modified, removed) in results.items():
            total_modified += modified
            total_removed += removed
            print(f"{file_path}: {modified} modified, {removed} removed")

        print(f"\n{'Would modify' if dry_run else 'Modified'} {total_modified} lines")
        print(f"{'Would remove' if dry_run else 'Removed'} {total_removed} comment-only lines")
        print(f"Across {len(results)} files")


if __name__ == '__main__':
    main()
