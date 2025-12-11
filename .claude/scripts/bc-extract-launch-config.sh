#!/bin/bash

# Business Central launch.json Configuration Extractor
# Extracts environment configuration from VS Code launch.json
# and suggests .env configuration values

echo "=== Business Central launch.json Configuration Extractor ==="
echo ""

# Determine workspace root
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default launch.json location
BC_APPS_ROOT="${BC_APPS_ROOT:-BC}"
if [[ "$BC_APPS_ROOT" != /* ]]; then
    BC_APPS_ROOT="$WORKSPACE_ROOT/$BC_APPS_ROOT"
fi

LAUNCH_JSON="$BC_APPS_ROOT/.vscode/launch.json"

# Check if launch.json exists
if [ ! -f "$LAUNCH_JSON" ]; then
    echo "Error: launch.json not found at $LAUNCH_JSON"
    echo ""
    echo "Searched in: $BC_APPS_ROOT/.vscode/launch.json"
    echo ""
    echo "Please ensure:"
    echo "  1. You have a BC app in the BC folder"
    echo "  2. The app has .vscode/launch.json configured"
    echo "  3. BC_APPS_ROOT in .env points to the correct directory"
    echo ""
    exit 1
fi

echo "Found launch.json: $LAUNCH_JSON"
echo ""

# Function to extract JSON value
extract_json_value() {
    local file="$1"
    local key="$2"
    local value=$(grep -m 1 "\"$key\"" "$file" | sed 's/.*"'"$key"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    echo "$value"
}

# Extract configuration values
echo "Extracting configuration..."
echo ""

CONFIG_NAME=$(extract_json_value "$LAUNCH_JSON" "name")
ENV_TYPE=$(extract_json_value "$LAUNCH_JSON" "environmentType")
ENV_NAME=$(extract_json_value "$LAUNCH_JSON" "environmentName")
TENANT_ID=$(extract_json_value "$LAUNCH_JSON" "tenant")

# Display found configuration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Configuration Found in launch.json"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -n "$CONFIG_NAME" ]; then
    echo "Configuration Name: $CONFIG_NAME"
fi

if [ -n "$ENV_TYPE" ]; then
    echo "Environment Type:   $ENV_TYPE"
fi

if [ -n "$ENV_NAME" ]; then
    echo "Environment Name:   $ENV_NAME"
fi

if [ -n "$TENANT_ID" ]; then
    echo "Tenant ID:          $TENANT_ID"
fi

echo ""

# Determine deployment type
DEPLOYMENT_TYPE="online"  # Default assumption for launch.json configurations

# Determine environment type
if [ -z "$ENV_TYPE" ]; then
    SUGGESTED_ENV_TYPE="sandbox"
else
    # Convert to lowercase and map
    ENV_TYPE_LOWER=$(echo "$ENV_TYPE" | tr '[:upper:]' '[:lower:]')
    if [ "$ENV_TYPE_LOWER" = "sandbox" ]; then
        SUGGESTED_ENV_TYPE="sandbox"
    elif [ "$ENV_TYPE_LOWER" = "production" ]; then
        SUGGESTED_ENV_TYPE="production"
    else
        SUGGESTED_ENV_TYPE="sandbox"
    fi
fi

# Generate suggested .env configuration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Suggested .env Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Add these values to your .env file:"
echo ""
echo "# ============================================================================"
echo "# PUBLISHING CONFIGURATION (extracted from launch.json)"
echo "# ============================================================================"
echo ""
echo "# Deployment type"
echo "BC_DEPLOYMENT_TYPE=$DEPLOYMENT_TYPE"
echo ""
echo "# Environment type"
echo "BC_ENVIRONMENT_TYPE=$SUGGESTED_ENV_TYPE"
echo ""

if [ -n "$ENV_NAME" ]; then
    echo "# Environment name"
    echo "BC_ENVIRONMENT_NAME=$ENV_NAME"
    echo ""
fi

if [ -n "$TENANT_ID" ]; then
    echo "# Tenant ID"
    echo "BC_TENANT_ID=$TENANT_ID"
    echo ""
fi

echo "# Authentication (online/SaaS)"
echo "# Get these from Azure AD App Registration:"
echo "BC_CLIENT_ID=your-app-client-id-here"
echo "BC_CLIENT_SECRET=your-app-secret-here"
echo ""
echo "# Company ID (optional)"
echo "# Get from BC: Search 'Companies' → API Setup"
echo "BC_COMPANY_ID=your-company-id-here"
echo ""

# Additional notes
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Create Azure AD App Registration:"
echo "   - Go to https://portal.azure.com"
echo "   - Navigate to Azure Active Directory → App registrations"
echo "   - Create new registration"
echo "   - Grant API permission: Automation.ReadWrite.All"
echo "   - Grant admin consent"
echo "   - Copy client ID and create client secret"
echo ""
echo "2. Update .env file:"
echo "   - Copy the suggested configuration above"
echo "   - Add your Azure AD app credentials"
echo "   - Save the file"
echo ""
echo "3. Validate configuration:"
echo "   bash scripts/bc-config-validate.sh"
echo ""
echo "4. Test authentication:"
echo "   bash scripts/bc-auth.sh test"
echo ""
echo "5. Start publishing:"
echo "   bc_compile"
echo "   bc_publish_sandbox"
echo ""

# Offer to append to .env
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -f "$WORKSPACE_ROOT/.env" ]; then
    echo "Note: .env file does not exist yet."
    echo "Copy .env.example to .env first:"
    echo "  cp .env.example .env"
    echo ""
else
    read -p "Would you like to append this configuration to your .env file? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> "$WORKSPACE_ROOT/.env"
        echo "# Configuration extracted from launch.json on $(date)" >> "$WORKSPACE_ROOT/.env"
        echo "BC_DEPLOYMENT_TYPE=$DEPLOYMENT_TYPE" >> "$WORKSPACE_ROOT/.env"
        echo "BC_ENVIRONMENT_TYPE=$SUGGESTED_ENV_TYPE" >> "$WORKSPACE_ROOT/.env"

        if [ -n "$ENV_NAME" ]; then
            echo "BC_ENVIRONMENT_NAME=$ENV_NAME" >> "$WORKSPACE_ROOT/.env"
        fi

        if [ -n "$TENANT_ID" ]; then
            echo "BC_TENANT_ID=$TENANT_ID" >> "$WORKSPACE_ROOT/.env"
        fi

        echo "BC_CLIENT_ID=your-app-client-id-here" >> "$WORKSPACE_ROOT/.env"
        echo "BC_CLIENT_SECRET=your-app-secret-here" >> "$WORKSPACE_ROOT/.env"
        echo "BC_COMPANY_ID=your-company-id-here" >> "$WORKSPACE_ROOT/.env"

        echo ""
        echo "✓ Configuration appended to .env"
        echo ""
        echo "Remember to update the placeholder values:"
        echo "  - BC_CLIENT_ID"
        echo "  - BC_CLIENT_SECRET"
        echo "  - BC_COMPANY_ID"
        echo ""
    else
        echo "Configuration not appended. Copy manually if needed."
        echo ""
    fi
fi

echo "For detailed authentication setup, see:"
echo "  docs/AUTHENTICATION.md"
echo ""
