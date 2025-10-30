#!/bin/bash

# Business Central AL Multi-App Compilation Script (Cross-platform)
# This script compiles Business Central extensions using the AL compiler
# Supports Windows, Linux, and macOS by auto-detecting the OS
# Automatically discovers and compiles all apps in the configured root directory

echo "=== Business Central AL Multi-App Compilation Script ==="
echo "Starting compilation process..."

# Detect operating system
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Linux*)
        OS_NAME="linux"
        COMPILER_EXE="alc"
        ;;
    Darwin*)
        OS_NAME="darwin"
        COMPILER_EXE="alc"
        ;;
    CYGWIN*|MINGW*|MSYS*)
        OS_NAME="win32"
        COMPILER_EXE="alc.exe"
        ;;
    *)
        echo "Warning: Unknown OS type '$OS_TYPE', defaulting to Linux"
        OS_NAME="linux"
        COMPILER_EXE="alc"
        ;;
esac

echo "Detected OS: $OS_NAME"
echo ""

# Define workspace root
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load .env file if it exists
if [ -f "$WORKSPACE_ROOT/.env" ]; then
    echo "Loading configuration from .env file..."
    # Load environment variables from .env (ignore comments and empty lines)
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        # Remove leading/trailing whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        # Export the variable
        if [[ -n "$key" && -n "$value" ]]; then
            export "$key=$value"
            echo "  $key=$value"
        fi
    done < "$WORKSPACE_ROOT/.env"
    echo ""
fi

# Set default paths (can be overridden by .env or command-line params)
BC_APPS_ROOT="${BC_APPS_ROOT:-BC}"
COMPILER_PATH="${BC_COMPILER_PATH:-$WORKSPACE_ROOT/scripts/compiler/extension/bin/$OS_NAME}"
PACKAGE_CACHE_PATH="${BC_PACKAGE_CACHE:-}"  # Will be set per-app if not specified
OUTPUT_DIR="${BC_OUTPUT_DIR:-}"  # Will be set per-app if not specified

# Allow overriding paths via parameters
while [[ $# -gt 0 ]]; do
    case $1 in
        --appsroot)
            BC_APPS_ROOT="$2"
            shift 2
            ;;
        --compiler)
            COMPILER_PATH="$2"
            shift 2
            ;;
        --packagecache)
            PACKAGE_CACHE_PATH="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --appsroot PATH      Root path to search for BC apps (default: $BC_APPS_ROOT)"
            echo "  --compiler PATH      Path to compiler folder (default: auto-detected)"
            echo "  --packagecache PATH  Path to package cache folder (default: per-app .alpackages)"
            echo "  --output PATH        Path to output directory (default: same as app folder)"
            echo "  --help               Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Resolve BC_APPS_ROOT to absolute path
