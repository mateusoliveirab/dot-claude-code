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
RED='\033[0;31m'
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

# ── Diff helpers ──────────────────────────────────────────────

colored_diff() {
    local repo_file="$1" local_file="$2"
    local diffout
    diffout=$(diff -u "$local_file" "$repo_file" 2>/dev/null) || true
    # Non-empty output that doesn't start with "---" means binary or error
    [[ -n "$diffout" ]] && [[ "${diffout:0:3}" != "---" ]] && {
        printf "  ${GRAY}(binary file — skipped)${NC}\n"; return
    }
    printf '%s\n' "$diffout" | while IFS= read -r line; do
        case "$line" in
            +++*|---*) printf "  ${GRAY}%s${NC}\n" "$line" ;;
            @@*)       printf "  ${CYAN}%s${NC}\n" "$line" ;;
            +*)        printf "  ${GREEN}%s${NC}\n" "$line" ;;
            -*)        printf "  ${RED}%s${NC}\n" "$line" ;;
            *)         printf "  %s\n" "$line" ;;
        esac
    done
}

colored_diff_dir() {
    # Strip trailing slashes to avoid double-slash in rel stripping
    local repo_dir="${1%/}" local_dir="${2%/}"
    while IFS= read -r -d $'\0' file; do
        local rel="${file#"$repo_dir"/}"
        [[ "$rel" == ".gitkeep" ]] && continue
        local local_file="$local_dir/$rel"
        if [ ! -f "$local_file" ]; then
            printf "  ${GREEN}+ %s${NC} ${GRAY}(new)${NC}\n" "$rel"
        elif ! diff -q "$file" "$local_file" >/dev/null 2>&1; then
            printf "  ${GRAY}── %s ──${NC}\n" "$rel"
            colored_diff "$file" "$local_file"
        fi
    done < <(find "$repo_dir" -type f -not -path '*/.git/*' -print0)
    [ -d "$local_dir" ] && while IFS= read -r -d $'\0' file; do
        local rel="${file#"$local_dir"/}"
        [[ "$rel" == ".gitkeep" ]] && continue
        [ -f "$repo_dir/$rel" ] || printf "  ${RED}- %s${NC} ${GRAY}(not in repo)${NC}\n" "$rel"
    done < <(find "$local_dir" -type f -not -path '*/.git/*' -print0)
}

# ── Phase 1: Scan & Preview ───────────────────────────────────

printf "${BOLD}dot-claude-code${NC}  ${GRAY}→ ~/.claude${NC}\n"
echo ""
_src_parts=()
for _item in "$SCRIPT_DIR/global/"*; do
    [ -f "$_item" ] && _src_parts+=("$(basename "$_item")")
done
for _item in "$SCRIPT_DIR/global/"/*/; do
    [ -d "$_item" ] && _src_parts+=("$(basename "$_item")/")
done
_src_list=$(IFS=; printf '%s' "${_src_parts[*]/#/ · }"); _src_list="${_src_list# · }"
printf "  ${GRAY}source:${NC}   global/  ·  %s\n" "$_src_list"
printf "  ${GRAY}promote:${NC}  choose ${CYAN}(P)${NC} at conflicts → copies ~/.claude/<file> back to global/<file> → commit\n"
echo ""

echo "  Files"
echo "$DIV"
for _f in "$SCRIPT_DIR/global/"*; do
    [ -f "$_f" ] || continue
    _fname=$(basename "$_f")
    [[ "$_fname" == "plugins.txt" ]] && continue  # handled separately
    scan_file "$_f" "$CLAUDE_DIR/$_fname" "$_fname"
done
echo ""

TOTAL_ORPHANS=0
DIR_NAMES=(); DIR_CHANGED=(); DIR_UNCH=(); DIR_LABELS=()

for _d in "$SCRIPT_DIR/global/"/*/; do
    [ -d "$_d" ] || continue
    _dname=$(basename "$_d")
    if [[ "$_dname" == "skills" ]]; then
        scan_skills "$_d" "$CLAUDE_DIR/$_dname"
        _label=""
        for _n in "${SKILLS_MOD_NAMES[@]}"; do
            [ -n "$_label" ] && _label+=" · "; _label+="$_n"
        done
        DIR_LABELS+=("$_label")
        TOTAL_ORPHANS=$((TOTAL_ORPHANS + _ORP))
    else
        scan_dir "$_d" "$CLAUDE_DIR/$_dname" "$_dname"
        DIR_LABELS+=("")
        TOTAL_ORPHANS=$((TOTAL_ORPHANS + _ORP))
    fi
    DIR_NAMES+=("$_dname/")
    DIR_CHANGED+=($((_MOD + _ORP)))
    DIR_UNCH+=("$_UNCH")
done

if [ $TOTAL_ORPHANS -gt 0 ]; then
    printf "  Directories  ${GRAY}·  %d untracked orphans${NC}\n" "$TOTAL_ORPHANS"
else
    echo "  Directories"
