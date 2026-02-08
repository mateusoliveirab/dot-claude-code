#!/usr/bin/env bash
set -euo pipefail

# Skill Validator Script
# Validates all skills in the global/skills directory

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/../global/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
    WARNINGS=$((WARNINGS + 1))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
    ERRORS=$((ERRORS + 1))
}

validate_skill() {
    local skill_path="$1"
    local skill_name
    skill_name=$(basename "$skill_path")
    
    echo ""
    echo -e "${CYAN}Validating: $skill_name${NC}"
    
    # Check SKILL.md exists
    if [[ ! -f "$skill_path/SKILL.md" ]]; then
        log_error "SKILL.md not found"
        return 1
    fi
    
    log_ok "SKILL.md exists"
    
    # Check frontmatter
    if ! head -1 "$skill_path/SKILL.md" | grep -q '^---$'; then
        log_error "Missing frontmatter start marker (---)"
        return 1
    fi
    
    log_ok "Frontmatter start marker found"
    
    # Extract frontmatter
    local frontmatter
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_path/SKILL.md" | head -20)
    
    # Check required fields
    if ! echo "$frontmatter" | grep -q '^name:'; then
        log_error "Missing required field: name"
    else
        local name_value
        name_value=$(echo "$frontmatter" | grep '^name:' | sed 's/^name: *//')
        
        # Validate name format
        if [[ ! "$name_value" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
            log_error "Invalid name format: '$name_value' (must be lowercase with hyphens)"
        elif [[ "$name_value" != "$skill_name" ]]; then
            log_warn "Name '$name_value' doesn't match directory '$skill_name'"
        else
            log_ok "Name: $name_value"
        fi
    fi
    
    if ! echo "$frontmatter" | grep -q '^description:'; then
        log_error "Missing required field: description"
    else
        local desc_value
        desc_value=$(echo "$frontmatter" | grep '^description:' | sed 's/^description: *//')
        local desc_len=${#desc_value}
        
        if [[ $desc_len -lt 10 ]]; then
            log_warn "Description too short ($desc_len chars, min 10)"
        elif [[ $desc_len -gt 1024 ]]; then
            log_warn "Description too long ($desc_len chars, max 1024)"
        else
            log_ok "Description: ${desc_value:0:50}..."
        fi
    fi
    
    # Check optional fields
    if echo "$frontmatter" | grep -q '^compatibility:'; then
        log_ok "Compatibility field present"
    fi
    
    if echo "$frontmatter" | grep -q '^metadata:'; then
        log_ok "Metadata field present"
    fi
    
    # Validate scripts
    if [[ -d "$skill_path/scripts" ]]; then
        local script_count=0
        for script in "$skill_path/scripts"/*; do
            if [[ -f "$script" ]]; then
                script_count=$((script_count + 1))
                
                # Check if executable
                if [[ ! -x "$script" ]]; then
                    log_warn "Script not executable: $(basename "$script")"
                fi
                
                # Validate bash syntax
                if [[ "$script" == *.sh ]]; then
                    if bash -n "$script" 2>/dev/null; then
                        log_ok "Script syntax valid: $(basename "$script")"
                    else
                        log_error "Script syntax error: $(basename "$script")"
                    fi
                fi
            fi
        done
        
        if [[ $script_count -eq 0 ]]; then
            log_warn "scripts/ directory exists but is empty"
        fi
    fi
    
    # Check file references
    local refs
    refs=$(grep -oE '\[([^]]+)\]\(([^)]+)\)' "$skill_path/SKILL.md" | grep -v 'http' | sed 's/.*(\(.*\)).*/\1/' || true)
    
    for ref in $refs; do
        # Remove leading ./ if present
        ref="${ref#./}"
        local full_path="$skill_path/$ref"
        
        if [[ ! -f "$full_path" ]] && [[ ! -d "$full_path" ]]; then
            log_warn "Broken reference: $ref"
        fi
    done
    
    log_ok "Validation complete for $skill_name"
}

generate_skills_xml() {
    echo ""
    log_info "Generating skills XML for agent prompt..."
    echo ""
    
    echo "<available_skills>"
    
    for skill_path in "$SKILLS_DIR"/*/; do
        if [[ -f "$skill_path/SKILL.md" ]]; then
            local skill_name
            skill_name=$(basename "$skill_path")
            
            local frontmatter
            frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_path/SKILL.md")
            
            local name description
            name=$(echo "$frontmatter" | grep '^name:' | sed 's/^name: *//' || echo "$skill_name")
            description=$(echo "$frontmatter" | grep '^description:' | sed 's/^description: *//' || echo "No description")
            
            echo "  <skill>"
            echo "    <name>$name</name>"
            echo "    <description>$description</description>"
            echo "    <location>$skill_path/SKILL.md</location>"
    echo "  </skill>"
        fi
    done
    
    echo "</available_skills>"
}

show_help() {
    cat << 'EOF'
Usage: validate-all-skills.sh [options] [skills-directory]

Validates all skills in the specified directory.

Arguments:
    skills-directory    Path to skills directory (default: ../global/skills)

Options:
    -x, --xml          Generate XML output for agent prompts
    -h, --help         Show this help message

Examples:
    validate-all-skills.sh
    validate-all-skills.sh /path/to/skills
    validate-all-skills.sh --xml
EOF
}

main() {
    local generate_xml=false
    local skills_dir=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -x|--xml)
                generate_xml=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                skills_dir="$1"
                shift
                ;;
        esac
    done
    
    # Set skills directory
    if [[ -n "$skills_dir" ]]; then
        SKILLS_DIR="$skills_dir"
    fi
    
    # Check directory exists
    if [[ ! -d "$SKILLS_DIR" ]]; then
        log_error "Skills directory not found: $SKILLS_DIR"
        exit 1
    fi
    
    log_info "Validating skills in: $SKILLS_DIR"
    
    if [[ "$generate_xml" == true ]]; then
        generate_skills_xml
        exit 0
    fi
    
    # Validate each skill
    local skill_count=0
    for skill_path in "$SKILLS_DIR"/*/; do
        if [[ -d "$skill_path" ]] && [[ -f "$skill_path/SKILL.md" ]]; then
            validate_skill "$skill_path"
            skill_count=$((skill_count + 1))
        fi
    done
    
    echo ""
    echo "========================================"
    log_info "Validation Summary"
    echo "========================================"
    echo "Skills validated: $skill_count"
    echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
    echo -e "Errors: ${RED}$ERRORS${NC}"
    echo ""
    
    if [[ $ERRORS -eq 0 ]]; then
        log_ok "All validations passed!"
        exit 0
    else
        log_error "Validation failed with $ERRORS error(s)"
        exit 1
    fi
}

main "$@"