if [[ "$BC_APPS_ROOT" != /* ]]; then
    BC_APPS_ROOT="$WORKSPACE_ROOT/$BC_APPS_ROOT"
fi

echo "Configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Apps Root:     $BC_APPS_ROOT"
echo "Compiler:      $COMPILER_PATH/$COMPILER_EXE"
if [ -n "$PACKAGE_CACHE_PATH" ]; then
    echo "Package Cache: $PACKAGE_CACHE_PATH (global)"
else
    echo "Package Cache: Per-app (.alpackages in each app folder)"
fi
if [ -n "$OUTPUT_DIR" ]; then
    echo "Output Dir:    $OUTPUT_DIR"
else
    echo "Output Dir:    Per-app (each app in its own folder)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if compiler exists
if [ ! -f "$COMPILER_PATH/$COMPILER_EXE" ]; then
    echo "Error: AL Compiler not found at $COMPILER_PATH/$COMPILER_EXE"
    echo "Please ensure the Business Central compiler is properly installed."
    exit 1
fi

# Check if apps root exists
if [ ! -d "$BC_APPS_ROOT" ]; then
    echo "Error: Apps root directory not found at $BC_APPS_ROOT"
    echo "Please ensure the path is correct."
    exit 1
fi

# Make compiler executable if not already (only needed on Linux/macOS)
if [ "$OS_NAME" != "win32" ]; then
    if [ ! -x "$COMPILER_PATH/$COMPILER_EXE" ]; then
        echo "Making AL compiler executable..."
        chmod +x "$COMPILER_PATH/$COMPILER_EXE"
        if [ $? -eq 0 ]; then
            echo "✓ AL compiler made executable"
        else
            echo "⚠ Warning: Could not make compiler executable"
        fi
        echo ""
    fi
fi

# Find all app.json files recursively
echo "Discovering Business Central apps..."
APP_JSON_FILES=()
while IFS= read -r -d '' app_json; do
    APP_JSON_FILES+=("$app_json")
done < <(find "$BC_APPS_ROOT" -name "app.json" -type f -print0)

APP_COUNT=${#APP_JSON_FILES[@]}

if [ $APP_COUNT -eq 0 ]; then
    echo "Error: No app.json files found under $BC_APPS_ROOT"
    echo "Please ensure you have at least one Business Central app in the directory."
    exit 1
fi

echo "Found $APP_COUNT app(s) to compile:"
for app_json in "${APP_JSON_FILES[@]}"; do
    APP_DIR=$(dirname "$app_json")
    echo "  - $APP_DIR"
done
echo ""

# Function to extract app name from app.json
get_app_name() {
    local app_json="$1"
    # Use grep and sed to extract the name field
    local name=$(grep -m 1 '"name"' "$app_json" | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    echo "$name"
}

# Function to extract app version from app.json
get_app_version() {
    local app_json="$1"
    # Use grep and sed to extract the version field
    local version=$(grep -m 1 '"version"' "$app_json" | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    echo "$version"
}

# Arrays to track compilation results
SUCCESSFUL_APPS=()
FAILED_APPS=()

# Navigate to compiler directory
cd "$COMPILER_PATH" || exit 1

# Compile each app
for app_json in "${APP_JSON_FILES[@]}"; do
    APP_DIR=$(dirname "$app_json")
    APP_NAME=$(get_app_name "$app_json")
    APP_VERSION=$(get_app_version "$app_json")

    if [ -z "$APP_NAME" ]; then
        echo "⚠ Warning: Could not extract app name from $app_json, using folder name"
        APP_NAME=$(basename "$APP_DIR")
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Compiling: $APP_NAME"
    if [ -n "$APP_VERSION" ]; then
        echo "Version:   $APP_VERSION"
    fi
    echo "Location:  $APP_DIR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Determine package cache path for this app
    if [ -n "$PACKAGE_CACHE_PATH" ]; then
        APP_PACKAGE_CACHE="$PACKAGE_CACHE_PATH"
    else
        APP_PACKAGE_CACHE="$APP_DIR/.alpackages"
    fi

    # Determine output file path for this app (include version in filename)
    if [ -n "$APP_VERSION" ]; then
        OUTPUT_FILENAME="${APP_NAME}_${APP_VERSION}.app"
    else
        OUTPUT_FILENAME="${APP_NAME}.app"
    fi

    if [ -n "$OUTPUT_DIR" ]; then
        APP_OUTPUT="$OUTPUT_DIR/$OUTPUT_FILENAME"
    else
        APP_OUTPUT="$APP_DIR/$OUTPUT_FILENAME"
    fi

    # Create package cache directory if it doesn't exist
    if [ ! -d "$APP_PACKAGE_CACHE" ]; then
        echo "Creating package cache directory: $APP_PACKAGE_CACHE"
        mkdir -p "$APP_PACKAGE_CACHE"
    fi

    # Remove existing output file if it exists
    if [ -f "$APP_OUTPUT" ]; then
        echo "Removing existing output file: $APP_OUTPUT"
        rm -f "$APP_OUTPUT"
    fi

    echo ""
    echo "Compilation settings:"
    echo "  Project:       $APP_DIR"
    echo "  Package Cache: $APP_PACKAGE_CACHE"
    echo "  Output:        $APP_OUTPUT"
    echo ""

    # Run compilation
    if [ "$OS_NAME" = "win32" ]; then
        # Convert Unix paths to Windows paths for the compiler
        WIN_APP_DIR=$(cygpath -w "$APP_DIR" 2>/dev/null || echo "$APP_DIR" | sed 's|^/\([a-z]\)/|\U\1:/|')
        WIN_APP_PACKAGE_CACHE=$(cygpath -w "$APP_PACKAGE_CACHE" 2>/dev/null || echo "$APP_PACKAGE_CACHE" | sed 's|^/\([a-z]\)/|\U\1:/|')
        WIN_APP_OUTPUT=$(cygpath -w "$APP_OUTPUT" 2>/dev/null || echo "$APP_OUTPUT" | sed 's|^/\([a-z]\)/|\U\1:/|')
        ./$COMPILER_EXE /project:"$WIN_APP_DIR" /packagecachepath:"$WIN_APP_PACKAGE_CACHE" /out:"$WIN_APP_OUTPUT"
    else
        # Linux and macOS use Unix paths directly
        ./$COMPILER_EXE /project:"$APP_DIR" /packagecachepath:"$APP_PACKAGE_CACHE" /out:"$APP_OUTPUT"
    fi

    COMPILE_RESULT=$?
    echo ""

    if [ $COMPILE_RESULT -eq 0 ] && [ -f "$APP_OUTPUT" ]; then
        FILE_SIZE=$(du -h "$APP_OUTPUT" | cut -f1)
        echo "✓ SUCCESS: $APP_NAME compiled successfully ($FILE_SIZE)"
        SUCCESSFUL_APPS+=("$APP_NAME|$APP_OUTPUT|$FILE_SIZE")
    else
        echo "✗ FAILED: $APP_NAME compilation failed"
        FAILED_APPS+=("$APP_NAME|$APP_DIR")
    fi

    echo ""
done

# Print compilation summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "=== COMPILATION SUMMARY ==="
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total apps found:       $APP_COUNT"
echo "Successfully compiled:  ${#SUCCESSFUL_APPS[@]}"
echo "Failed:                 ${#FAILED_APPS[@]}"
echo ""

if [ ${#SUCCESSFUL_APPS[@]} -gt 0 ]; then
    echo "✓ Successful compilations:"
    for app_info in "${SUCCESSFUL_APPS[@]}"; do
        IFS='|' read -r name output size <<< "$app_info"
        echo "  - $name → $output ($size)"
    done
    echo ""
fi

if [ ${#FAILED_APPS[@]} -gt 0 ]; then
    echo "✗ Failed compilations:"
    for app_info in "${FAILED_APPS[@]}"; do
        IFS='|' read -r name location <<< "$app_info"
        echo "  - $name (at $location)"
    done
    echo ""
    echo "Common issues:"
    echo "  - Missing dependencies in .alpackages folder"
    echo "  - Syntax errors in AL code"
    echo "  - Invalid app.json configuration"
    echo "  - Incompatible dependency versions"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Exit with error if any compilation failed
if [ ${#FAILED_APPS[@]} -gt 0 ]; then
    echo "Compilation process completed with errors."
    exit 1
else
    echo "Compilation process completed successfully!"
    exit 0
fi
