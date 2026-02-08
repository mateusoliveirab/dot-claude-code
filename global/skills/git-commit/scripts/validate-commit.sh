#!/usr/bin/env bash
set -euo pipefail

# Git Commit Helper Script
# Validates commit message format and checks for sensitive files

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_help() {
    cat << 'EOF'
Usage: validate-commit.sh [options]

Validates staged changes before committing.

Options:
    -c, --check-sensitive   Check for sensitive files in staging area
    -m, --message FILE      Validate commit message from file
    -h, --help             Show this help message

Examples:
    validate-commit.sh --check-sensitive
    validate-commit.sh --message commit-msg.txt
EOF
}

check_sensitive_files() {
    local found_sensitive=false
    local sensitive_patterns=(
        "\.env$"
        "\.env\."
        "credentials"
        "secrets"
        "password"
        "token"
        "key\.json$"
    )
    
    echo "Checking for sensitive files in staging area..."
    
    while IFS= read -r file; do
        for pattern in "${sensitive_patterns[@]}"; do
            if echo "$file" | grep -qiE "$pattern"; then
                echo -e "${RED}WARNING: Potentially sensitive file detected: $file${NC}"
                found_sensitive=true
            fi
        done
    done < <(git diff --cached --name-only)
    
    if [ "$found_sensitive" = true ]; then
        echo -e "${YELLOW}Review files above before committing!${NC}"
        return 1
    else
        echo -e "${GREEN}No sensitive files detected.${NC}"
        return 0
    fi
}

validate_message() {
    local msg_file="$1"
    
    if [ ! -f "$msg_file" ]; then
        echo -e "${RED}Error: Message file not found: $msg_file${NC}"
        return 1
    fi
    
    local first_line
    first_line=$(head -1 "$msg_file")
    
    # Check length
    if [ ${#first_line} -gt 50 ]; then
        echo -e "${YELLOW}Warning: First line exceeds 50 characters (${#first_line} chars)${NC}"
    fi
    
    # Check imperative mood (basic check)
    if echo "$first_line" | grep -qE "^(Added|Fixed|Updated|Changed|Removed|Implemented|Created|Deleted)"; then
        echo -e "${YELLOW}Warning: Use imperative mood ('Add' not 'Added')${NC}"
    fi
    
    echo -e "${GREEN}Message validation complete.${NC}"
}

main() {
    case "${1:-}" in
        -c|--check-sensitive)
            check_sensitive_files
            ;;
        -m|--message)
            if [ -z "${2:-}" ]; then
                echo "Error: Message file required"
                exit 1
            fi
            validate_message "$2"
            ;;
        -h|--help|*)
            show_help
            ;;
    esac
}

main "$@"
