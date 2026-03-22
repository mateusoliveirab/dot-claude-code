#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/.backup/$(date +%Y%m%d-%H%M)"

DRY_RUN=false
AUTO_YES=false
for arg in "$@"; do
    case "$arg" in
        --dry-run|-n) DRY_RUN=true ;;
        --yes|-y)     AUTO_YES=true ;;
    esac
done

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'
DIV="  ─────────────────────────────"

DECIDE_LABELS=()
DECIDE_TYPES=()
DECIDE_SRCS=()
DECIDE_TGTS=()
DECIDE_CHOICES=()

AUTO_SRCS=()
AUTO_TGTS=()
AUTO_IS_DIR=()

# Temp globals for dir scan results
_NEW=0; _MOD=0; _UNCH=0; _ORP=0
SKILLS_MOD_NAMES=()

add_decision() { DECIDE_LABELS+=("$1"); DECIDE_TYPES+=("$2"); DECIDE_SRCS+=("$3"); DECIDE_TGTS+=("$4"); DECIDE_CHOICES+=(""); }
add_auto()     { AUTO_SRCS+=("$1"); AUTO_TGTS+=("$2"); AUTO_IS_DIR+=("${3:-false}"); }

# ── Scan helpers ──────────────────────────────────────────────

scan_file() {
    local src="$1" tgt="$2" label="$3"
    if [ ! -f "$tgt" ]; then
        printf "  ${GREEN}+${NC}  %s\n" "$label"
        add_auto "$src" "$tgt" "false"
    elif diff -q "$src" "$tgt" >/dev/null 2>&1; then
        printf "  ${GRAY}✓${NC}  %s\n" "$label"
    else
        printf "  ${YELLOW}~${NC}  %s\n" "$label"
        add_decision "$label" "modified" "$src" "$tgt"
    fi
}

scan_dir() {
    local src="$1" tgt="$2" dir_label="$3"
    _NEW=0; _MOD=0; _UNCH=0; _ORP=0
    [ -d "$src" ] || return
    while IFS= read -r -d $'\0' file; do
        local rel="${file#"$src"/}"
        [[ "$rel" == ".gitkeep" ]] && continue
        local tgt_file="$tgt/$rel"
        if [ ! -f "$tgt_file" ]; then
            _NEW=$((_NEW + 1)); add_auto "$file" "$tgt_file" "false"
        elif diff -q "$file" "$tgt_file" >/dev/null 2>&1; then
            _UNCH=$((_UNCH + 1))
        else
            _MOD=$((_MOD + 1)); add_decision "$dir_label/$rel" "modified" "$file" "$tgt_file"
        fi
    done < <(find "$src" -type f -print0)
    if [ -d "$tgt" ]; then
        while IFS= read -r -d $'\0' file; do
            local rel="${file#"$tgt"/}"
            [ -f "$src/$rel" ] || { _ORP=$((_ORP + 1)); add_decision "$dir_label/$rel" "orphan" "" "$file"; }
        done < <(find "$tgt" -type f -print0)
    fi
}

scan_skills() {
    local src="$1" tgt="$2"
    _NEW=0; _MOD=0; _UNCH=0; _ORP=0
    SKILLS_MOD_NAMES=()
    [ -d "$src" ] || return
    for skill_dir in "$src"/*/; do
        [ -d "$skill_dir" ] || continue
        local skill; skill=$(basename "$skill_dir")
        if [ ! -d "$tgt/$skill" ]; then
            _NEW=$((_NEW + 1)); add_auto "$skill_dir" "$tgt/$skill" "true"
        elif diff -rq --exclude='.gitkeep' "$skill_dir" "$tgt/$skill" >/dev/null 2>&1; then
            _UNCH=$((_UNCH + 1))
        else
            _MOD=$((_MOD + 1)); SKILLS_MOD_NAMES+=("$skill")
            add_decision "skills/$skill" "modified_dir" "$skill_dir" "$tgt/$skill"
        fi
    done
    if [ -d "$tgt" ]; then
        for skill_dir in "$tgt"/*/; do
            [ -d "$skill_dir" ] || continue
            local skill; skill=$(basename "$skill_dir")
            if [ ! -d "$src/$skill" ]; then
                _ORP=$((_ORP + 1)); SKILLS_MOD_NAMES+=("$skill")
                add_decision "skills/$skill" "orphan_dir" "" "$skill_dir"
            fi
        done
    fi
}