fi
echo "$DIV"
for _i in "${!DIR_NAMES[@]}"; do
    dir_row "${DIR_NAMES[$_i]}" "${DIR_CHANGED[$_i]}" "${DIR_UNCH[$_i]}" "${DIR_LABELS[$_i]}"
done
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
            _promote_total=${#DECIDE_LABELS[@]}
            printf "\n  ${YELLOW}promote all writes %d item(s) back to the source repo.${NC}\n" "$_promote_total"
            printf "  ${GRAY}Type the count to confirm:${NC} "
            read -r _confirm_count
            echo ""
            if [[ "$_confirm_count" =~ ^[0-9]+$ ]] && [[ "$_confirm_count" -eq "$_promote_total" ]]; then
                for i in "${!DECIDE_LABELS[@]}"; do DECIDE_CHOICES[$i]="p"; done
            else
                printf "${GRAY}aborted.${NC}\n"
                exit 1
            fi
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
                        echo "$DIV"
                        if [[ "$type" == "modified_dir" ]]; then
                            colored_diff_dir "${DECIDE_SRCS[$i]}" "${DECIDE_TGTS[$i]}"
                        else
                            colored_diff "${DECIDE_SRCS[$i]}" "${DECIDE_TGTS[$i]}"
                        fi
                        echo "$DIV"
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

[ -f "$HOME/.claude.json" ] && { ensure_backup; cp "$HOME/.claude.json" "$BACKUP_DIR/.claude.json"; }
for _f in "$SCRIPT_DIR/global/"*; do
    [ -f "$_f" ] || continue
    _fname=$(basename "$_f")
    [[ "$_fname" == "plugins.txt" ]] && continue
    [ -f "$CLAUDE_DIR/$_fname" ] && { ensure_backup; cp "$CLAUDE_DIR/$_fname" "$BACKUP_DIR/$_fname"; }
done
for _d in "$SCRIPT_DIR/global/"/*/; do
    [ -d "$_d" ] || continue
    _dname=$(basename "$_d")
    [ -d "$CLAUDE_DIR/$_dname" ] && [ "$(ls -A "$CLAUDE_DIR/$_dname" 2>/dev/null)" ] && { ensure_backup; cp -r "$CLAUDE_DIR/$_dname" "$BACKUP_DIR/$_dname"; }
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

# Plugins
PLUGINS_FILE="$SCRIPT_DIR/global/plugins.txt"
if [ -f "$PLUGINS_FILE" ] && command -v claude >/dev/null 2>&1; then
    INSTALLED_PLUGINS_JSON="$CLAUDE_DIR/plugins/installed_plugins.json"
    STAT_PLUGINS_NEW=0
    STAT_PLUGINS_SKIP=0

    echo "  Plugins"
    echo "$DIV"
    while IFS= read -r plugin || [ -n "$plugin" ]; do
        [[ -z "$plugin" || "$plugin" == \#* ]] && continue
        # Check if already installed
        if [ -f "$INSTALLED_PLUGINS_JSON" ] && command -v jq >/dev/null 2>&1 \
            && jq -e --arg p "$plugin" '.plugins[$p]' "$INSTALLED_PLUGINS_JSON" >/dev/null 2>&1; then
            printf "  ${GRAY}✓${NC}  %s\n" "$plugin"
            STAT_PLUGINS_SKIP=$((STAT_PLUGINS_SKIP + 1))
        else
            printf "  ${GREEN}+${NC}  %s  " "$plugin"
            if claude plugin install "$plugin" --scope user >/dev/null 2>&1; then
                printf "${GREEN}installed${NC}\n"
                STAT_PLUGINS_NEW=$((STAT_PLUGINS_NEW + 1))
            else
                printf "${YELLOW}failed — run: claude plugin install %s${NC}\n" "$plugin"
            fi
        fi
    done < "$PLUGINS_FILE"
    echo ""
fi

# Tools
echo "  Tools"
echo "$DIV"
if ! command -v rtk >/dev/null 2>&1; then
    printf "  ${GREEN}+${NC}  rtk  "
    if curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh >/dev/null 2>&1; then
        printf "${GREEN}installed${NC}\n"
        printf "\n"
        printf "  ${CYAN}rtk${NC} — token-saving proxy for Claude Code bash commands\n"
        printf "  ${GRAY}Next steps:${NC}\n"
        printf "  ${GRAY}  1.${NC} Activate the auto-rewrite hook:  ${CYAN}rtk init --global${NC}\n"
        printf "  ${GRAY}  2.${NC} Check token savings anytime:     ${CYAN}rtk gain${NC}\n"
        printf "  ${GRAY}  After init, all bash commands are transparently rewritten — no extra steps.${NC}\n"
    else
        printf "${YELLOW}failed${NC}\n"
        printf "  ${GRAY}Run manually:${NC} curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh\n"
    fi
else
    printf "  ${GRAY}✓${NC}  rtk\n"
fi
echo ""

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
