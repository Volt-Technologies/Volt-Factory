#!/usr/bin/env python3
"""
AL Object Renumbering Script for Business Central Extensions

This script renumbers AL objects in the BC folder according to the ranges defined
in FeatureRanges.json. It also renames files to include the new object number and
renumbers field IDs in tables and table extensions.

Note: Object IDs are assigned per object type, meaning you can have both
codeunit 70000 and page 70000 (they don't conflict).

Usage:
    python renumber_al_objects.py [--dry-run] [--verbose]

Options:
    --dry-run   Show what would be changed without making actual changes
    --verbose   Show detailed output
"""

import os
import re
import sys
import json
import argparse
from pathlib import Path
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional
from collections import defaultdict


@dataclass
class FeatureRange:
    """Represents a feature's object ID range"""
    name: str
    start: int
    end: int


@dataclass
class ALObject:
    """Represents an AL object found in a file"""
    file_path: Path
    object_type: str  # table, tableextension, page, pageextension, codeunit, enum, enumextension, report, etc.
    object_id: int
    object_name: str
    content: str
    feature: str  # Which feature folder it belongs to
    fields: List[Tuple[int, str]] = field(default_factory=list)  # List of (field_id, field_name) for tables/tableexts


# Object type patterns for parsing AL files
OBJECT_TYPE_PATTERNS = {
    "table": r"^table\s+(\d+)\s+\"?([^\"]+)\"?",
    "tableextension": r"^tableextension\s+(\d+)\s+\"?([^\"]+)\"?\s+extends",
    "page": r"^page\s+(\d+)\s+\"?([^\"]+)\"?",
    "pageextension": r"^pageextension\s+(\d+)\s+\"?([^\"]+)\"?\s+extends",
    "codeunit": r"^codeunit\s+(\d+)\s+\"?([^\"]+)\"?",
    "enum": r"^enum\s+(\d+)\s+\"?([^\"]+)\"?",
    "enumextension": r"^enumextension\s+(\d+)\s+\"?([^\"]+)\"?\s+extends",
    "report": r"^report\s+(\d+)\s+\"?([^\"]+)\"?",
    "reportextension": r"^reportextension\s+(\d+)\s+\"?([^\"]+)\"?\s+extends",
    "query": r"^query\s+(\d+)\s+\"?([^\"]+)\"?",
    "xmlport": r"^xmlport\s+(\d+)\s+\"?([^\"]+)\"?",
    "permissionset": r"^permissionset\s+(\d+)\s+\"?([^\"]+)\"?",
    "permissionsetextension": r"^permissionsetextension\s+(\d+)\s+\"?([^\"]+)\"?\s+extends",
    "interface": r"^interface\s+\"?([^\"]+)\"?",  # Interfaces don't have IDs
    "controladdin": r"^controladdin\s+\"?([^\"]+)\"?",  # Control add-ins don't have IDs
}

# File extension patterns for different object types
FILE_EXTENSION_MAP = {
    "table": ".Tab",
    "tableextension": ".Tab-Ext",
    "page": ".Pag",
    "pageextension": ".Pag-Ext",
    "codeunit": ".Cod",
    "enum": ".Enum",
    "enumextension": ".Enum-Ext",
    "report": ".Rep",
    "reportextension": ".Rep-Ext",
    "query": ".Que",
    "xmlport": ".Xml",
    "permissionset": ".Perm",
    "permissionsetextension": ".Perm-Ext",
}


