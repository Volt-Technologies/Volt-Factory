#!/bin/bash

# Business Central Configuration Validation Script
# Validates .env configuration and tests connectivity

echo "=== Business Central Configuration Validator ==="
echo ""

# Determine workspace root
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output (if supported)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

# Function to print success
print_success() {
    echo -e "${GREEN}✓${NC} $1"
    CHECKS=$((CHECKS + 1))
}

# Function to print error
print_error() {
    echo -e "${RED}✗${NC} $1"
    ERRORS=$((ERRORS + 1))
    CHECKS=$((CHECKS + 1))
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
    CHECKS=$((CHECKS + 1))
}

# Function to load .env file
load_env() {
    local env_file="$WORKSPACE_ROOT/.env"

    if [ ! -f "$env_file" ]; then
        print_error ".env file not found at $env_file"
        echo ""
        echo "Please copy .env.example to .env and configure it:"
        echo "  cp .env.example .env"
        echo ""
        return 1
    fi

    print_success ".env file found"

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

    return 0
}

# Check deployment type
check_deployment_type() {
    echo ""
    echo "Checking Deployment Type..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -z "$BC_DEPLOYMENT_TYPE" ]; then
        print_error "BC_DEPLOYMENT_TYPE not set"
        echo "  Must be 'online' or 'local'"
        return
    fi

    if [ "$BC_DEPLOYMENT_TYPE" != "online" ] && [ "$BC_DEPLOYMENT_TYPE" != "local" ]; then
        print_error "Invalid BC_DEPLOYMENT_TYPE: $BC_DEPLOYMENT_TYPE"
        echo "  Must be 'online' or 'local'"
        return
    fi

    print_success "Deployment type: $BC_DEPLOYMENT_TYPE"
}

# Check environment type
check_environment_type() {
    echo ""
    echo "Checking Environment Type..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -z "$BC_ENVIRONMENT_TYPE" ]; then
        print_error "BC_ENVIRONMENT_TYPE not set"
        echo "  Must be 'sandbox' or 'production'"
        return
    fi

    if [ "$BC_ENVIRONMENT_TYPE" != "sandbox" ] && [ "$BC_ENVIRONMENT_TYPE" != "production" ]; then
        print_error "Invalid BC_ENVIRONMENT_TYPE: $BC_ENVIRONMENT_TYPE"
        echo "  Must be 'sandbox' or 'production'"
        return
    fi

    print_success "Environment type: $BC_ENVIRONMENT_TYPE"

    if [ "$BC_ENVIRONMENT_TYPE" = "production" ]; then
        print_warning "Production environment - use caution!"
    fi
}

# Check environment name
check_environment_name() {
    echo ""
    echo "Checking Environment Name..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -z "$BC_ENVIRONMENT_NAME" ]; then
        print_error "BC_ENVIRONMENT_NAME not set"
        return
    fi

    print_success "Environment name: $BC_ENVIRONMENT_NAME"
}

# Check online authentication
check_online_auth() {
    echo ""
    echo "Checking Online Authentication (OAuth)..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -z "$BC_TENANT_ID" ]; then
        print_error "BC_TENANT_ID not set"
    else
        print_success "Tenant ID configured"
    fi

    if [ -z "$BC_CLIENT_ID" ]; then
        print_error "BC_CLIENT_ID not set"
    else
        print_success "Client ID configured"
    fi

    if [ -z "$BC_CLIENT_SECRET" ]; then
        print_error "BC_CLIENT_SECRET not set"
    else
        print_success "Client secret configured"
    fi

    if [ -n "$BC_OAUTH_SCOPE" ]; then
        print_success "OAuth scope: $BC_OAUTH_SCOPE"
    else
        print_warning "BC_OAUTH_SCOPE not set (will use default)"
    fi
}

