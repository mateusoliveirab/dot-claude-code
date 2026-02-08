#!/usr/bin/env bash
set -euo pipefail

# Skill Helper Script Template
# 
# Description:
#   Brief description of what this script does
#
# Usage:
#   helper.sh [options] <command>
#
# Commands:
#   command1    Description of command1
#   command2    Description of command2
#
# Options:
#   -h, --help     Show this help message
#   -v, --verbose  Enable verbose output
#   -d, --dry-run  Show what would be done without executing
#
# Examples:
#   helper.sh command1
#   helper.sh --verbose command2
#   helper.sh --dry-run command1

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VERBOSE=false
DRY_RUN=false

log() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[INFO]${NC} $*"
    fi
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

show_help() {
    sed -n '/^# /,/^$/p' "$0" | sed 's/^# //'
}

command1() {
    log "Running command1..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would execute: actual command here"
        return 0
    fi
    
    # Implementation here
    success "Command1 completed"
}

command2() {
    log "Running command2..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would execute: actual command here"
        return 0
    fi
    
    # Implementation here
    success "Command2 completed"
}

main() {
    local command=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -*)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                command="$1"
                shift
                break
                ;;
        esac
    done
    
    if [ -z "$command" ]; then
        error "No command specified"
        show_help
        exit 1
    fi
    
    case "$command" in
        command1)
            command1 "$@"
            ;;
        command2)
            command2 "$@"
            ;;
        *)
            error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
