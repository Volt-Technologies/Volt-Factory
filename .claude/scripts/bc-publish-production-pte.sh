#!/bin/bash

# Business Central Production PTE Publishing Script
# Publishes BC apps to production environment using PTE (Per-Tenant Extension) mode
# Production-safe with validation and confirmation steps

echo "=== Business Central Production PTE Publishing ==="
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
SKIP_CONFIRMATION=false

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
        --yes|--confirm)
            SKIP_CONFIRMATION=true
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
            echo "  --yes, --confirm             Skip confirmation prompt"
            echo "  --help                       Show this help message"
            echo ""
            echo "Environment Configuration:"
            echo "  Configure .env file with deployment settings"
            echo "  BC_ENVIRONMENT_TYPE must be set to 'production'"
            echo "  BC_DEPLOYMENT_TYPE must be set to 'online' (local production not supported)"
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

echo "⚠ PRODUCTION DEPLOYMENT ⚠"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Deployment Type:   $BC_DEPLOYMENT_TYPE"
echo "Environment Type:  $BC_ENVIRONMENT_TYPE"
echo "Environment Name:  $ENVIRONMENT_NAME"
echo "Company ID:        ${COMPANY_ID:-Not specified}"
echo "Install Deps:      $INSTALL_DEPENDENCIES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate environment type (PTE only for production)
if [ "$BC_ENVIRONMENT_TYPE" != "production" ]; then
    echo "Error: This script is for production environments only"
    echo "Current environment type: $BC_ENVIRONMENT_TYPE"
    echo ""
    echo "For sandbox environments, use:"
    echo "  - bc-publish-sandbox-dev.sh (for dev mode)"
    echo "  - bc-publish-sandbox-pte.sh (for PTE mode)"
    exit 1
fi

# Validate deployment type (production assumed to be online)
if [ "$BC_DEPLOYMENT_TYPE" != "online" ]; then
    echo "Error: Production PTE publishing only supports online/SaaS deployments"
    echo "Current deployment type: $BC_DEPLOYMENT_TYPE"
    echo ""
    echo "If you need to publish to local production, please use:"
    echo "  - Admin Center portal for manual deployment"
    echo "  - Custom deployment scripts for on-premises"
    exit 1
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

# Try to extract app ID from app.json
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

# Confirmation prompt
if [ "$SKIP_CONFIRMATION" = false ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠  PRODUCTION DEPLOYMENT CONFIRMATION  ⚠"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "You are about to deploy to a PRODUCTION environment."
    echo "This action will affect live users and data."
    echo ""
    echo "Target Environment: $ENVIRONMENT_NAME"
    echo "App to Deploy:      $APP_NAME"
    if [ -n "$APP_VERSION" ]; then
        echo "App Version:        $APP_VERSION"
    fi
    echo ""
    echo "Please ensure:"
    echo "  ✓ App has been tested thoroughly in sandbox"
    echo "  ✓ All dependencies are available in target environment"
    echo "  ✓ Database changes are backward compatible"
    echo "  ✓ Deployment is scheduled during maintenance window"
    echo "  ✓ Rollback plan is in place"
    echo ""
    read -p "Type 'DEPLOY' to confirm production deployment: " CONFIRMATION
    echo ""

    if [ "$CONFIRMATION" != "DEPLOY" ]; then
        echo "Deployment cancelled by user."
        exit 0
    fi
fi

# Get authentication
echo "Authenticating..."
AUTH_HEADER=$(bash "$WORKSPACE_ROOT/scripts/bc-auth.sh" get-header)

if [ $? -ne 0 ]; then
    echo "Error: Authentication failed"
    exit 1
fi

echo "✓ Authentication successful"
echo ""

# Construct PTE API endpoint
# Note: Using Admin Center API for production PTE deployment
# API endpoint for uploading/installing extensions

if [ -n "$APP_ID" ]; then
    # Use app ID based endpoint
    API_URL="https://api.businesscentral.dynamics.com/admin/v2.25/applications/businesscentral/environments/$ENVIRONMENT_NAME/apps/$APP_ID"

    echo "Publishing via Admin Center API (PTE mode)..."
    echo "URL: $API_URL"
    echo ""
    echo "⚠ Note: Production PTE publishing requires Admin Center API access"
    echo "This script uses a simplified PTE workflow."
    echo ""
    echo "For full PTE deployment with app signing and validation:"
    echo "  1. Sign your app with a code signing certificate"
    echo "  2. Upload via AppSource or direct install"
    echo "  3. Use BC Admin Center portal for deployment"
    echo ""

    # Note: The actual PTE installation via API requires:
    # 1. App to be uploaded to a staging area
    # 2. Separate install command with app package ID
    # 3. Proper app signing for production

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠ PRODUCTION PTE DEPLOYMENT LIMITATION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Full automated production PTE deployment via API requires:"
    echo "  • App code signing certificate"
    echo "  • Multi-step upload and installation process"
    echo "  • Admin Center API permissions"
    echo ""
    echo "RECOMMENDED APPROACH for production:"
    echo "  1. Upload .app file manually via BC Admin Center"
    echo "  2. Install extension through Admin Center portal"
    echo "  3. Or use this script for sandbox PTE testing:"
    echo "     bc-publish-sandbox-pte.sh"
    echo ""
    echo "Your app file is ready at: $APP_PATH"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    exit 0
else
    echo "Error: Could not extract app ID from app.json"
    echo "App ID is required for PTE deployment"
    exit 1
fi
