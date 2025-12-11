#!/bin/bash

# Business Central App Verification Script
# Checks app installation status via Admin Center API or Extension Management API
# Works for both sandbox and production environments

echo "=== Business Central App Verification ==="
echo ""

# Exit on error
set -e

# Determine workspace root (repo root, two directories up from scripts)
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Default values
APP_ID=""
ENVIRONMENT_NAME=""
SHOW_ALL_APPS=false

# Function to load .env file
load_env() {
    local env_file="$WORKSPACE_ROOT/.env"

    if [ ! -f "$env_file" ]; then
        echo "Error: .env file not found at $env_file"
        echo "Please copy .env.example to .env and configure it."
        exit 1
    fi

    # Load environment variables
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        if [[ -n "$key" && -n "$value" ]]; then
            export "$key=$value"
        fi
    done < "$env_file"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --app-id)
            APP_ID="$2"
            shift 2
            ;;
        --environment)
            ENVIRONMENT_NAME="$2"
            shift 2
            ;;
        --all)
            SHOW_ALL_APPS=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --app-id GUID          App ID to verify (auto-detected if not specified)"
            echo "  --environment NAME     Override environment name from .env"
            echo "  --all                  Show all installed extensions"
            echo "  --help                 Show this help message"
            echo ""
            echo "Configuration:"
            echo "  Configure .env file with deployment settings"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Load environment configuration
load_env

# Use provided environment name or default from .env
ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-$BC_ENVIRONMENT_NAME}"

if [ -z "$ENVIRONMENT_NAME" ]; then
    echo "Error: BC_ENVIRONMENT_NAME not set in .env and not provided via --environment"
    exit 1
fi

echo "Configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Deployment Type:   $BC_DEPLOYMENT_TYPE"
echo "Environment Type:  $BC_ENVIRONMENT_TYPE"
echo "Environment Name:  $ENVIRONMENT_NAME"
if [ "$SHOW_ALL_APPS" = true ]; then
    echo "Mode:              Show all extensions"
else
    echo "Mode:              Verify specific app"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Auto-detect app ID if not provided and not showing all apps