def parse_feature_ranges(ranges_file: Path) -> Dict[str, FeatureRange]:
    """Parse FeatureRanges.json to extract feature ranges"""
    ranges = {}

    if not ranges_file.exists():
        print(f"Error: FeatureRanges.json not found at {ranges_file}")
        sys.exit(1)

    with open(ranges_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    for name, range_data in data.items():
        ranges[name] = FeatureRange(
            name=name,
            start=range_data["start"],
            end=range_data["end"]
        )

    return ranges


def detect_feature_from_path(file_path: Path, bc_folder: Path) -> Optional[str]:
    """Detect which feature a file belongs to based on its path"""
    try:
        rel_path = file_path.relative_to(bc_folder / "src")
        parts = rel_path.parts
        if len(parts) >= 1:
            return parts[0]  # First folder under src/
    except ValueError:
        pass
    return None


def parse_al_file(file_path: Path, bc_folder: Path) -> Optional[ALObject]:
    """Parse an AL file to extract object information"""
    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            content = f.read()
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}")
        return None

    # Try to match each object type pattern
    for obj_type, pattern in OBJECT_TYPE_PATTERNS.items():
        match = re.search(pattern, content, re.MULTILINE | re.IGNORECASE)
        if match:
            # Handle objects without IDs (interface, controladdin)
            if obj_type in ("interface", "controladdin"):
                return None  # Skip these for renumbering

            object_id = int(match.group(1))
            object_name = match.group(2).strip().strip('"')
            feature = detect_feature_from_path(file_path, bc_folder)

            al_object = ALObject(
                file_path=file_path,
                object_type=obj_type,
                object_id=object_id,
                object_name=object_name,
                content=content,
                feature=feature,
                fields=[]
            )

            # Extract fields for tables and table extensions
            if obj_type in ("table", "tableextension"):
                al_object.fields = extract_fields(content)

            return al_object

    return None


def extract_fields(content: str) -> List[Tuple[int, str]]:
    """Extract field definitions from table/tableextension content"""
    fields = []
    # Match field(id; "name") or field(id; name)
    field_pattern = r"field\s*\(\s*(\d+)\s*;\s*\"?([^;\"]+)\"?\s*;"
    matches = re.findall(field_pattern, content, re.IGNORECASE)
    for field_id, field_name in matches:
        fields.append((int(field_id), field_name.strip()))
    return fields


def generate_new_filename(obj: ALObject, new_id: int) -> str:
    """Generate a new filename with the new object ID"""
    ext_suffix = FILE_EXTENSION_MAP.get(obj.object_type, "")

    # Extract the base name without the current ID and extension
    current_filename = obj.file_path.stem  # filename without .al

    # Try to find existing ID pattern in filename
    # Patterns like: VOLName.Tab70000, VOLName.Pag-Ext70000, etc.
    id_pattern = r"(\d+)$"

    # Check if the filename already has an ID at the end
    match = re.search(id_pattern, current_filename)
    if match:
        # Replace existing ID
        base_name = current_filename[:match.start()]
    else:
        # Check for pattern like VOLName.Tab or VOLName.Pag-Ext (without ID)
        # Find the extension suffix position
        for suffix in sorted(FILE_EXTENSION_MAP.values(), key=len, reverse=True):
            if current_filename.endswith(suffix) or suffix in current_filename:
                idx = current_filename.find(suffix)
                if idx != -1:
                    base_name = current_filename[:idx + len(suffix)]
                    break
        else:
            # No suffix found, just use the current name
            base_name = current_filename

    # Ensure the base_name ends with the correct extension suffix
    if not base_name.endswith(ext_suffix):
        # Remove any existing suffix and add the correct one
        for suffix in FILE_EXTENSION_MAP.values():
            if base_name.endswith(suffix):
                base_name = base_name[:-len(suffix)]
                break
        base_name += ext_suffix

    return f"{base_name}{new_id}.al"


def renumber_object_content(content: str, obj_type: str, old_id: int, new_id: int) -> str:
    """Replace the object ID in the file content"""
    # Pattern to match the object declaration
    if obj_type == "tableextension":
        pattern = rf"^(tableextension\s+){old_id}(\s+)"
    elif obj_type == "pageextension":
        pattern = rf"^(pageextension\s+){old_id}(\s+)"
    elif obj_type == "enumextension":
        pattern = rf"^(enumextension\s+){old_id}(\s+)"
    elif obj_type == "reportextension":
        pattern = rf"^(reportextension\s+){old_id}(\s+)"
    elif obj_type == "permissionsetextension":
        pattern = rf"^(permissionsetextension\s+){old_id}(\s+)"
    else:
        pattern = rf"^({obj_type}\s+){old_id}(\s+)"

    replacement = rf"\g<1>{new_id}\g<2>"
    return re.sub(pattern, replacement, content, count=1, flags=re.MULTILINE | re.IGNORECASE)


