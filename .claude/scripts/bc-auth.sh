#!/bin/bash

# Business Central Authentication Script
# Handles both OAuth (online/SaaS) and Basic Auth (local/Docker) authentication
# Returns authorization header for use by other scripts

# Exit on error
set -e

# Determine workspace root (repo root, two directories up from scripts)
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Token cache file
TOKEN_CACHE_FILE="$WORKSPACE_ROOT/.bc_token_cache"

# Function to load .env file
load_env() {
    local env_file="$WORKSPACE_ROOT/.env"

    if [ ! -f "$env_file" ]; then
        echo "Error: .env file not found at $env_file" >&2
        echo "Please copy .env.example to .env and configure it." >&2
        exit 1
    fi

    # Load environment variables
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
        fi
    done < "$env_file"
}

# Function to validate required variables
validate_config() {
    local deployment_type="${1:-$BC_DEPLOYMENT_TYPE}"

    if [ -z "$deployment_type" ]; then
        echo "Error: BC_DEPLOYMENT_TYPE not set in .env" >&2
        echo "Must be 'online' or 'local'" >&2
        exit 1
    fi

    if [ "$deployment_type" = "online" ]; then
        if [ -z "$BC_TENANT_ID" ] || [ -z "$BC_CLIENT_ID" ] || [ -z "$BC_CLIENT_SECRET" ]; then
            echo "Error: Online authentication requires BC_TENANT_ID, BC_CLIENT_ID, and BC_CLIENT_SECRET" >&2
            echo "Please configure these in your .env file" >&2
            exit 1
        fi
    elif [ "$deployment_type" = "local" ]; then
        if [ -z "$BC_LOCAL_USERNAME" ] || [ -z "$BC_LOCAL_PASSWORD" ]; then
            echo "Error: Local authentication requires BC_LOCAL_USERNAME and BC_LOCAL_PASSWORD" >&2
            echo "Please configure these in your .env file" >&2
            exit 1
        fi
    else
        echo "Error: Invalid BC_DEPLOYMENT_TYPE: $deployment_type" >&2
        echo "Must be 'online' or 'local'" >&2
        exit 1
    fi
}

# Function to check if cached token is still valid
is_token_valid() {
    if [ ! -f "$TOKEN_CACHE_FILE" ]; then
        return 1
    fi

    # Read cached token and expiry
    local cached_token=$(grep "^ACCESS_TOKEN=" "$TOKEN_CACHE_FILE" | cut -d'=' -f2-)
    local expiry_time=$(grep "^EXPIRY=" "$TOKEN_CACHE_FILE" | cut -d'=' -f2-)

    if [ -z "$cached_token" ] || [ -z "$expiry_time" ]; then
        return 1
    fi

    # Check if token has expired (with 5 minute buffer)
    local current_time=$(date +%s)
    local buffer=300  # 5 minutes

    if [ $((current_time + buffer)) -ge "$expiry_time" ]; then
        return 1
    fi

    # Token is still valid
    echo "$cached_token"
    return 0
}

