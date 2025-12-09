#!/bin/bash

# Business Central Version Increment Script
# Automatically increments the version number in app.json by 1
# Usage: bash scripts/bc-increment-version.sh [app-path]

set -e

# Determine workspace root
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default app path
APP_PATH="${1:-BC}"

# Resolve to absolute path if relative
if [[ "$APP_PATH" != /* ]]; then
    APP_PATH="$WORKSPACE_ROOT/$APP_PATH"
fi

# Check if app.json exists
APP_JSON="$APP_PATH/app.json"
if [ ! -f "$APP_JSON" ]; then
    echo "Error: app.json not found at $APP_JSON"
    exit 1
fi

echo "=== Business Central Version Increment ==="
echo ""
echo "App location: $APP_PATH"
echo ""

# Read current version using grep and cut (portable across systems)
CURRENT_VERSION=$(grep '"version"' "$APP_JSON" | head -1 | cut -d'"' -f4)

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not read version from app.json"
    exit 1
fi

echo "Current version: $CURRENT_VERSION"

# Parse version components (assumes format: major.minor.build.revision)
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"

# Get the number of version parts
NUM_PARTS=${#VERSION_PARTS[@]}

if [ $NUM_PARTS -lt 2 ]; then
    echo "Error: Invalid version format. Expected at least major.minor"
    exit 1
fi

# Increment the last component
LAST_INDEX=$((NUM_PARTS - 1))
VERSION_PARTS[$LAST_INDEX]=$((VERSION_PARTS[$LAST_INDEX] + 1))

# Reconstruct version string
NEW_VERSION="${VERSION_PARTS[0]}"
for (( i=1; i<$NUM_PARTS; i++ )); do
    NEW_VERSION="$NEW_VERSION.${VERSION_PARTS[$i]}"
done

echo "New version:     $NEW_VERSION"
echo ""

# Create backup
BACKUP_FILE="$APP_JSON.backup"
cp "$APP_JSON" "$BACKUP_FILE"
echo "Created backup:  $BACKUP_FILE"

# Update version in app.json
# Use sed with proper escaping for cross-platform compatibility
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed requires -i with empty string
    sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$APP_JSON"
else
    # Linux/Windows Git Bash sed
    sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$APP_JSON"
fi

# Verify the change
VERIFY_VERSION=$(grep '"version"' "$APP_JSON" | head -1 | cut -d'"' -f4)

if [ "$VERIFY_VERSION" = "$NEW_VERSION" ]; then
    echo "✓ Version updated successfully"
    echo ""
    echo "Summary:"
    echo "  Old: $CURRENT_VERSION"
    echo "  New: $NEW_VERSION"
    echo ""
    rm -f "$BACKUP_FILE"
    exit 0
else
    echo "✗ Error: Version update failed"
    echo "Restoring backup..."
    mv "$BACKUP_FILE" "$APP_JSON"
    exit 1
fi