dir_row() {
    local label="$1" changed="$2" unch="$3" names="${4:-}"
    if [ "$changed" -eq 0 ]; then
        printf "  %-10s ${GRAY}all up to date${NC}\n" "$label"
    elif [ -n "$names" ]; then
        printf "  %-10s ${YELLOW}%d changed${NC}  ${GRAY}·  %s${NC}\n" "$label" "$changed" "$names"
    else
        printf "  %-10s ${YELLOW}%d changed${NC}  ${GRAY}·  %d unchanged${NC}\n" "$label" "$changed" "$unch"
    fi
}

# ── Phase 1: Scan & Preview ───────────────────────────────────

printf "${BOLD}dot-claude-code${NC}  ${GRAY}→ ~/.claude${NC}\n"
echo ""

echo "  Files"
echo "$DIV"
scan_file "$SCRIPT_DIR/global/CLAUDE.md"     "$CLAUDE_DIR/CLAUDE.md"     "CLAUDE.md"
scan_file "$SCRIPT_DIR/global/settings.json" "$CLAUDE_DIR/settings.json" "settings.json"
scan_file "$SCRIPT_DIR/global/mcp.json"      "$CLAUDE_DIR/mcp.json"      "mcp.json"
echo ""

scan_dir "$SCRIPT_DIR/global/agents" "$CLAUDE_DIR/agents" "agents"
A_MOD=$_MOD; A_UNCH=$_UNCH; A_ORP=$_ORP

scan_dir "$SCRIPT_DIR/global/rules" "$CLAUDE_DIR/rules" "rules"
R_MOD=$_MOD; R_UNCH=$_UNCH; R_ORP=$_ORP

scan_skills "$SCRIPT_DIR/global/skills" "$CLAUDE_DIR/skills"
S_MOD=$_MOD; S_UNCH=$_UNCH; S_ORP=$_ORP

TOTAL_ORPHANS=$((A_ORP + R_ORP + S_ORP))

if [ $TOTAL_ORPHANS -gt 0 ]; then
    printf "  Directories  ${GRAY}·  %d untracked orphans${NC}\n" "$TOTAL_ORPHANS"
else
    echo "  Directories"
fi
echo "$DIV"
dir_row "agents/"  $((A_MOD + A_ORP)) "$A_UNCH"
dir_row "rules/"   $((R_MOD + R_ORP)) "$R_UNCH"
if [ ${#SKILLS_MOD_NAMES[@]} -gt 0 ]; then
    skill_list=""
    for name in "${SKILLS_MOD_NAMES[@]}"; do
        [ -n "$skill_list" ] && skill_list+=" · "
        skill_list+="$name"
    done
    dir_row "skills/" $((S_MOD + S_ORP)) "$S_UNCH" "$skill_list"
else
    dir_row "skills/" 0 "$S_UNCH"
fi
echo ""

# Nothing to do?
if [ ${#DECIDE_LABELS[@]} -eq 0 ] && [ ${#AUTO_SRCS[@]} -eq 0 ]; then
    printf "${GRAY}everything up to date.${NC}\n"
    exit 0
fi

[ "$DRY_RUN" = true ] && { printf "${GRAY}(dry-run — no changes made)${NC}\n"; exit 0; }

# ── Phase 2: Bulk actions ─────────────────────────────────────

if [ ${#DECIDE_LABELS[@]} -gt 0 ] && [ "$AUTO_YES" = false ]; then
    echo "  Conflicts — bulk actions"
    echo "$DIV"
    printf "  ${CYAN}(A)${NC} increment all   ${GRAY}keep local changes, new repo files are added alongside${NC}\n"
    printf "  ${CYAN}(R)${NC} replace all     ${GRAY}overwrite local with repo version${NC}\n"
    printf "  ${CYAN}(P)${NC} promote all     ${GRAY}push local changes back to source repo${NC}\n"
    printf "  ${CYAN}(M)${NC} decide one by one\n"
    echo ""
    printf "  ${CYAN}→${NC} "
    read -r bulk_choice
    echo ""

    case "$bulk_choice" in
        A|a)
            for i in "${!DECIDE_LABELS[@]}"; do DECIDE_CHOICES[$i]="k"; done
            ;;
        R|r)
            for i in "${!DECIDE_LABELS[@]}"; do
                [[ "${DECIDE_TYPES[$i]}" == orphan* ]] && DECIDE_CHOICES[$i]="k" || DECIDE_CHOICES[$i]="r"
            done
            ;;
        P|p)
            for i in "${!DECIDE_LABELS[@]}"; do DECIDE_CHOICES[$i]="p"; done
            ;;
        M|m)
            echo "$DIV"
            total="${#DECIDE_LABELS[@]}"
            for i in "${!DECIDE_LABELS[@]}"; do
                label="${DECIDE_LABELS[$i]}"
                type="${DECIDE_TYPES[$i]}"
                printf "  ${BOLD}[%d/%d]${NC} %s\n" "$((i+1))" "$total" "$label"
                case "$type" in
                    modified|modified_dir)
                        printf "         ${CYAN}(r)${NC} replace  ${CYAN}(k)${NC} keep  ${CYAN}(p)${NC} promote  ${CYAN}→${NC} "
                        read -r choice
                        case "$choice" in
                            r|R) DECIDE_CHOICES[$i]="r" ;;
                            p|P) DECIDE_CHOICES[$i]="p" ;;
                            *)   DECIDE_CHOICES[$i]="k" ;;
                        esac
                        ;;
                    orphan|orphan_dir)
                        printf "         ${CYAN}(d)${NC} delete  ${CYAN}(k)${NC} keep  ${CYAN}(p)${NC} promote  ${CYAN}→${NC} "
                        read -r choice
                        case "$choice" in
                            d|D) DECIDE_CHOICES[$i]="d" ;;
                            p|P) DECIDE_CHOICES[$i]="p" ;;
                            *)   DECIDE_CHOICES[$i]="k" ;;
                        esac
                        ;;
                esac
            done
            echo ""
            ;;
        *)
            printf "${GRAY}aborted.${NC}\n"
            exit 0
            ;;
    esac