def renumber_fields(content: str, object_new_id: int, is_extension: bool = False) -> Tuple[str, Dict[int, int]]:
    """
    Renumber field IDs in table/tableextension content.
    Returns the modified content and a mapping of old_id -> new_id.

    For tables: fields use simple sequential IDs (1, 2, 3, ...)
    For tableextensions: fields use object_id as base (e.g., object 70100 -> fields 70100, 70101, 70102, ...)
    """
    field_mapping = {}

    # Find all fields
    field_pattern = r"(field\s*\(\s*)(\d+)(\s*;\s*)"

    # First pass: collect all field IDs and create mapping
    matches = list(re.finditer(field_pattern, content, re.IGNORECASE))

    if not matches:
        return content, field_mapping

    # Calculate the base for field IDs
    if is_extension:
        # For extensions: use object_id as base (70100, 70101, 70102, ...)
        field_base = object_new_id
    else:
        # For tables: use simple sequential (1, 2, 3, ...)
        field_base = 0

    # Assign new IDs sequentially
    for i, match in enumerate(matches):
        old_id = int(match.group(2))
        new_id = field_base + i + 1  # Start from field_base + 1
        if old_id != new_id:
            field_mapping[old_id] = new_id

    # Second pass: replace field IDs (in reverse order to avoid position shifts)
    new_content = content
    for match in reversed(matches):
        old_id = int(match.group(2))
        if old_id in field_mapping:
            new_id = field_mapping[old_id]
            start = match.start(2)
            end = match.end(2)
            new_content = new_content[:start] + str(new_id) + new_content[end:]

    return new_content, field_mapping


def renumber_enum_values(content: str, object_new_id: int, is_extension: bool = False) -> Tuple[str, Dict[int, int]]:
    """
    Renumber value IDs in enum/enumextension content.
    Returns the modified content and a mapping of old_id -> new_id.

    For enums: values use simple sequential IDs (0, 1, 2, ...)
    For enumextensions: values use object_id as base (e.g., object 70100 -> values 70100, 70101, ...)
    """
    value_mapping = {}

    # Find all value definitions: value(id; "name") or value(id; name)
    value_pattern = r"(value\s*\(\s*)(\d+)(\s*;\s*)"

    # First pass: collect all value IDs and create mapping
    matches = list(re.finditer(value_pattern, content, re.IGNORECASE))

    if not matches:
        return content, value_mapping

    # Calculate the base for value IDs
    if is_extension:
        # For extensions: use object_id as base (70100, 70101, ...)
        value_base = object_new_id
        start_offset = 0  # Start from base itself
    else:
        # For enums: use simple sequential starting at 0
        value_base = -1  # So first value is 0
        start_offset = 1

    # Assign new IDs sequentially
    for i, match in enumerate(matches):
        old_id = int(match.group(2))
        new_id = value_base + i + start_offset
        if old_id != new_id:
            value_mapping[old_id] = new_id

    # Second pass: replace value IDs (in reverse order to avoid position shifts)
    new_content = content
    for match in reversed(matches):
        old_id = int(match.group(2))
        if old_id in value_mapping:
            new_id = value_mapping[old_id]
            start = match.start(2)
            end = match.end(2)
            new_content = new_content[:start] + str(new_id) + new_content[end:]

    return new_content, value_mapping


def organize_objects_by_feature_and_type(objects: List[ALObject]) -> Dict[str, Dict[str, List[ALObject]]]:
    """Organize objects by feature and object type"""
    organized = defaultdict(lambda: defaultdict(list))

    for obj in objects:
        if obj.feature:
            organized[obj.feature][obj.object_type].append(obj)

    return organized