if [ -z "$APP_ID" ] && [ "$SHOW_ALL_APPS" = false ]; then
    echo "Auto-detecting app ID from app.json..."

    BC_APPS_ROOT="${BC_APPS_ROOT:-BC}"
    if [[ "$BC_APPS_ROOT" != /* ]]; then
        BC_APPS_ROOT="$WORKSPACE_ROOT/$BC_APPS_ROOT"
    fi

    # Find app.json files
    APP_JSON_FILES=()
    while IFS= read -r -d '' app_json; do
        APP_JSON_FILES+=("$app_json")
    done < <(find "$BC_APPS_ROOT" -name "app.json" -type f -print0 2>/dev/null)

    if [ ${#APP_JSON_FILES[@]} -eq 0 ]; then
        echo "Error: No app.json files found in $BC_APPS_ROOT"
        echo "Please specify --app-id or use --all to show all extensions"
        exit 1
    elif [ ${#APP_JSON_FILES[@]} -eq 1 ]; then
        APP_JSON="${APP_JSON_FILES[0]}"
        APP_ID=$(grep -m 1 '"id"' "$APP_JSON" | sed 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [ -n "$APP_ID" ]; then
            echo "Found app ID: $APP_ID"
            APP_NAME=$(grep -m 1 '"name"' "$APP_JSON" | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
            if [ -n "$APP_NAME" ]; then
                echo "App name: $APP_NAME"
            fi
        else
            echo "Error: Could not extract app ID from $APP_JSON"
            exit 1
        fi
    else
        echo "Multiple app.json files found:"
        for i in "${!APP_JSON_FILES[@]}"; do
            APP_JSON="${APP_JSON_FILES[$i]}"
            DETECTED_ID=$(grep -m 1 '"id"' "$APP_JSON" | sed 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
            DETECTED_NAME=$(grep -m 1 '"name"' "$APP_JSON" | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
            echo "  $((i+1)). $DETECTED_NAME (ID: $DETECTED_ID)"
        done
        echo ""
        echo "Please specify which app to verify using --app-id"
        exit 1
    fi
    echo ""
fi

# Get authentication
echo "Authenticating..."
AUTH_HEADER=$(bash "$WORKSPACE_ROOT/.claude/scripts/bc-auth.sh" get-header)

if [ $? -ne 0 ]; then
    echo "Error: Authentication failed"
    exit 1
fi

echo "✓ Authentication successful"
echo ""

# Construct API endpoint
if [ "$BC_DEPLOYMENT_TYPE" = "online" ]; then
    # Admin Center API for online
    if [ "$SHOW_ALL_APPS" = true ]; then
        API_URL="https://api.businesscentral.dynamics.com/admin/v2.25/applications/businesscentral/environments/$ENVIRONMENT_NAME/apps"
    else
        API_URL="https://api.businesscentral.dynamics.com/admin/v2.25/applications/businesscentral/environments/$ENVIRONMENT_NAME/apps/$APP_ID"
    fi
elif [ "$BC_DEPLOYMENT_TYPE" = "local" ]; then
    # Extension Management API for local
    echo "⚠ Note: Local verification uses Extension Management page data"
    echo "Admin Center API not available for local/Docker deployments"
    echo ""

    # For local, we can try the published apps endpoint
    if [ "$SHOW_ALL_APPS" = true ]; then
        API_URL="$BC_LOCAL_SERVER_URL/$ENVIRONMENT_NAME/api/microsoft/automation/v2.0/extensions"
    else
        API_URL="$BC_LOCAL_SERVER_URL/$ENVIRONMENT_NAME/api/microsoft/automation/v2.0/extensions?$filter=id eq $APP_ID"
    fi
else
    echo "Error: Invalid BC_DEPLOYMENT_TYPE: $BC_DEPLOYMENT_TYPE"
    exit 1
fi

echo "Querying BC environment..."
echo "API: $API_URL"
echo ""

# Query the API
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "$API_URL" \
    -H "$AUTH_HEADER" \
    -H "Accept: application/json")

# Extract HTTP status code
HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS:" | cut -d':' -f2)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS:/d')

echo ""

# Check result
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "201" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✓ Query Successful"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Try to parse response
    if echo "$RESPONSE_BODY" | grep -q "\"value\""; then
        # List of apps
        echo "Installed Extensions:"
        echo ""

        # Extract app information (simplified parsing)
        echo "$RESPONSE_BODY" | grep -o '"displayName":"[^"]*"' | cut -d'"' -f4 | while read -r app_name; do
            echo "  • $app_name"
        done
        echo ""

        # Show full JSON for details (limited to first 2000 chars)
        echo "Response details:"
        echo "$RESPONSE_BODY" | head -c 2000
        if [ ${#RESPONSE_BODY} -gt 2000 ]; then
            echo "..."
            echo "(Response truncated - showing first 2000 characters)"
        fi
    else
        # Single app details
        echo "App Details:"
        echo ""

        # Try to extract key fields
        if echo "$RESPONSE_BODY" | grep -q "displayName"; then
            DISPLAY_NAME=$(echo "$RESPONSE_BODY" | grep -o '"displayName":"[^"]*"' | cut -d'"' -f4)
            echo "Name:        $DISPLAY_NAME"
        fi

        if echo "$RESPONSE_BODY" | grep -q "\"version\""; then
            VERSION=$(echo "$RESPONSE_BODY" | grep -o '"version":"[^"]*"' | cut -d'"' -f4 | head -1)
            echo "Version:     $VERSION"
        fi

        if echo "$RESPONSE_BODY" | grep -q "\"state\""; then
            STATE=$(echo "$RESPONSE_BODY" | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
            echo "State:       $STATE"
        fi

        if echo "$RESPONSE_BODY" | grep -q "\"publisher\""; then
            PUBLISHER=$(echo "$RESPONSE_BODY" | grep -o '"publisher":"[^"]*"' | cut -d'"' -f4)
            echo "Publisher:   $PUBLISHER"
        fi

        if echo "$RESPONSE_BODY" | grep -q "\"id\""; then
            FOUND_ID=$(echo "$RESPONSE_BODY" | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | head -1)
            echo "App ID:      $FOUND_ID"
        fi

        echo ""
        echo "Full response:"
        echo "$RESPONSE_BODY"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0

elif [ "$HTTP_STATUS" = "404" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠ App Not Found"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    if [ -n "$APP_ID" ]; then
        echo "App ID: $APP_ID"
    fi
    echo "Environment: $ENVIRONMENT_NAME"
    echo ""
    echo "The specified app is not installed in this environment."
    echo ""
    echo "Possible reasons:"
    echo "  - App has not been published yet"
    echo "  - App was published to a different environment"
    echo "  - App ID is incorrect"
    echo "  - App installation is still in progress"
    echo ""
    echo "Try:"
    echo "  - Publish the app: bc_publish_sandbox"
    echo "  - Check all apps: bash .claude/scripts/bc-verify-app.sh --all"
    echo "  - Verify app ID in app.json"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1

else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✗ Query Failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "HTTP Status: $HTTP_STATUS"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY"
    echo ""
    echo "Common Issues:"
    echo "  - Check authentication credentials in .env"
    echo "  - Verify environment name is correct"
    echo "  - For online: Ensure API permissions are granted"
    echo "  - For local: Ensure BC server is running and accessible"
    echo "  - Admin Center API may require additional permissions"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi
