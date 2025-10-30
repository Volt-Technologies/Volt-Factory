#!/bin/bash

# Business Central Sandbox PTE Publishing Script
# Publishes BC apps to sandbox environment using PTE mode
# For testing production deployment process in safe sandbox environment

echo "=== Business Central Sandbox PTE Publishing ==="
echo ""

# Exit on error
set -e

# Determine workspace root
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default values
APP_PATH=""
ENVIRONMENT_NAME=""
COMPANY_ID=""
INSTALL_DEPENDENCIES=true

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
        --company-id)
            COMPANY_ID="$2"
            shift 2
            ;;
        --no-install-dependencies)
            INSTALL_DEPENDENCIES=false
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --app-path PATH              Path to .app file (auto-detected if not specified)"
            echo "  --environment NAME           Override environment name from .env"
            echo "  --company-id GUID            Company ID for installation (uses .env if not specified)"
            echo "  --no-install-dependencies    Do not automatically install dependencies"
            echo "  --help                       Show this help message"
            echo ""
            echo "Environment Configuration:"
            echo "  Configure .env file with deployment settings"
            echo "  BC_ENVIRONMENT_TYPE should be set to 'sandbox'"
            echo "  Supports both online/SaaS and local/Docker deployments"
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

# Use provided values or defaults from .env
ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-$BC_ENVIRONMENT_NAME}"
COMPANY_ID="${COMPANY_ID:-$BC_COMPANY_ID}"

if [ -z "$ENVIRONMENT_NAME" ]; then
    echo "Error: BC_ENVIRONMENT_NAME not set in .env and not provided via --environment"
    exit 1
fi

# Auto-fetch company ID if not provided
if [ -z "$COMPANY_ID" ]; then
    echo "Company ID not specified, attempting to fetch from BC API..."

    # Get authentication header early
    AUTH_HEADER_TEMP=$(bash "$WORKSPACE_ROOT/scripts/bc-auth.sh" get-header 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$AUTH_HEADER_TEMP" ]; then
        # Construct companies API URL
        if [ "$BC_DEPLOYMENT_TYPE" = "online" ]; then
            COMPANIES_API_URL="https://api.businesscentral.dynamics.com/v2.0/$BC_TENANT_ID/$ENVIRONMENT_NAME/api/v2.0/companies"
        else
            COMPANIES_API_URL="$BC_LOCAL_SERVER_URL/$ENVIRONMENT_NAME/api/v2.0/companies"
        fi

        # Fetch companies and extract first company ID
        COMPANIES_RESPONSE=$(curl -s -H "$AUTH_HEADER_TEMP" -H "Accept: application/json" "$COMPANIES_API_URL" 2>/dev/null)
        COMPANY_ID=$(echo "$COMPANIES_RESPONSE" | grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)

        if [ -n "$COMPANY_ID" ]; then
            echo "✓ Auto-fetched Company ID: $COMPANY_ID"

            # Try to get company name for display
            COMPANY_NAME=$(echo "$COMPANIES_RESPONSE" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)
            if [ -n "$COMPANY_NAME" ]; then
                echo "  Company Name: $COMPANY_NAME"
            fi
            echo ""
        else
            echo "⚠ Warning: Could not auto-fetch company ID"
            echo "  The companies API may not be accessible or returned no data"
            echo ""
        fi
    fi
fi

echo "Configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Deployment Type:   $BC_DEPLOYMENT_TYPE"
echo "Environment Type:  $BC_ENVIRONMENT_TYPE"
echo "Environment Name:  $ENVIRONMENT_NAME"
echo "Publishing Mode:   PTE (Per-Tenant Extension)"
echo "Company ID:        ${COMPANY_ID:-Not specified}"
echo "Install Deps:      $INSTALL_DEPENDENCIES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate environment type
if [ "$BC_ENVIRONMENT_TYPE" = "production" ]; then
    echo "⚠ Warning: Using PTE mode with production environment type"
    echo "For actual production deployments, use bc-publish-production-pte.sh"
    echo ""
fi

# Find .app file if not specified
if [ -z "$APP_PATH" ]; then
    echo "Searching for compiled .app file..."

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

# Get app details
APP_NAME=$(basename "$APP_PATH")
APP_SIZE=$(du -h "$APP_PATH" | cut -f1)

# Try to extract app ID and version from app.json
APP_DIR=$(dirname "$APP_PATH")
APP_JSON="$APP_DIR/app.json"
APP_ID=""
APP_VERSION=""

if [ -f "$APP_JSON" ]; then
    APP_ID=$(grep -m 1 '"id"' "$APP_JSON" | sed 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    APP_VERSION=$(grep -m 1 '"version"' "$APP_JSON" | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
fi

echo ""
echo "App Details:"
echo "  Name:    $APP_NAME"
echo "  Size:    $APP_SIZE"
echo "  Path:    $APP_PATH"
if [ -n "$APP_ID" ]; then
    echo "  App ID:  $APP_ID"
fi
if [ -n "$APP_VERSION" ]; then
    echo "  Version: $APP_VERSION"
fi
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

# Note about PTE deployment
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PTE Deployment via Automation API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "PTE (Per-Tenant Extension) deployment requires the Automation API."
echo "This is a multi-step process:"
echo "  1. Upload extension package"
echo "  2. Install extension"
echo "  3. Configure extension settings"
echo ""

if [ -z "$COMPANY_ID" ]; then
    echo "⚠ Warning: Company ID not specified"
    echo "PTE installation via Automation API requires a company ID"
    echo "Set BC_COMPANY_ID in .env or use --company-id parameter"
    echo ""
fi

# Validate company ID is available
if [ -z "$COMPANY_ID" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✗ ERROR: Company ID Required"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "PTE publishing requires a company ID and auto-fetch failed."
    echo ""
    echo "Solutions:"
    echo "  1. Set BC_COMPANY_ID in .env file"
    echo "  2. Use --company-id parameter"
    echo "  3. Ensure companies API is accessible in your environment"
    echo ""
    echo "To find your company ID manually:"
    echo "  - Open Business Central web client"
    echo "  - Search for 'Companies'"
    echo "  - Open a company and go to API Setup"
    echo "  - Copy the Company ID (GUID)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi

# Construct Automation API endpoint for extensionUpload
if [ "$BC_DEPLOYMENT_TYPE" = "online" ]; then
    # Online/SaaS Automation API endpoint
    AUTOMATION_API_BASE="https://api.businesscentral.dynamics.com/v2.0/$BC_TENANT_ID/$ENVIRONMENT_NAME/api/microsoft/automation/v2.0/companies($COMPANY_ID)/extensionUpload"
elif [ "$BC_DEPLOYMENT_TYPE" = "local" ]; then
    # Local/Docker Automation API endpoint
    AUTOMATION_API_BASE="$BC_LOCAL_SERVER_URL/$ENVIRONMENT_NAME/api/microsoft/automation/v2.0/companies($COMPANY_ID)/extensionUpload"
else
    echo "Error: Invalid BC_DEPLOYMENT_TYPE: $BC_DEPLOYMENT_TYPE"
    exit 1
fi

echo "PTE Upload Workflow (4 steps):"
echo "  1. Create extensionUpload resource"
echo "  2. Upload extension content via PATCH"
echo "  3. Trigger installation via bound action"
echo "  4. Monitor deployment status until complete"
echo ""

# STEP 0/1: Get or Create extensionUpload resource
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Getting or creating extensionUpload resource..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SYSTEM_ID=""

# Try to get existing extensionUpload records
EXISTING_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "$AUTOMATION_API_BASE" \
    -H "$AUTH_HEADER" \
    -H "Accept: application/json")

EXISTING_STATUS=$(echo "$EXISTING_RESPONSE" | grep "HTTP_STATUS:" | cut -d':' -f2)
EXISTING_BODY=$(echo "$EXISTING_RESPONSE" | sed '/HTTP_STATUS:/d')

if [ "$EXISTING_STATUS" = "200" ]; then
    # Check if there are any existing records and reuse the first one
    SYSTEM_ID=$(echo "$EXISTING_BODY" | grep -o '"systemId"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$SYSTEM_ID" ]; then
        echo "✓ Found existing extensionUpload resource, reusing it"
        echo "  System ID: $SYSTEM_ID"

        # Update it with our desired settings
        SCHEMA_SYNC_MODE="Add"
        [ "$INSTALL_DEPENDENCIES" = false ] && SCHEMA_SYNC_MODE="Force Sync"

        UPDATE_PAYLOAD=$(cat <<EOF
{
    "schedule": "Current version",
    "schemaSyncMode": "$SCHEMA_SYNC_MODE"
}
EOF
)

        echo "  Updating settings..."
        RESPONSE_UPDATE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X PATCH "$AUTOMATION_API_BASE($SYSTEM_ID)" \
            -H "$AUTH_HEADER" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -H "If-Match: *" \
            -d "$UPDATE_PAYLOAD")

        HTTP_STATUS_UPDATE=$(echo "$RESPONSE_UPDATE" | grep "HTTP_STATUS:" | cut -d':' -f2)

        if [ "$HTTP_STATUS_UPDATE" = "200" ] || [ "$HTTP_STATUS_UPDATE" = "204" ]; then
            echo "  ✓ Settings updated"
        else
            echo "  ⚠ Could not update settings (will proceed anyway)"
        fi
    fi
fi

# If no existing record found, create a new one
if [ -z "$SYSTEM_ID" ]; then
    echo "No existing record found, creating new extensionUpload resource..."

    # Build JSON payload for creating extensionUpload
    SCHEMA_SYNC_MODE="Add"
    [ "$INSTALL_DEPENDENCIES" = false ] && SCHEMA_SYNC_MODE="Force Sync"

    CREATE_PAYLOAD=$(cat <<EOF
{
    "schedule": "Current version",
    "schemaSyncMode": "$SCHEMA_SYNC_MODE"
}
EOF
)

    # Create extensionUpload resource
    RESPONSE_CREATE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$AUTOMATION_API_BASE" \
        -H "$AUTH_HEADER" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "$CREATE_PAYLOAD")

    HTTP_STATUS_CREATE=$(echo "$RESPONSE_CREATE" | grep "HTTP_STATUS:" | cut -d':' -f2)
    RESPONSE_BODY_CREATE=$(echo "$RESPONSE_CREATE" | sed '/HTTP_STATUS:/d')

    if [ "$HTTP_STATUS_CREATE" != "201" ] && [ "$HTTP_STATUS_CREATE" != "200" ]; then
        echo "✗ Failed to create extensionUpload resource"
        echo "HTTP Status: $HTTP_STATUS_CREATE"
        echo "Response: $RESPONSE_BODY_CREATE"
        exit 1
    fi

    # Extract systemId from response
    SYSTEM_ID=$(echo "$RESPONSE_BODY_CREATE" | grep -o '"systemId"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)

    if [ -z "$SYSTEM_ID" ]; then
        echo "✗ Failed to extract systemId from response"
        echo "Response: $RESPONSE_BODY_CREATE"
        exit 1
    fi

    echo "✓ Created new extensionUpload resource"
    echo "  System ID: $SYSTEM_ID"
fi

echo ""

# STEP 2: PATCH extension content
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Uploading extension content..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# PATCH extension content to the created resource
# The extensionContent field expects the binary file directly, not JSON
PATCH_URL="$AUTOMATION_API_BASE($SYSTEM_ID)/extensionContent"

RESPONSE_PATCH=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X PATCH "$PATCH_URL" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/octet-stream" \
    -H "If-Match: *" \
    --data-binary "@$APP_PATH")

HTTP_STATUS_PATCH=$(echo "$RESPONSE_PATCH" | grep "HTTP_STATUS:" | cut -d':' -f2)
RESPONSE_BODY_PATCH=$(echo "$RESPONSE_PATCH" | sed '/HTTP_STATUS:/d')

if [ "$HTTP_STATUS_PATCH" != "200" ] && [ "$HTTP_STATUS_PATCH" != "204" ]; then
    echo "✗ Failed to upload extension content"
    echo "HTTP Status: $HTTP_STATUS_PATCH"
    echo "Response: $RESPONSE_BODY_PATCH"
    exit 1
fi

echo "✓ Extension content uploaded successfully"
echo ""

# STEP 3: Trigger upload via bound action
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Triggering installation..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Call the bound action Microsoft.NAV.upload
UPLOAD_ACTION_URL="$AUTOMATION_API_BASE($SYSTEM_ID)/Microsoft.NAV.upload"

RESPONSE_UPLOAD=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$UPLOAD_ACTION_URL" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -H "Content-Length: 0" \
    -H "Accept: application/json" \
    -d "")

HTTP_STATUS_UPLOAD=$(echo "$RESPONSE_UPLOAD" | grep "HTTP_STATUS:" | cut -d':' -f2)
RESPONSE_BODY_UPLOAD=$(echo "$RESPONSE_UPLOAD" | sed '/HTTP_STATUS:/d')

# Check if upload trigger succeeded
HTTP_STATUS=$HTTP_STATUS_UPLOAD
RESPONSE_BODY=$RESPONSE_BODY_UPLOAD

echo ""

if [ "$HTTP_STATUS" != "200" ] && [ "$HTTP_STATUS" != "201" ] && [ "$HTTP_STATUS" != "204" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✗ FAILED: Extension upload trigger failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "HTTP Status: $HTTP_STATUS"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY"
    echo ""
    exit 1
fi

echo "✓ Upload triggered successfully"
echo ""

# STEP 4: Monitor installation status
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Monitoring installation status..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Construct extensionDeploymentStatus endpoint
if [ "$BC_DEPLOYMENT_TYPE" = "online" ]; then
    DEPLOYMENT_STATUS_URL="https://api.businesscentral.dynamics.com/v2.0/$BC_TENANT_ID/$ENVIRONMENT_NAME/api/microsoft/automation/v2.0/companies($COMPANY_ID)/extensionDeploymentStatus"
else
    DEPLOYMENT_STATUS_URL="$BC_LOCAL_SERVER_URL/$ENVIRONMENT_NAME/api/microsoft/automation/v2.0/companies($COMPANY_ID)/extensionDeploymentStatus"
fi

# Poll deployment status (max 5 minutes, check every 10 seconds)
MAX_ATTEMPTS=30
ATTEMPT=0
DEPLOYMENT_STATUS=""
DEPLOYMENT_OPERATION_TYPE=""

echo "Polling deployment status (checking every 10 seconds)..."
echo ""

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))

    # Query deployment status
    STATUS_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "$DEPLOYMENT_STATUS_URL" \
        -H "$AUTH_HEADER" \
        -H "Accept: application/json")

    STATUS_HTTP=$(echo "$STATUS_RESPONSE" | grep "HTTP_STATUS:" | cut -d':' -f2)
    STATUS_BODY=$(echo "$STATUS_RESPONSE" | sed '/HTTP_STATUS:/d')

    if [ "$STATUS_HTTP" = "200" ]; then
        # Look for our app's deployment status (match by name or operation type = Upload)
        # Extract the latest Upload operation status
        DEPLOYMENT_STATUS=$(echo "$STATUS_BODY" | grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)
        DEPLOYMENT_OPERATION=$(echo "$STATUS_BODY" | grep -o '"operationType"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)
        DEPLOYMENT_NAME=$(echo "$STATUS_BODY" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)
        DEPLOYMENT_VERSION=$(echo "$STATUS_BODY" | grep -o '"appVersion"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | cut -d'"' -f4)

        if [ -n "$DEPLOYMENT_STATUS" ]; then
            echo "[$ATTEMPT] Status: $DEPLOYMENT_STATUS"

            if [ "$DEPLOYMENT_STATUS" = "Completed" ]; then
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "✓ SUCCESS: Extension installed successfully (PTE mode)"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "App:          $DEPLOYMENT_NAME"
                echo "Version:      $DEPLOYMENT_VERSION"
                echo "Environment:  $ENVIRONMENT_NAME"
                echo "Company:      $COMPANY_ID"
                echo "Mode:         PTE (Per-Tenant Extension)"
                echo "Status:       Installed and Ready"
                echo ""
                echo "The extension is now available in Business Central!"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                exit 0
            elif [ "$DEPLOYMENT_STATUS" = "Failed" ]; then
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "✗ FAILED: Extension installation failed"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "App:         $DEPLOYMENT_NAME"
                echo "Version:     $DEPLOYMENT_VERSION"
                echo "Status:      Failed"
                echo ""
                echo "Deployment Status Response:"
                echo "$STATUS_BODY"
                echo ""
                echo "Common Issues:"
                echo "  - App dependencies not met"
                echo "  - Schema sync errors"
                echo "  - App conflicts with existing extensions"
                echo "  - Check BC Event Log for detailed error messages"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                exit 1
            elif [ "$DEPLOYMENT_STATUS" = "InProgress" ] || [ "$DEPLOYMENT_STATUS" = "Scheduled" ]; then
                # Continue polling
                sleep 10
                continue
            else
                echo "  Unknown status: $DEPLOYMENT_STATUS"
                sleep 10
                continue
            fi
        else
            echo "[$ATTEMPT] No deployment status found yet, waiting..."
            sleep 10
            continue
        fi
    else
        echo "[$ATTEMPT] Unable to query deployment status (HTTP $STATUS_HTTP), retrying..."
        sleep 10
        continue
    fi
done

# Timeout reached
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠ TIMEOUT: Installation status check timed out"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The extension upload was triggered but installation is taking longer than expected."
echo ""
echo "Last known status: ${DEPLOYMENT_STATUS:-Unknown}"
echo ""
echo "Next steps:"
echo "  - Check installation manually in BC Admin Center"
echo "  - Run bc_verify to check current installation status"
echo "  - Check BC Event Log for any errors"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 2