def calculate_new_ids(
    organized_objects: Dict[str, Dict[str, List[ALObject]]],
    feature_ranges: Dict[str, FeatureRange],
    sort_alphabetically: bool = False
) -> Tuple[Dict[Path, Tuple[ALObject, int]], List[str]]:
    """
    Calculate new IDs for all objects based on feature ranges.
    IDs are assigned per object type (codeunit 70000 and page 70000 can coexist).

    Args:
        organized_objects: Objects organized by feature and type
        feature_ranges: Feature range definitions
        sort_alphabetically: If True, sort by object name; otherwise sort by current ID

    Returns a tuple of:
    - mapping of file_path -> (ALObject, new_id)
    - list of error messages
    """
    new_id_map = {}
    errors = []

    for feature_name, feature_objects in organized_objects.items():
        if feature_name not in feature_ranges:
            errors.append(f"Warning: No range defined for feature '{feature_name}'")
            continue

        feature_range = feature_ranges[feature_name]

        # Process each object type separately - IDs are per object type
        for obj_type, type_objects in feature_objects.items():
            # Check if we have enough IDs for this object type
            available_ids = feature_range.end - feature_range.start + 1
            if len(type_objects) > available_ids:
                errors.append(
                    f"Error: Feature '{feature_name}' has {len(type_objects)} {obj_type} objects but only "
                    f"{available_ids} IDs available ({feature_range.start}-{feature_range.end}). "
                    f"Consider expanding the range in FeatureRanges.json."
                )

            # Sort objects: alphabetically by name, or by current ID for consistent ordering
            if sort_alphabetically:
                sorted_objects = sorted(type_objects, key=lambda x: x.object_name.lower())
            else:
                sorted_objects = sorted(type_objects, key=lambda x: x.object_id)

            # Assign new IDs for this object type starting from feature range start
            current_id = feature_range.start

            for obj in sorted_objects:
                if current_id > feature_range.end:
                    # Don't add more objects, but still track them
                    continue

                new_id_map[obj.file_path] = (obj, current_id)
                current_id += 1

    return new_id_map, errors


def apply_changes(
    new_id_map: Dict[Path, Tuple[ALObject, int]],
    dry_run: bool = True,
    verbose: bool = False
) -> List[str]:
    """Apply the renumbering changes to files"""
    changes = []

    for file_path, (obj, new_id) in new_id_map.items():
        old_id = obj.object_id
        id_changed = old_id != new_id

        # Start with current content
        new_content = obj.content

        # Update object ID if changed
        if id_changed:
            new_content = renumber_object_content(new_content, obj.object_type, old_id, new_id)

        # Renumber fields for tables and tableextensions (always check, even if ID unchanged)
        field_changes = {}
        if obj.object_type in ("table", "tableextension"):
            is_extension = obj.object_type == "tableextension"
            new_content, field_changes = renumber_fields(new_content, new_id, is_extension)

        # Renumber enum values for enums and enumextensions (always check, even if ID unchanged)
        enum_value_changes = {}
        if obj.object_type in ("enum", "enumextension"):
            is_extension = obj.object_type == "enumextension"
            new_content, enum_value_changes = renumber_enum_values(new_content, new_id, is_extension)

        # Check if anything changed
        content_changed = new_content != obj.content

        if not content_changed:
            if verbose:
                print(f"  Skipping {file_path.name} - no changes needed")
            continue

        # Generate new filename
        new_filename = generate_new_filename(obj, new_id)
        new_file_path = file_path.parent / new_filename

        if id_changed:
            change_desc = f"[{obj.object_type}] {file_path.name} -> {new_filename} (ID: {old_id} -> {new_id})"
        else:
            change_desc = f"[{obj.object_type}] {file_path.name} (field/value renumbering only)"
        changes.append(change_desc)

        if verbose:
            print(f"  {change_desc}")
            if field_changes:
                print(f"    Field renumbering: {len(field_changes)} fields updated")
                for old_fid, new_fid in sorted(field_changes.items()):
                    print(f"      Field {old_fid} -> {new_fid}")
            if enum_value_changes:
                print(f"    Enum value renumbering: {len(enum_value_changes)} values updated")
                for old_vid, new_vid in sorted(enum_value_changes.items()):
                    print(f"      Value {old_vid} -> {new_vid}")

        if not dry_run:
            # Write new content
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)

            # Rename file if needed
            if file_path != new_file_path:
                # Handle case where new file might already exist
                if new_file_path.exists() and new_file_path != file_path:
                    # Create a temp name first
                    temp_path = file_path.with_suffix('.al.tmp')
                    file_path.rename(temp_path)
                    temp_path.rename(new_file_path)
                else:
                    file_path.rename(new_file_path)

    return changes


