#!/usr/bin/env bash
set -euo pipefail

# Git PR Helper
# Analyzes branch and generates PR content

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

show_help() {
    cat << 'EOF'
Git PR Helper

Usage: pr-helper.sh <command> [target-branch]

Commands:
    analyze [target]   Analyze branch changes
    generate [target]  Generate complete PR content
    summary [target]   Show branch summary
    help               Show this help

Arguments:
    target-branch      Target branch (default: main)

Examples:
    pr-helper.sh analyze
    pr-helper.sh analyze develop
    pr-helper.sh generate main
EOF
}

detect_change_type() {
    local files="$1"
    local feat=0 fix=0 docs=0 test=0 chore=0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        if [[ "$file" =~ ^(docs?/|README|CHANGELOG|.*\.md)$ ]]; then
            docs=$((docs + 1))
        elif [[ "$file" =~ ^(test|spec|__tests__/|.*\.(test|spec)\.) ]]; then
            test=$((test + 1))
        elif [[ "$file" =~ (fix|bug|hotfix) ]]; then
            fix=$((fix + 1))
        elif [[ "$file" =~ (feat|feature) ]]; then
            feat=$((feat + 1))
        else
            chore=$((chore + 1))
        fi
    done <<< "$files"
    
    # Return most frequent type
    local max_val=$chore
    local max_type="chore"
    
    [[ $feat -gt $max_val ]] && { max_val=$feat; max_type="feat"; }
    [[ $fix -gt $max_val ]] && { max_val=$fix; max_type="fix"; }
    [[ $docs -gt $max_val ]] && { max_val=$docs; max_type="docs"; }
    [[ $test -gt $max_val ]] && { max_val=$test; max_type="test"; }
    
    echo "$max_type"
}

get_commit_messages() {
    local target="$1"
    git log "$target..HEAD" --format="%s" --no-merges 2>/dev/null || echo ""
}

analyze_branch() {
    local target="${1:-main}"
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    log_info "Analyzing branch: $current_branch → $target"
    echo ""
    
    # Check if branch exists
    if ! git rev-parse "$target" >/dev/null 2>&1; then
        log_error "Target branch '$target' not found"
        return 1
    fi
    
    # Get changes
    local files_changed
    files_changed=$(git diff --name-only "$target...HEAD" 2>/dev/null || true)
    local file_count
    file_count=$(echo "$files_changed" | grep -c '^' || echo "0")
    
    local commit_count
    commit_count=$(git rev-list --count "$target..HEAD" 2>/dev/null || echo "0")
    
    # Detect type
    local change_type
    change_type=$(detect_change_type "$files_changed")
    
    echo -e "${CYAN}=== Branch Analysis ===${NC}"
    echo ""
    echo -e "Current branch: ${GREEN}$current_branch${NC}"
    echo -e "Target branch: ${GREEN}$target${NC}"
    echo -e "Commits ahead: ${YELLOW}$commit_count${NC}"
    echo -e "Files changed: ${YELLOW}$file_count${NC}"
    echo -e "Detected type: ${GREEN}$change_type${NC}"
    echo ""
    
    if [[ $file_count -gt 0 ]]; then
        echo -e "${CYAN}Changed Files:${NC}"
        echo "$files_changed" | head -20 | sed 's/^/  - /'
        [[ $file_count -gt 20 ]] && echo "  ... and $((file_count - 20)) more"
        echo ""
    fi
    
    if [[ $commit_count -gt 0 ]]; then
        echo -e "${CYAN}Commit Messages:${NC}"
        git log "$target..HEAD" --oneline --no-merges | head -10 | sed 's/^/  /'
        [[ $commit_count -gt 10 ]] && echo "  ... and $((commit_count - 10)) more"
    fi
}

