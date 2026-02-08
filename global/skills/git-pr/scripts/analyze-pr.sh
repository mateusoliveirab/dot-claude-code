#!/usr/bin/env bash
set -euo pipefail

# Git PR Helper Script
# Analyzes branch changes and generates PR content

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << 'EOF'
Usage: analyze-pr.sh [target-branch]

Analyzes current branch and generates PR summary.

Arguments:
    target-branch    Target branch for PR (default: main)

Examples:
    analyze-pr.sh
    analyze-pr.sh main
    analyze-pr.sh develop
EOF
}

get_pr_summary() {
    local target_branch="${1:-main}"
    local current_branch
    current_branch=$(git branch --show-current)
    
    echo ""
    echo -e "${BLUE}=== PR Analysis ===${NC}"
    echo ""
    
    # Check if branch tracks remote
    if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
        local remote_branch
        remote_branch=$(git rev-parse --abbrev-ref @{u})
        echo -e "${GREEN}Branch:${NC} $current_branch → $remote_branch"
    else
        echo -e "${YELLOW}Branch:${NC} $current_branch (no remote tracking)"
    fi
    
    # Count commits
    local commit_count
    commit_count=$(git log "$target_branch..HEAD" --oneline | wc -l)
    echo -e "${GREEN}Commits ahead of $target_branch:${NC} $commit_count"
    
    # Show files changed
    echo ""
    echo -e "${BLUE}Files Changed:${NC}"
    git diff --name-status "$target_branch...HEAD" | head -20
    
    local file_count
    file_count=$(git diff --name-only "$target_branch...HEAD" | wc -l)
    if [ "$file_count" -gt 20 ]; then
        echo -e "${YELLOW}... and $((file_count - 20)) more files${NC}"
    fi
    
    # Show commit summary
    echo ""
    echo -e "${BLUE}Commits:${NC}"
    git log "$target_branch..HEAD" --oneline --no-decorate
}

check_pr_ready() {
    local target_branch="${1:-main}"
    local issues=0
    
    echo ""
    echo -e "${BLUE}=== PR Readiness Check ===${NC}"
    echo ""
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}⚠️  Uncommitted changes present${NC}"
        ((issues++))
    else
        echo -e "${GREEN}✓ Working tree clean${NC}"
    fi
    
    # Check if branch is behind target
    local behind_count
    behind_count=$(git rev-list --count HEAD.."$target_branch" 2>/dev/null || echo "0")
    if [ "$behind_count" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Branch is $behind_count commits behind $target_branch${NC}"
        ((issues++))
    else
        echo -e "${GREEN}✓ Branch is up to date with $target_branch${NC}"
    fi
    
    if [ $issues -eq 0 ]; then
        echo -e "\n${GREEN}✓ PR is ready!${NC}"
        return 0
    else
        echo -e "\n${YELLOW}! Fix issues above before creating PR${NC}"
        return 1
    fi
}

main() {
    case "${1:-}" in
        -h|--help)
            show_help
            ;;
        *)
            local target="${1:-main}"
            get_pr_summary "$target"
            check_pr_ready "$target"
            ;;
    esac
}

main "$@"
