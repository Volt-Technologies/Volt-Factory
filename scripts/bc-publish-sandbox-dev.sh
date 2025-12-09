#!/bin/bash

# Business Central Sandbox Dev Mode Publishing Script
# Publishes BC apps to sandbox environment using Dev endpoint
# Supports both online/SaaS and local/Docker deployments
#
# Authentication Requirements:
#   Online/SaaS: Uses OAuth Bearer token (no special headers needed)
#   Local/Docker: Requires both Basic Auth AND Authorization-Scheme: NAVUserPassword header
#
# Tenant Configuration:
#   Online/SaaS: Uses tenant ID from .env (BC_TENANT_ID)
#   Local/Docker: Uses "default" as the tenant identifier (standard for on-premises)

echo "=== Business Central Sandbox Dev Publishing ==="
echo ""

# Exit on error
set -e

# Determine workspace root
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default values
FORCE_SYNC=false
SCHEMA_UPDATE_MODE="forcesync"
DEPENDENCY_OPTION="default"
APP_PATH=""
ENVIRONMENT_NAME=""

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
        --app-path)
            APP_PATH="$2"
            shift 2
            ;;
        --environment)
            ENVIRONMENT_NAME="$2"
            shift 2
            ;;
        --force-sync)
            FORCE_SYNC=true
            SCHEMA_UPDATE_MODE="forcesync"
            shift
            ;;
        --synchronize)
            SCHEMA_UPDATE_MODE="synchronize"
            shift
            ;;
        --recreate)
            SCHEMA_UPDATE_MODE="recreate"
            shift
            ;;
        --ignore-dependencies)
            DEPENDENCY_OPTION="ignore"
            shift
            ;;
        --strict-dependencies)
            DEPENDENCY_OPTION="strict"
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --app-path PATH              Path to .app file (auto-detected if not specified)"
            echo "  --environment NAME           Override environment name from .env"
            echo "  --force-sync                 Use force sync mode (default)"
            echo "  --synchronize                Use synchronize mode"
            echo "  --recreate                   Use recreate mode"
            echo "  --ignore-dependencies        Ignore dependency validation"
            echo "  --strict-dependencies        Strict dependency validation"
            echo "  --help                       Show this help message"
            echo ""
            echo "Environment Configuration:"
            echo "  Configure .env file with deployment settings"
            echo "  See .env.example for configuration template"
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
echo "Schema Mode:       $SCHEMA_UPDATE_MODE"
echo "Dependencies:      $DEPENDENCY_OPTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate environment type (dev mode only for sandbox)
if [ "$BC_ENVIRONMENT_TYPE" != "sandbox" ]; then
    echo "Error: Dev mode publishing is only supported for sandbox environments"
    echo "Current environment type: $BC_ENVIRONMENT_TYPE"
    echo "For production environments, use bc-publish-production-pte.sh instead"
    exit 1
fi