elif [ ${#DECIDE_LABELS[@]} -gt 0 ] && [ "$AUTO_YES" = true ]; then
    # --yes defaults to increment (keep local, install new)
    for i in "${!DECIDE_LABELS[@]}"; do DECIDE_CHOICES[$i]="k"; done
fi

# ── Phase 3: Execute ──────────────────────────────────────────

BACKED_UP=false
ensure_backup() {
    if [ "$BACKED_UP" = false ]; then
        mkdir -p "$BACKUP_DIR"; BACKED_UP=true
    fi
}

[ -f "$HOME/.claude.json" ]        && { ensure_backup; cp "$HOME/.claude.json" "$BACKUP_DIR/.claude.json"; }
[ -f "$CLAUDE_DIR/CLAUDE.md" ]     && { ensure_backup; cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"; }
[ -f "$CLAUDE_DIR/settings.json" ] && { ensure_backup; cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/settings.json"; }
[ -f "$CLAUDE_DIR/mcp.json" ]      && { ensure_backup; cp "$CLAUDE_DIR/mcp.json" "$BACKUP_DIR/mcp.json"; }
for dir in agents skills rules; do
    [ -d "$CLAUDE_DIR/$dir" ] && [ "$(ls -A "$CLAUDE_DIR/$dir" 2>/dev/null)" ] && { ensure_backup; cp -r "$CLAUDE_DIR/$dir" "$BACKUP_DIR/$dir"; }
done

ENV_LOADED=false
if [ -f "$SCRIPT_DIR/.env" ]; then
    set -a
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/.env"
    set +a
    ENV_LOADED=true
fi

mkdir -p "$CLAUDE_DIR"

STAT_COPIED=0; STAT_REPLACED=0; STAT_PROMOTED=0; STAT_DELETED=0; STAT_KEPT=0
PROMOTED_LABELS=()

# Auto-install new items
for i in "${!AUTO_SRCS[@]}"; do
    src="${AUTO_SRCS[$i]}"; tgt="${AUTO_TGTS[$i]}"; is_dir="${AUTO_IS_DIR[$i]}"
    mkdir -p "$(dirname "$tgt")"
    if [ "$is_dir" = "true" ]; then
        mkdir -p "$tgt"
        rsync -a --exclude='.gitkeep' "$src/" "$tgt/" 2>/dev/null || cp -r "$src/." "$tgt/"
    else
        cp "$src" "$tgt"
    fi
    STAT_COPIED=$((STAT_COPIED + 1))
done

# Apply env substitution for mcp.json
if [ -f "$CLAUDE_DIR/mcp.json" ] && [ "$ENV_LOADED" = true ] && command -v envsubst >/dev/null 2>&1; then
    envsubst < "$SCRIPT_DIR/global/mcp.json" > "$CLAUDE_DIR/mcp.json"
fi

# Apply decisions
for i in "${!DECIDE_LABELS[@]}"; do
    label="${DECIDE_LABELS[$i]}"; type="${DECIDE_TYPES[$i]}"
    src="${DECIDE_SRCS[$i]}";     tgt="${DECIDE_TGTS[$i]}"
    choice="${DECIDE_CHOICES[$i]}"
    repo_dest="$SCRIPT_DIR/global/${tgt#"$CLAUDE_DIR/"}"

    case "$choice" in
        r)  mkdir -p "$(dirname "$tgt")"
            if [[ "$type" == *"_dir" ]]; then
                mkdir -p "$tgt"; rsync -a --exclude='.gitkeep' "$src/" "$tgt/" 2>/dev/null || cp -r "$src/." "$tgt/"
            else cp "$src" "$tgt"; fi
            STAT_REPLACED=$((STAT_REPLACED + 1)) ;;
        p)  if [[ "$type" == *"_dir" ]]; then
                mkdir -p "$repo_dest"; rsync -a --exclude='.gitkeep' "$tgt/" "$repo_dest/" 2>/dev/null || cp -r "$tgt/." "$repo_dest/"
            else mkdir -p "$(dirname "$repo_dest")"; cp "$tgt" "$repo_dest"; fi
            PROMOTED_LABELS+=("$label")
            STAT_PROMOTED=$((STAT_PROMOTED + 1)) ;;
        d)  if [[ "$type" == *"_dir" ]]; then rm -rf "$tgt"; else rm -f "$tgt"; fi
            STAT_DELETED=$((STAT_DELETED + 1)) ;;
        k)  STAT_KEPT=$((STAT_KEPT + 1)) ;;
    esac