# Function to acquire OAuth access token
acquire_oauth_token() {
    echo "Acquiring OAuth access token..." >&2

    local tenant_id="$BC_TENANT_ID"
    local client_id="$BC_CLIENT_ID"
    local client_secret="$BC_CLIENT_SECRET"
    local scope="${BC_OAUTH_SCOPE:-https://api.businesscentral.dynamics.com/.default}"

    local token_url="https://login.microsoftonline.com/$tenant_id/oauth2/v2.0/token"

    # Request access token
    local response=$(curl -s -X POST "$token_url" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials" \
        -d "client_id=$client_id" \
        -d "client_secret=$client_secret" \
        -d "scope=$scope")

    # Check for errors
    if echo "$response" | grep -q "error"; then
        echo "Error acquiring OAuth token:" >&2
        echo "$response" | grep -o '"error_description":"[^"]*"' | cut -d'"' -f4 >&2
        exit 1
    fi

    # Extract access token and expires_in
    local access_token=$(echo "$response" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    local expires_in=$(echo "$response" | grep -o '"expires_in":[0-9]*' | cut -d':' -f2)

    if [ -z "$access_token" ]; then
        echo "Error: Failed to extract access token from response" >&2
        exit 1
    fi

    # Calculate expiry time
    local current_time=$(date +%s)
    local expiry_time=$((current_time + expires_in))

    # Cache the token
    echo "ACCESS_TOKEN=$access_token" > "$TOKEN_CACHE_FILE"
    echo "EXPIRY=$expiry_time" >> "$TOKEN_CACHE_FILE"
    chmod 600 "$TOKEN_CACHE_FILE"  # Protect token file

    echo "✓ OAuth token acquired successfully (expires in ${expires_in}s)" >&2
    echo "$access_token"
}

# Function to get OAuth token (with caching)
get_oauth_token() {
    # Try to use cached token
    local cached_token=$(is_token_valid)
    if [ $? -eq 0 ] && [ -n "$cached_token" ]; then
        echo "Using cached OAuth token" >&2
        echo "$cached_token"
        return 0
    fi

    # Acquire new token
    acquire_oauth_token
}

# Function to create Basic Auth header value
create_basic_auth() {
    local username="$BC_LOCAL_USERNAME"
    local password="$BC_LOCAL_PASSWORD"

    # Create base64 encoded credentials
    local credentials=$(echo -n "$username:$password" | base64)

    echo "$credentials"
}

# Function to get authorization header
get_auth_header() {
    local deployment_type="${BC_DEPLOYMENT_TYPE}"

    if [ "$deployment_type" = "online" ]; then
        # OAuth Bearer token
        local token=$(get_oauth_token)
        echo "Authorization: Bearer $token"
    elif [ "$deployment_type" = "local" ]; then
        # Basic authentication
        local credentials=$(create_basic_auth)
        echo "Authorization: Basic $credentials"
    else
        echo "Error: Invalid deployment type: $deployment_type" >&2
        exit 1
    fi
}

# Main execution
main() {
    local command="${1:-get-header}"

    # Load environment
    load_env

    # Validate configuration
    validate_config

    case "$command" in
        get-header)
            # Return authorization header
            get_auth_header
            ;;
        get-token)
            # Return just the token/credentials (for advanced use)
            if [ "$BC_DEPLOYMENT_TYPE" = "online" ]; then
                get_oauth_token
            else
                create_basic_auth
            fi
            ;;
        clear-cache)
            # Clear token cache
            if [ -f "$TOKEN_CACHE_FILE" ]; then
                rm -f "$TOKEN_CACHE_FILE"
                echo "Token cache cleared" >&2
            else
                echo "No token cache to clear" >&2
            fi
            ;;
        test)
            # Test authentication
            echo "Testing authentication..." >&2
            echo "Deployment type: $BC_DEPLOYMENT_TYPE" >&2
            echo "Environment: $BC_ENVIRONMENT_NAME" >&2
            echo "" >&2

            local auth_header=$(get_auth_header)
            if [ $? -eq 0 ]; then
                echo "✓ Authentication successful" >&2
                echo "Auth header: ${auth_header:0:50}..." >&2
                exit 0
            else
                echo "✗ Authentication failed" >&2
                exit 1
            fi
            ;;
        --help|help)
            echo "Business Central Authentication Script"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  get-header    Get complete authorization header (default)"
            echo "  get-token     Get just the token/credentials"
            echo "  clear-cache   Clear cached OAuth token"
            echo "  test          Test authentication configuration"
            echo "  help          Show this help message"
            echo ""
            echo "Configuration:"
            echo "  Edit .env file to configure authentication"
            echo "  See .env.example for configuration template"
            ;;
        *)
            echo "Unknown command: $command" >&2
            echo "Use '$0 help' for usage information" >&2
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