# Check local authentication
check_local_auth() {
    echo ""
    echo "Checking Local Authentication (NavUserPassword)..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -z "$BC_LOCAL_USERNAME" ]; then
        print_error "BC_LOCAL_USERNAME not set"
    else
        print_success "Username configured: $BC_LOCAL_USERNAME"
    fi

    if [ -z "$BC_LOCAL_PASSWORD" ]; then
        print_error "BC_LOCAL_PASSWORD not set"
    else
        print_success "Password configured (hidden)"
    fi

    if [ -z "$BC_LOCAL_SERVER_URL" ]; then
        print_error "BC_LOCAL_SERVER_URL not set"
    else
        print_success "Server URL: $BC_LOCAL_SERVER_URL"
    fi
}

# Test authentication
test_authentication() {
    echo ""
    echo "Testing Authentication..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if ! bash "$WORKSPACE_ROOT/scripts/bc-auth.sh" test > /dev/null 2>&1; then
        print_error "Authentication test failed"
        echo "  Run: bash scripts/bc-auth.sh test"
        echo "  For detailed error information"
    else
        print_success "Authentication test passed"
    fi
}

# Check apps root
check_apps_root() {
    echo ""
    echo "Checking Apps Root..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    BC_APPS_ROOT="${BC_APPS_ROOT:-BC}"
    if [[ "$BC_APPS_ROOT" != /* ]]; then
        BC_APPS_ROOT="$WORKSPACE_ROOT/$BC_APPS_ROOT"
    fi

    if [ ! -d "$BC_APPS_ROOT" ]; then
        print_error "Apps root directory not found: $BC_APPS_ROOT"
        return
    fi

    print_success "Apps root exists: $BC_APPS_ROOT"

    # Count app.json files
    APP_COUNT=$(find "$BC_APPS_ROOT" -name "app.json" -type f 2>/dev/null | wc -l)
    if [ "$APP_COUNT" -eq 0 ]; then
        print_warning "No app.json files found in apps root"
    else
        print_success "Found $APP_COUNT app(s)"
    fi
}

# Check company ID
check_company_id() {
    echo ""
    echo "Checking Company ID..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -z "$BC_COMPANY_ID" ]; then
        print_warning "BC_COMPANY_ID not set"
        echo "  Required for some API operations"
        echo "  Set in .env or use --company-id flag"
    else
        print_success "Company ID configured"
    fi
}

# Main validation
main() {
    echo "Validating Business Central configuration..."
    echo ""

    # Load .env
    if ! load_env; then
        exit 1
    fi

    # Check deployment and environment configuration
    check_deployment_type
    check_environment_type
    check_environment_name

    # Check authentication based on deployment type
    if [ "$BC_DEPLOYMENT_TYPE" = "online" ]; then
        check_online_auth
    elif [ "$BC_DEPLOYMENT_TYPE" = "local" ]; then
        check_local_auth
    fi

    # Test authentication
    if [ "$BC_DEPLOYMENT_TYPE" = "online" ] || [ "$BC_DEPLOYMENT_TYPE" = "local" ]; then
        test_authentication
    fi

    # Check other configuration
    check_apps_root
    check_company_ID

    # Print summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "VALIDATION SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total checks: $CHECKS"
    echo -e "${GREEN}Passed: $((CHECKS - ERRORS - WARNINGS))${NC}"
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    echo -e "${RED}Errors: $ERRORS${NC}"
    echo ""

    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}✗ Configuration has errors. Please fix them before proceeding.${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Review errors above"
        echo "  2. Update .env file"
        echo "  3. Run this script again"
        echo ""
        exit 1
    elif [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Configuration has warnings. Review them if needed.${NC}"
        echo ""
        exit 0
    else
        echo -e "${GREEN}✓ Configuration is valid!${NC}"
        echo ""
        echo "You're ready to:"
        echo "  • Compile apps: bc_compile"
        echo "  • Publish to sandbox: bc_publish_sandbox"
        echo "  • Verify apps: bash scripts/bc-verify-app.sh"
        echo ""
        exit 0
    fi
}

# Run validation
main