done

# MCP merge into ~/.claude.json
CLAUDE_JSON="$HOME/.claude.json"
if [ -f "$CLAUDE_JSON" ] && command -v jq >/dev/null 2>&1; then
    TEMP_MCP=$(mktemp)
    [ "$ENV_LOADED" = true ] && command -v envsubst >/dev/null 2>&1 \
        && envsubst < "$SCRIPT_DIR/global/mcp.json" > "$TEMP_MCP" \
        || cp "$SCRIPT_DIR/global/mcp.json" "$TEMP_MCP"
    TEMP_JSON=$(mktemp)
    jq -s '.[0] * {"mcpServers": (.[0].mcpServers + .[1].mcpServers)}' \
        "$CLAUDE_JSON" "$TEMP_MCP" > "$TEMP_JSON" \
        && mv "$TEMP_JSON" "$CLAUDE_JSON" || rm -f "$TEMP_JSON"
    rm -f "$TEMP_MCP"
fi

# ── Summary ───────────────────────────────────────────────────

echo ""
if [ ${#PROMOTED_LABELS[@]} -gt 0 ]; then
    echo "  Promoted — review and commit:"
    echo "$DIV"
    for lbl in "${PROMOTED_LABELS[@]}"; do
        printf "  ${GREEN}+${NC}  global/%s\n" "${lbl#*/}"
    done
    echo ""
fi

# Skills list
echo "  Skills"
echo "$DIV"
if [ -d "$CLAUDE_DIR/skills" ]; then
    for skill_dir in "$CLAUDE_DIR/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        printf "  ${GRAY}/$(basename "$skill_dir")${NC}\n"
    done
fi
echo ""

# Done line
printf "${GRAY}done"
[ $STAT_COPIED -gt 0 ]   && printf "  ·  %d copied"   "$STAT_COPIED"
[ $STAT_REPLACED -gt 0 ] && printf "  ·  %d replaced"  "$STAT_REPLACED"
[ $STAT_PROMOTED -gt 0 ] && printf "  ·  %d promoted"  "$STAT_PROMOTED"
[ $STAT_DELETED -gt 0 ]  && printf "  ·  %d deleted"   "$STAT_DELETED"
[ $STAT_KEPT -gt 0 ]     && printf "  ·  %d kept"      "$STAT_KEPT"
[ "$BACKED_UP" = true ]  && printf "  ·  backup → %s"  "${BACKUP_DIR/#$HOME/\~}"
printf "${NC}\n\n"
printf "${GRAY}restart Claude Code to apply changes.${NC}\n\n"
