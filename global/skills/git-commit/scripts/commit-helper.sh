#!/usr/bin/env bash
set -euo pipefail

# Git Commit Helper
# Analyzes changes, suggests commits and validates format

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
Git Commit Helper

Usage: commit-helper.sh <command>

Commands:
    analyze     Analyze changes and group by functionality
    suggest     Suggest commit message based on staged files
    validate    Validate message format
    summary     Show analysis summary
    help        Show this help

Examples:
    commit-helper.sh analyze
    commit-helper.sh suggest
    commit-helper.sh validate "feat: add new feature"
EOF
}

analyze_changes() {
    log_info "Analyzing changes..."
    echo ""
    
    local files
    files=$(git status --porcelain 2>/dev/null || true)
    
    if [[ -z "$files" ]]; then
        log_warn "No changes detected"
        return 0
    fi
    
    # Group by type
    local feat_files=""
    local fix_files=""
    local docs_files=""
    local test_files=""
    local other_files=""
    
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        local status="${line:0:2}"
        local file="${line:3}"
        
        # Detect type based on filename
        if [[ "$file" =~ ^(docs?/|README|CHANGELOG|\.md$) ]]; then
            docs_files+="  - [$status] $file\n"
        elif [[ "$file" =~ ^(test|spec|__tests__|\.test\.|\.spec\.) ]]; then
            test_files+="  - [$status] $file\n"
        elif [[ "$file" =~ (fix|bug|hotfix|patch) ]]; then
            fix_files+="  - [$status] $file\n"
        elif [[ "$file" =~ (feat|feature|add|new) ]]; then
            feat_files+="  - [$status] $file\n"
        else
            other_files+="  - [$status] $file\n"
        fi
    done <<< "$files"
    
    echo -e "${CYAN}=== Files by Category ===${NC}"
    echo ""
    
    if [[ -n "$feat_files" ]]; then
        echo -e "${GREEN}feat (new features):${NC}"
        echo -e "$feat_files"
    fi
    
    if [[ -n "$fix_files" ]]; then
        echo -e "${YELLOW}fix (bug fixes):${NC}"
        echo -e "$fix_files"
    fi
    
    if [[ -n "$docs_files" ]]; then
        echo -e "${BLUE}docs (documentation):${NC}"
        echo -e "$docs_files"
    fi
    
    if [[ -n "$test_files" ]]; then
        echo -e "${CYAN}test (tests):${NC}"
        echo -e "$test_files"
    fi
    
    if [[ -n "$other_files" ]]; then
        echo -e "${NC}others:${NC}"
        echo -e "$other_files"
    fi
    
    echo ""
    log_info "Tip: Group related files and commit by functionality"
}

suggest_commit() {
    log_info "Analyzing staged files to suggest commit..."
    echo ""
    
    local staged
    staged=$(git diff --cached --name-only 2>/dev/null || true)
    
    if [[ -z "$staged" ]]; then
        log_warn "No staged files. Use 'git add' first."
        return 1
    fi
    
    # Count types
    local feat_count=0
    local fix_count=0
    local docs_count=0
    local test_count=0
    local other_count=0
    
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        
        if [[ "$file" =~ ^(docs?/|README|CHANGELOG|\.md$) ]]; then
            docs_count=$((docs_count + 1))
        elif [[ "$file" =~ ^(test|spec|__tests__|\.test\.|\.spec\.) ]]; then
            test_count=$((test_count + 1))
        elif [[ "$file" =~ (fix|bug|hotfix) ]]; then
            fix_count=$((fix_count + 1))
        elif [[ "$file" =~ (feat|feature|add) ]]; then
            feat_count=$((feat_count + 1))
        else
            other_count=$((other_count + 1))
        fi
    done <<< "$staged"
    
    # Determine predominant type
    local suggested_type="chore"
    local max_count=$other_count
    
    if [[ $feat_count -gt $max_count ]]; then
        suggested_type="feat"
        max_count=$feat_count
    fi
    if [[ $fix_count -gt $max_count ]]; then
        suggested_type="fix"
        max_count=$fix_count
    fi
    if [[ $docs_count -gt $max_count ]]; then
        suggested_type="docs"
        max_count=$docs_count
    fi
    if [[ $test_count -gt $max_count ]]; then
        suggested_type="test"
        max_count=$test_count
    fi
    
    echo -e "${CYAN}=== Commit Suggestion ===${NC}"
    echo ""
    echo -e "Suggested type: ${GREEN}$suggested_type${NC}"
    echo ""
    echo "Staged files:"
    echo "$staged" | sed 's/^/  - /'
    echo ""
    echo -e "${YELLOW}Example message:${NC}"
    echo "  $suggested_type: <brief description of what changes>"
    echo ""
    echo "Commands:"
    echo "  git commit -m \"$suggested_type: your description here\""
}

validate_message() {
    local message="${1:-}"
    
    if [[ -z "$message" ]]; then
        log_error "No message provided"
        return 1
    fi
    
    log_info "Validating message: $message"
    echo ""
    
    local errors=0
    
    # Check type
    if ! echo "$message" | grep -qE '^(feat|fix|docs|style|refactor|test|chore)(\([a-z-]+\))?:'; then
        log_error "Invalid type. Use: feat, fix, docs, style, refactor, test, or chore"
        errors=$((errors + 1))
    else
        log_ok "Valid type"
    fi
    
    # Check length
    local first_line
    first_line=$(echo "$message" | head -1)
    if [[ ${#first_line} -gt 50 ]]; then
        log_warn "First line is ${#first_line} characters (max: 50)"
    else
        log_ok "First line length: ${#first_line} characters"
    fi
    
    # Check imperative mood
    if echo "$first_line" | grep -qE '^(feat|fix|docs|style|refactor|test|chore): (Added|Fixed|Updated|Changed|Removed|Implemented|Created|Deleted)'; then
        log_warn "Use imperative mood: 'Add' instead of 'Added'"
    else
        log_ok "Imperative mood correct"
    fi
    
    echo ""
    if [[ $errors -eq 0 ]]; then
        log_ok "Message is valid!"
        return 0
    else
        log_error "Message is invalid ($errors error(s))"
        return 1
    fi
}

show_summary() {
    log_info "Analysis Summary"
    echo ""
    
    local modified
    modified=$(git status --porcelain 2>/dev/null | wc -l)
    local staged
    staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
    local unstaged
    unstaged=$((modified - staged))
    
    echo -e "${CYAN}=== Status ===${NC}"
    echo -e "Modified files: ${YELLOW}$modified${NC}"
    echo -e "Staged files: ${GREEN}$staged${NC}"
    echo -e "Unstaged files: ${YELLOW}$unstaged${NC}"
    echo ""
    
    if [[ $staged -gt 0 ]]; then
        log_ok "Ready to commit"
        echo "  Use: git commit -m \"type: description\""
    elif [[ $modified -gt 0 ]]; then
        log_warn "Modified files but not staged"
        echo "  Use: git add <files>"
    else
        log_info "Working tree clean"
    fi
}

main() {
    case "${1:-help}" in
        analyze)
            analyze_changes
            ;;
        suggest)
            suggest_commit
            ;;
        validate)
            shift
            validate_message "$*"
            ;;
        summary)
            show_summary
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