def main():
    parser = argparse.ArgumentParser(description='Renumber AL objects according to feature ranges')
    parser.add_argument('--dry-run', action='store_true', help='Show changes without applying them')
    parser.add_argument('--verbose', '-v', action='store_true', help='Show detailed output')
    parser.add_argument('--bc-folder', type=str, help='Path to BC folder (default: auto-detect)')
    parser.add_argument('--alphabetical', '-a', action='store_true',
                        help='Sort objects alphabetically by name before renumbering (useful for initial setup)')
    args = parser.parse_args()

    # Determine BC folder path
    if args.bc_folder:
        bc_folder = Path(args.bc_folder)
    else:
        # Try to find BC folder relative to script location
        script_dir = Path(__file__).parent
        bc_folder = script_dir.parent / "BC"
        if not bc_folder.exists():
            # Try current directory
            bc_folder = Path.cwd() / "BC"

    if not bc_folder.exists():
        print(f"Error: BC folder not found at {bc_folder}")
        sys.exit(1)

    print(f"BC Folder: {bc_folder}")
    print(f"Mode: {'DRY RUN' if args.dry_run else 'APPLY CHANGES'}")
    print("-" * 60)

    # Parse feature ranges from JSON
    ranges_file = bc_folder / "FeatureRanges.json"
    feature_ranges = parse_feature_ranges(ranges_file)

    print(f"\nFeature Ranges:")
    for name, fr in feature_ranges.items():
        print(f"  {name}: {fr.start} - {fr.end}")

    # Find all AL files
    al_files = list((bc_folder / "src").rglob("*.al"))
    print(f"\nFound {len(al_files)} AL files")

    # Parse all AL files
    objects = []
    for al_file in al_files:
        obj = parse_al_file(al_file, bc_folder)
        if obj:
            objects.append(obj)
        elif args.verbose:
            print(f"  Warning: Could not parse {al_file.name}")

    print(f"Parsed {len(objects)} AL objects")

    # Organize by feature and type
    organized = organize_objects_by_feature_and_type(objects)

    print(f"\nObjects by feature and type:")
    for feature, type_objects in organized.items():
        total = sum(len(objs) for objs in type_objects.values())
        print(f"  {feature}: {total} objects")
        for obj_type, objs in sorted(type_objects.items()):
            print(f"    {obj_type}: {len(objs)}")

    # Calculate new IDs (per object type)
    if args.alphabetical:
        print("\nSorting: ALPHABETICAL (by object name)")
    else:
        print("\nSorting: BY CURRENT ID")
    new_id_map, errors = calculate_new_ids(organized, feature_ranges, args.alphabetical)

    # Display errors
    if errors:
        print("\n" + "=" * 60)
        print("ERRORS / WARNINGS:")
        print("=" * 60)
        for error in errors:
            print(f"  {error}")
        print("=" * 60)

        # If there are actual errors (not just warnings), don't apply changes
        has_errors = any(e.startswith("Error:") for e in errors)
        if has_errors and not args.dry_run:
            print("\nCannot apply changes due to errors. Please fix the issues above.")
            print("Typically this means updating FeatureRanges.json with larger ranges.")
            return 1

    print(f"\n{'Proposed' if args.dry_run else 'Applying'} changes:")
    print("-" * 60)

    # Apply changes
    changes = apply_changes(new_id_map, args.dry_run, args.verbose)

    # Show summary in non-verbose mode
    if not args.verbose and changes:
        print(f"  (Use --verbose to see detailed changes)")

    print("-" * 60)
    print(f"Total changes: {len(changes)}")

    if args.dry_run:
        print("\nRun without --dry-run to apply changes")
        if errors:
            print("Note: Fix errors above before applying changes.")
    else:
        print("\nChanges applied successfully!")

    return 0


if __name__ == "__main__":
    sys.exit(main())