generate_pr() {
    local target="${1:-main}"
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    log_info "Generating PR content for $current_branch → $target"
    echo ""
    
    # Get data
    local files_changed
    files_changed=$(git diff --name-only "$target...HEAD" 2>/dev/null || true)
    local change_type
    change_type=$(detect_change_type "$files_changed")
    local commit_count
    commit_count=$(git rev-list --count "$target..HEAD" 2>/dev/null || echo "0")
    
    # Generate title
    local title
    title="$change_type: "
    
    # Try to extract from commits
    local first_commit
    first_commit=$(git log "$target..HEAD" --format="%s" --no-merges --reverse | head -1)
    if [[ -n "$first_commit" ]]; then
        # Remove type prefix if exists
        title+="$(echo "$first_commit" | sed -E 's/^(feat|fix|docs|style|refactor|test|chore)(\([^)]+\))?: ?//')"
    else
        title+="update $current_branch"
    fi
    
    # Generate changes table
    local changes_table=""
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        local change_desc="Modified"
        if [[ "$file" =~ ^(feat|feature) ]]; then
            change_desc="New feature"
        elif [[ "$file" =~ (fix|bug) ]]; then
            change_desc="Bug fix"
        elif [[ "$file" =~ ^(docs?|README) ]]; then
            change_desc="Documentation"
        elif [[ "$file" =~ ^(test|spec) ]]; then
            change_desc="Tests"
        fi
        
        changes_table+="| \`$file\` | $change_desc |\n"
    done <<< "$files_changed"
    
    # Output PR content
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}           PR TITLE${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo "$title"
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}        PR DESCRIPTION${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    cat << EOF
## Summary
Brief overview of what this PR accomplishes.

## What, Why & Benefits

**What:**
- Describe what changes are being made
- Include key modifications

**Why:**
Explain the motivation behind these changes and the problem being solved.

**Benefits:**
- Benefit 1: What improves?
- Benefit 2: What problems are solved?

## Validation
- [ ] Code follows project conventions
- [ ] Self-review completed
- [ ] No sensitive data in changes
- [ ] Tests pass locally

## Changes
| File | Change |
|------|--------|
$changes_table

## Testing/Validations
- [ ] Tested locally
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
EOF
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${GREEN}Copy the title and description above${NC}"
    echo -e "${GREEN}Open PR manually at your repository${NC}"
    echo -e "${CYAN}========================================${NC}"
}

show_summary() {
    local target="${1:-main}"
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    log_info "Branch Summary: $current_branch"
    echo ""
    
    local commit_count
    commit_count=$(git rev-list --count "$target..HEAD" 2>/dev/null || echo "0")
    local file_count
    file_count=$(git diff --name-only "$target...HEAD" 2>/dev/null | wc -l)
    local behind_count
    behind_count=$(git rev-list --count HEAD.."$target" 2>/dev/null || echo "0")
    
    echo -e "${CYAN}=== Status ===${NC}"
    echo -e "Branch: ${GREEN}$current_branch${NC}"
    echo -e "Target: ${GREEN}$target${NC}"
    echo -e "Commits ahead: ${YELLOW}$commit_count${NC}"
    echo -e "Commits behind: ${YELLOW}$behind_count${NC}"
    echo -e "Files changed: ${YELLOW}$file_count${NC}"
    echo ""
    
    # Check working tree
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_warn "Uncommitted changes present"
    else
        log_ok "Working tree clean"
    fi
    
    # Check if behind
    if [[ $behind_count -gt 0 ]]; then
        log_warn "Branch is $behind_count commits behind $target"
        echo "  Run: git pull origin $target"
    fi
    
    if [[ $commit_count -eq 0 ]]; then
        log_info "No commits to merge"
    elif [[ $commit_count -gt 0 && $behind_count -eq 0 ]]; then
        log_ok "Ready to create PR"
        echo "  Run: pr-helper.sh generate"
    fi
}

main() {
    local cmd="${1:-help}"
    local target="${2:-main}"
    
    case "$cmd" in
        analyze)
            analyze_branch "$target"
            ;;
        generate)
            generate_pr "$target"
            ;;
        summary)
            show_summary "$target"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $cmd"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