# Find .app file if not specified
if [ -z "$APP_PATH" ]; then
    echo "Searching for compiled .app file..."

    # Look for .app files in BC apps root
    BC_APPS_ROOT="${BC_APPS_ROOT:-BC}"
    if [[ "$BC_APPS_ROOT" != /* ]]; then
        BC_APPS_ROOT="$WORKSPACE_ROOT/$BC_APPS_ROOT"
    fi

    APP_FILES=()
    while IFS= read -r -d '' app_file; do
        APP_FILES+=("$app_file")
    done < <(find "$BC_APPS_ROOT" -name "*.app" -type f -print0 2>/dev/null)

    if [ ${#APP_FILES[@]} -eq 0 ]; then
        echo "Error: No .app files found in $BC_APPS_ROOT"
        echo "Please compile your app first using: bc_compile"
        exit 1
    elif [ ${#APP_FILES[@]} -eq 1 ]; then
        APP_PATH="${APP_FILES[0]}"
        echo "Found app: $APP_PATH"
    else
        echo "Multiple .app files found:"
        for i in "${!APP_FILES[@]}"; do
            echo "  $((i+1)). ${APP_FILES[$i]}"
        done
        echo ""
        echo "Please specify which app to publish using --app-path"
        exit 1
    fi
else
    if [ ! -f "$APP_PATH" ]; then
        echo "Error: App file not found: $APP_PATH"
        exit 1
    fi
fi

# Get app name and size
APP_NAME=$(basename "$APP_PATH")
APP_SIZE=$(du -h "$APP_PATH" | cut -f1)

echo ""
echo "Publishing app:"
echo "  File: $APP_NAME"
echo "  Size: $APP_SIZE"
echo "  Path: $APP_PATH"
echo ""

# Get authentication
echo "Authenticating..."
AUTH_HEADER=$(bash "$WORKSPACE_ROOT/scripts/bc-auth.sh" get-header)

if [ $? -ne 0 ]; then
    echo "Error: Authentication failed"
    exit 1
fi

echo "✓ Authentication successful"
echo ""

# Construct API endpoint based on deployment type
if [ "$BC_DEPLOYMENT_TYPE" = "online" ]; then
    # Online/SaaS endpoint
    API_URL="https://api.businesscentral.dynamics.com/v2.0/$ENVIRONMENT_NAME/dev/apps"
    QUERY_PARAMS="tenant=$BC_TENANT_ID&SchemaUpdateMode=$SCHEMA_UPDATE_MODE&DependencyPublishingOption=$DEPENDENCY_OPTION"
elif [ "$BC_DEPLOYMENT_TYPE" = "local" ]; then
    # Local/Docker endpoint
    # Note: Local BC instances use "default" as the default tenant identifier
    # This is the standard tenant name for single-tenant on-premises installations
    API_URL="$BC_LOCAL_SERVER_URL/$ENVIRONMENT_NAME/dev/apps"
    QUERY_PARAMS="tenant=default&SchemaUpdateMode=$SCHEMA_UPDATE_MODE&DependencyPublishingOption=$DEPENDENCY_OPTION"
else
    echo "Error: Invalid BC_DEPLOYMENT_TYPE: $BC_DEPLOYMENT_TYPE"
    exit 1
fi

FULL_URL="$API_URL?$QUERY_PARAMS"

echo "Publishing to Dev endpoint..."
echo "URL: $API_URL"
echo ""

# Generate unique boundary for multipart form data
BOUNDARY="----BCAppBoundary$(date +%s)"

# Create temporary file for multipart body
TEMP_BODY=$(mktemp)
trap "rm -f $TEMP_BODY" EXIT

# Build multipart form data (must use CRLF line endings for HTTP)
{
    printf -- "--%s\r\n" "$BOUNDARY"
    printf "Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n" "$APP_NAME"
    printf "Content-Type: application/octet-stream\r\n"
    printf "\r\n"
    cat "$APP_PATH"
    printf "\r\n"
    printf -- "--%s--\r\n" "$BOUNDARY"
} > "$TEMP_BODY"

# Publish the app
echo "Uploading app to Business Central..."

# Build headers based on deployment type
if [ "$BC_DEPLOYMENT_TYPE" = "local" ]; then
    # Local deployment requires NAVUserPassword authentication scheme
    RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$FULL_URL" \
        -H "$AUTH_HEADER" \
        -H "Authorization-Scheme: NAVUserPassword" \
        -H "Content-Type: multipart/form-data; boundary=$BOUNDARY" \
        -H "Accept: application/json" \
        --data-binary "@$TEMP_BODY")
else
    # Online deployment uses standard OAuth Bearer token
    RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$FULL_URL" \
        -H "$AUTH_HEADER" \
        -H "Content-Type: multipart/form-data; boundary=$BOUNDARY" \
        -H "Accept: application/json" \
        --data-binary "@$TEMP_BODY")
fi

# Extract HTTP status code
HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS:" | cut -d':' -f2)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS:/d')

echo ""

# Check result
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "201" ] || [ "$HTTP_STATUS" = "204" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✓ SUCCESS: App published successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "App:         $APP_NAME"
    echo "Environment: $ENVIRONMENT_NAME"
    echo "Mode:        Dev (sandbox)"
    echo "Status:      Published and synchronized"
    echo ""

    # Try to extract app details from response
    if echo "$RESPONSE_BODY" | grep -q "id"; then
        APP_ID=$(echo "$RESPONSE_BODY" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$APP_ID" ]; then
            echo "App ID:      $APP_ID"
        fi
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✗ FAILED: App publishing failed"
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
    echo "  - Ensure app dependencies are satisfied"
    echo "  - Check app.json configuration"
    echo "  - For local: Ensure BC server is running and accessible"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi
