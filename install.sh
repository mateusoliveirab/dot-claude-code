#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Parse arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]] || [[ "${1:-}" == "-n" ]]; then
    DRY_RUN=true
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper function for dry-run
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CYAN}[dry-run] $*${NC}"
    else
        "$@"
    fi
}

echo -e "${BLUE}=== dot-claude-code installer ===${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}(dry-run mode - no changes will be made)${NC}"
fi
echo ""

# 1. Create ~/.claude/ if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}Creating $CLAUDE_DIR...${NC}"
    run_cmd mkdir -p "$CLAUDE_DIR"
else
    echo -e "${GREEN}$CLAUDE_DIR already exists.${NC}"
fi

# 2. Back up previous setup
BACKED_UP=false
FILES_TO_BACKUP=("CLAUDE.md" "settings.json" "mcp.json")

# Also backup ~/.claude.json if it exists
if [ -f "$HOME/.claude.json" ]; then
    if [ "$BACKED_UP" = false ]; then
        echo -e "${YELLOW}Backing up to $BACKUP_DIR...${NC}"
        run_cmd mkdir -p "$BACKUP_DIR"
        BACKED_UP=true
    fi
    run_cmd cp "$HOME/.claude.json" "$BACKUP_DIR/.claude.json"
    echo "  Backup: .claude.json"
fi

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$CLAUDE_DIR/$file" ]; then
        if [ "$BACKED_UP" = false ]; then
            echo -e "${YELLOW}Backing up to $BACKUP_DIR...${NC}"
            run_cmd mkdir -p "$BACKUP_DIR"
            BACKED_UP=true
        fi
        run_cmd cp "$CLAUDE_DIR/$file" "$BACKUP_DIR/$file"
        echo "  Backup: $file"
    fi
done

DIRS_TO_BACKUP=("agents" "skills" "rules")

for dir in "${DIRS_TO_BACKUP[@]}"; do
    if [ -d "$CLAUDE_DIR/$dir" ] && [ "$(ls -A "$CLAUDE_DIR/$dir" 2>/dev/null)" ]; then
        if [ "$BACKED_UP" = false ]; then
            echo -e "${YELLOW}Backing up to $BACKUP_DIR...${NC}"
            run_cmd mkdir -p "$BACKUP_DIR"
            BACKED_UP=true
        fi
        run_cmd cp -r "$CLAUDE_DIR/$dir" "$BACKUP_DIR/$dir"
        echo "  Backup: $dir/"
    fi
done

echo ""

# 3. Load .env if exists (for environment variable substitution)
ENV_LOADED=false
if [ -f "$SCRIPT_DIR/.env" ] && [ "$DRY_RUN" = false ]; then
    echo -e "${BLUE}Loading environment variables from .env...${NC}"
    set -a  # Auto-export all variables
    source "$SCRIPT_DIR/.env"
    set +a
    ENV_LOADED=true
    echo -e "  ${GREEN}Environment variables loaded${NC}"
    echo ""
fi

# 4. Install files
echo -e "${BLUE}Installing files...${NC}"

run_cmd cp "$SCRIPT_DIR/global/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo -e "  ${GREEN}CLAUDE.md${NC}"

run_cmd cp "$SCRIPT_DIR/global/settings.json" "$CLAUDE_DIR/settings.json"
echo -e "  ${GREEN}settings.json${NC}"

# Install mcp.json as reference
if [ "$DRY_RUN" = false ]; then
    if [ "$ENV_LOADED" = true ] && command -v envsubst >/dev/null 2>&1; then
        envsubst < "$SCRIPT_DIR/global/mcp.json" > "$CLAUDE_DIR/mcp.json"
        echo -e "  ${GREEN}mcp.json${NC} (reference with env vars substituted)"
    else
        cp "$SCRIPT_DIR/global/mcp.json" "$CLAUDE_DIR/mcp.json"
        echo -e "  ${GREEN}mcp.json${NC} (reference template)"
    fi
else
    echo -e "  ${CYAN}[dry-run] install mcp.json${NC}"
    echo -e "  ${GREEN}mcp.json${NC} (reference)"
fi

# Merge MCP servers into ~/.claude.json
CLAUDE_JSON="$HOME/.claude.json"
if [ "$DRY_RUN" = false ]; then
    if [ -f "$CLAUDE_JSON" ] && command -v jq >/dev/null 2>&1; then
        echo ""
        echo -e "${BLUE}Merging MCP servers into .claude.json...${NC}"

        # Create temp MCP config with env substitution
        TEMP_MCP=$(mktemp)
        if [ "$ENV_LOADED" = true ] && command -v envsubst >/dev/null 2>&1; then
            envsubst < "$SCRIPT_DIR/global/mcp.json" > "$TEMP_MCP"
        else
            cp "$SCRIPT_DIR/global/mcp.json" "$TEMP_MCP"
        fi

        # Merge mcpServers section using jq
        TEMP_JSON=$(mktemp)
        jq -s '.[0] * {"mcpServers": (.[0].mcpServers + .[1].mcpServers)}' \
            "$CLAUDE_JSON" "$TEMP_MCP" > "$TEMP_JSON"

        if [ $? -eq 0 ]; then
            mv "$TEMP_JSON" "$CLAUDE_JSON"
            echo -e "  ${GREEN}MCP servers merged successfully${NC}"
        else
            echo -e "  ${YELLOW}Failed to merge - .claude.json unchanged${NC}"
            rm -f "$TEMP_JSON"
        fi

        rm -f "$TEMP_MCP"
    elif [ ! -f "$CLAUDE_JSON" ]; then
        echo -e "  ${YELLOW}~/.claude.json not found - skipping MCP merge${NC}"
    else
        echo ""
        echo -e "${YELLOW}⚠️  jq not installed - cannot merge MCPs into .claude.json${NC}"
        echo -e "  Install jq: ${CYAN}sudo apt install jq${NC} (Ubuntu/Debian)"
        echo -e "  Or manually copy MCPs from ~/.claude/mcp.json to ~/.claude.json"
    fi
fi

# 4. Install directories (agents, rules)
for dir in agents rules; do
    SOURCE_DIR="$SCRIPT_DIR/global/$dir"
    TARGET_DIR="$CLAUDE_DIR/$dir"

    if [ -d "$SOURCE_DIR" ]; then
        run_cmd mkdir -p "$TARGET_DIR"
        if [ "$DRY_RUN" = false ]; then
            rsync -a --exclude='.gitkeep' "$SOURCE_DIR/" "$TARGET_DIR/" 2>/dev/null || {
                find "$SOURCE_DIR" -type f ! -name '.gitkeep' -exec cp --parents {} "$TARGET_DIR/" \; 2>/dev/null || true
            }
        fi
        FILE_COUNT=$(find "$SOURCE_DIR" -type f ! -name '.gitkeep' | wc -l)
        echo -e "  ${GREEN}$dir/${NC} ($FILE_COUNT files)"
    fi
done

# 5. Install skills (preserve directory structure)
SOURCE_SKILLS="$SCRIPT_DIR/global/skills"
TARGET_SKILLS="$CLAUDE_DIR/skills"

if [ -d "$SOURCE_SKILLS" ]; then
    run_cmd mkdir -p "$TARGET_SKILLS"
    for skill_dir in "$SOURCE_SKILLS"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            if [ "$DRY_RUN" = false ]; then
                cp -r "$skill_dir" "$TARGET_SKILLS/$skill_name"
            fi
        fi
    done
    SKILL_COUNT=$(find "$SOURCE_SKILLS" -mindepth 1 -maxdepth 1 -type d | wc -l)
    echo -e "  ${GREEN}skills/${NC} ($SKILL_COUNT skills)"
fi

echo ""

# 6. Summary
if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}=== Dry-run complete ===${NC}"
    echo ""
    echo "The following would be installed to $CLAUDE_DIR:"
else
    echo -e "${BLUE}=== Installation complete ===${NC}"
    echo ""
    echo "Files installed to $CLAUDE_DIR:"
fi

echo "  - CLAUDE.md       (user instructions)"
echo "  - settings.json   (settings with granular permissions)"
echo "  - mcp.json        (MCP servers: Chrome DevTools, Shadcn, Supabase)"
echo "  - agents/         (custom subagent definitions)"
echo "  - skills/         (git-commit, git-pr workflows)"
echo "  - rules/          (communication, working-approach, dev-workflow, mcp-usage, auto-memory)"
echo ""

if [ "$BACKED_UP" = true ]; then
    echo -e "${YELLOW}Backup saved to: $BACKUP_DIR${NC}"
    echo ""
fi

if [ "$DRY_RUN" = false ]; then
    echo -e "${GREEN}Restart Claude Code to apply changes.${NC}"
    echo ""
fi

echo -e "${BLUE}Available skills:${NC}"
echo "  /git-commit   - Streamlined git commit workflow"
echo "  /git-pr       - Prepare pull request (git CLI)"
